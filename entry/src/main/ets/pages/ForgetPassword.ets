import { promptAction, router } from '@kit.ArkUI';
import User from '../model/Users'
import { UserDBManager } from '../dataBase/localDB'

@Entry
@Component
struct ForgetPassword {
  @State UserName: string = "";
  @State PhoneNumber: string = "";
  @State VerificationCode: string = "";
  @State Password: string = "";
  @State ConfirmPassword: string = "";
  @State countdown: number = 0;
  @State private dbManager: UserDBManager | null = null;
  private timerId: number = -1;

  // 初始化数据库
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

  // 验证码校验（模拟实现）
  private confirmVerificationCode(): boolean {
    // TODO: 实际应调用服务端验证，临时模拟验证码为123456
    return this.VerificationCode === "123456";
  }

  // 密码修改核心逻辑
  private async modifyPassword() {
    // 基础验证
    if (!this.validateInput()) return;

    // 数据库操作
    if (!this.dbManager) {
      promptAction.showToast({ message: $r("app.string.databaseError") });
      return;
    }

    try {
      const user = await this.dbManager.getUserByName(this.UserName);
      if (!user) {
        promptAction.showToast({ message: $r("app.string.userNotFound") });
        return;
      }

      if (user.phoneNumber !== this.PhoneNumber) {
        promptAction.showToast({ message: $r("app.string.phoneMismatch") });
        return;
      }

      // 创建更新后的用户对象（保留原积分和头像）
      const updatedUser = new User(
        user.userName,
        this.Password,       // 新密码
        user.phoneNumber,
        user.score,          // 继承原积分
        user.profile         // 原头像
      );

      const success = await this.dbManager.updateUser(updatedUser);
      if (success) {
        promptAction.showToast({ message: $r("app.string.passwordResetSuccess") });
        router.pushUrl({ url: 'pages/LogIn' });
      } else {
        promptAction.showToast({ message: $r("app.string.updateFailed") });
      }
    } catch (e) {
      console.error("Password reset error:", e);
      promptAction.showToast({ message: $r("app.string.operationFailed") });
    }
  }
  // 输入验证
  private validateInput(): boolean {
    if (!this.UserName.trim()) {
      promptAction.showToast({ message: $r("app.string.emptyUsername") });
      return false;
    }

    if (!this.PhoneNumber.trim()) {
      promptAction.showToast({ message: $r("app.string.emptyPhone") });
      return false;
    }

    if (!this.VerificationCode.trim()) {
      promptAction.showToast({ message: $r("app.string.emptyVerificationCode") });
      return false;
    }

    if (!this.confirmVerificationCode()) {
      promptAction.showToast({ message: $r("app.string.wrongVerificationCode") });
      return false;
    }

    if (this.Password !== this.ConfirmPassword) {
      promptAction.showToast({ message: $r("app.string.newPasswordMismatch") });
      return false;
    }

    return true;
  }

  build() {
    Column({ space: 10 }) {
      TextInput({ placeholder: $r("app.string.forgetUserName") })
        .type(InputType.USER_NAME)
        .width('100%')
        .onChange(value => this.UserName = value)

      Row() {
        TextInput({ placeholder: $r("app.string.forgetPhone") })
          .type(InputType.PhoneNumber)
          .layoutWeight(1)
          .onChange(value => this.PhoneNumber = value)

        Button(this.countdown > 0 ? `${this.countdown}秒后重试` : $r("app.string.SendVerificationCode"))
          .width(100)
          .flexShrink(0)
          .enabled(this.countdown === 0)
          .fontColor($r("app.color.write"))
          .backgroundColor($r("app.color.starBlue"))
          .onClick(() => {
            this.startCountdown();
            // TODO: 实际发送验证码逻辑
            console.log("发送验证码到:", this.PhoneNumber);
          })
      }
      .width('100%')

      TextInput({ placeholder: $r("app.string.inputVerificationCode") })
        .type(InputType.Number)
        .width('100%')
        .onChange(value => this.VerificationCode = value)

      TextInput({ placeholder: $r("app.string.newPassword") })
        .type(InputType.Password)
        .width('100%')
        .onChange(value => this.Password = value)

      TextInput({ placeholder: $r("app.string.confirmNewPassword") })
        .type(InputType.Password)
        .width('100%')
        .onChange(value => this.ConfirmPassword = value)

      Button($r("app.string.confirmChange"))
        .width('100%')
        .fontColor($r("app.color.write"))
        .backgroundColor($r("app.color.starBlue"))
        .onClick(async () => {
          await this.modifyPassword();
        })
    }
    .width('100%')
    .padding({ left: 30, top: 100, right: 50 })
  }

  aboutToDisappear() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
  }
}