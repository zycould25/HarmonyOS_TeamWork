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
  @State private dbManager: UserDBManager | null = null;

  async aboutToAppear() {
    this.dbManager = await UserDBManager.getInstance();
  }

  build() {
    Column({ space: 15 }) {
      Text($r("app.string.registerTitle"))
        .fontSize(24)

      TextInput({ placeholder: $r("app.string.registerUsername") })
        .onChange(value => this.username = value)

      TextInput({ placeholder: $r("app.string.registerPassword") })
        .type(InputType.Password)
        .onChange(value => this.password = value)

      TextInput({ placeholder: $r("app.string.confirmPassword") })
        .type(InputType.Password)
        .onChange(value => this.confirmPassword = value)

      Button($r("app.string.register"))
        .width('80%')
        .onClick(async () => {
          await this.handleRegistration();
        })

      Button($r("app.string.backToLogin"))
        .onClick(() => {
          router.back();
        })
    }
    .padding(20)
  }

  private async handleRegistration() {
    if (!this.validateInput()) return;

    try {
      // 检查用户是否存在
      if (!this.dbManager) { return;}
      const existingUser = await this.dbManager.getUserByName(this.username);
      if (existingUser) {
        promptAction.showToast({ message: $r("app.string.userExists") });
        return;
      }

      // 创建新用户
      const newUser = new User(
        this.username,
        this.password,
        "",  // 可扩展其他字段
        ""
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
}