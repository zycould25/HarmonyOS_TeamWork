import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import User from '../model/Users'
import { UserDBManager } from '../dataBase/localDB'

@Entry
@Component
struct RegisterPage {
  @State username: string = "";
  @State password: string = "";
  @State confirmPassword: string = "";
  @State phoneNumber: string = "";
  @State verificationCode: string = "";
  @State countdown: number = 0;
  @State private dbManager: UserDBManager | null = null;
  private timerId: number = -1;

  async aboutToAppear() {
    try {
      this.dbManager = await UserDBManager.getInstance();
    } catch (e) {
      console.error("Database init error:", e);
    }
  }

  // 倒计时控制
  private startCountdown() {
    if (this.countdown > 0) return;

    this.countdown = 120;
    this.timerId = setInterval(() => {
      if (this.countdown > 0) {
        this.countdown -= 1;
      } else {
        clearInterval(this.timerId);
      }
    }, 1000);
  }

  // 验证码校验
  private confirmVerificationCode(): boolean {
    // TODO: 实际应调用服务端验证，临时模拟验证码为123456
    return this.verificationCode === "123456";
  }

  build() {
    Column({ space: 15 }) {
      Text($r("app.string.registerTitle"))
        .fontSize(24)

      TextInput({ placeholder: $r("app.string.registerUsername") })
        .width('100%')
        .onChange(value => this.username = value)

      // 手机号+验证码行
      Row() {
        TextInput({ placeholder: $r("app.string.registerPhone") })
          .type(InputType.PhoneNumber)
          .layoutWeight(1)
          .onChange(value => this.phoneNumber = value)

        Button(this.countdown > 0 ? `${this.countdown}秒后重试` : $r("app.string.sendVerificationCode"))
          .width(120)
          .flexShrink(0)
          .enabled(this.countdown === 0)
          .fontColor($r("app.color.write"))
          .backgroundColor($r("app.color.starBlue"))
          .onClick(() => {
            this.startCountdown();
            // TODO: 实际发送验证码逻辑
            console.log("发送验证码到:", this.phoneNumber);
          })
      }
      .width('100%')

      // 验证码输入
      TextInput({ placeholder: $r("app.string.inputVerificationCode") })
        .type(InputType.Number)
        .width('100%')
        .onChange(value => this.verificationCode = value)

      TextInput({ placeholder: $r("app.string.registerPassword") })
        .type(InputType.Password)
        .width('100%')
        .onChange(value => this.password = value)

      TextInput({ placeholder: $r("app.string.confirmPassword") })
        .type(InputType.Password)
        .width('100%')
        .onChange(value => this.confirmPassword = value)

      Button($r("app.string.register"))
        .fontColor($r("app.color.write"))
        .backgroundColor($r("app.color.starBlue"))
        .width('100%')
        .onClick(async () => {
          await this.handleRegistration();
        })

      Button($r("app.string.backToLogin"))
        .width('100%')
        .fontColor($r("app.color.write"))
        .backgroundColor($r("app.color.starBlue"))
        .onClick(() => {
          router.pushUrl({ url: 'pages/LogIn' });
        })
    }
    .padding(20)
  }

  private async handleRegistration() {
    if (!this.validateInput()) return;

    try {
      if (!this.dbManager) {
        promptAction.showToast({ message: $r("app.string.databaseError") });
        return;
      }

      // 检查用户是否存在
      const existingUser = await this.dbManager.getUserByName(this.username);
      if (existingUser) {
        promptAction.showToast({ message: $r("app.string.userExists") });
        return;
      }

      // 创建新用户（包含手机号）
      const newUser = new User(
        this.username,
        this.password,
        this.phoneNumber,  // 保存手机号
        ""  // 头像字段
      );

      const userId = await this.dbManager.addUser(newUser);
      if (userId !== -1) {
        promptAction.showToast({ message: $r("app.string.registrationSuccess") });
        router.back();
      }
    } catch (e) {
      console.error("Registration failed:", e);
      promptAction.showToast({ message: $r("app.string.registrationFailed") });
    }
  }

  private validateInput(): boolean {
    if (!this.username.trim()) {
      promptAction.showToast({ message: $r("app.string.emptyUsername") });
      return false;
    }

    if (!this.phoneNumber.trim()) {
      promptAction.showToast({ message: $r("app.string.emptyPhone") });
      return false;
    }

    if (!this.verificationCode.trim()) {
      promptAction.showToast({ message: $r("app.string.emptyVerificationCode") });
      return false;
    }

    if (!this.confirmVerificationCode()) {
      promptAction.showToast({ message: $r("app.string.wrongVerificationCode") });
      return false;
    }

    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: $r("app.string.passwordMismatch") });
      return false;
    }

    if (this.password.length < 6) {
      promptAction.showToast({ message: $r("app.string.passwordTooShort") });
      return false;
    }

    return true;
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
  }
}
