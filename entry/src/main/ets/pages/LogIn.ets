import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import User from '../model/Users'
import { UserDBManager } from '../dataBase/localDB'

@Entry
@Component
struct LogIn {
  @State username: string = "";  // 使用string类型更规范
  @State password: string = "";

  @State private dbManager: UserDBManager | null = null;

  @State deleteUser:string = ""

  // 页面初始化时获取数据库实例
  async aboutToAppear() {
    try {
      this.dbManager = await UserDBManager.getInstance();
      //promptAction.showToast({ message: "数据库就绪" });
    } catch (e) {
      //promptAction.showToast({ message: "数据库初始化失败" });
      console.error("Database init error:", e);
    }
  }

  build() {
    Column({ space: 10 }) {
      Image($r("app.media.profile"))
        .width(80)

      // 用户名输入
      TextInput({ placeholder: $r("app.string.loginTips") })
        .type(InputType.USER_NAME)
        .onChange(value => this.username = value)

      // 密码输入
      TextInput({ placeholder: $r("app.string.passwordTips") })
        .type(InputType.Password)  // 使用标准密码类型
        .onChange(value => this.password = value)

      // 登录按钮
      Button($r("app.string.login"))
        .width('100%')
        .fontColor($r("app.color.write"))
        .backgroundColor($r("app.color.starBlue"))
        .onClick(async () => {
          await this.handleLogin();
        })


        TextInput({placeholder:"测试用：删除用户"})
          .onChange(value=>this.deleteUser = value)
        Button("删除用户")
          .width('100%')
          .fontColor($r("app.color.write"))
          .backgroundColor($r("app.color.starBlue"))
          .onClick(()=>{
          if (!this.dbManager) {
            promptAction.showToast({message:"数据库为空"})
            return;}
          this.dbManager.deleteUser(this.deleteUser);
        })


      // 辅助功能行
      Row({ space: 10 }) {
        Text($r("app.string.ForgetPassword"))
          .onClick(() => this.showPasswordReset())

        Text('|')

        Text($r("app.string.GoToRegister"))
          .onClick(() => {
            router.pushUrl({ url: 'pages/RegisterPage' });
          })
      }
    }
    .width('100%')
    .padding({ left: 30, top: 100, right: 50 })
  }

  // 处理登录逻辑
  private async handleLogin() {
    if (!this.validateInput()) return;

    try {
      // 从数据库查询用户
      if (!this.dbManager) {
        return;
      }
      const user = await this.dbManager.getUserByName(this.username);

      if (!user) {
        promptAction.showToast({ message: $r("app.string.userNotFound") });
        return;
      }

      // 验证密码
      if (user.passWord === this.password) {
        await this.redirectToMainPage();
      } else {
        promptAction.showToast({ message: $r("app.string.wrongPassword") });
      }
    } catch (e) {
      console.error("Login failed:", e);
      promptAction.showToast({ message: $r("app.string.loginFailed") });
    }
  }

  // 输入验证
  private validateInput(): boolean {
    if (!this.username.trim()) {
      promptAction.showToast({ message: $r("app.string.emptyUsername") });
      return false;
    }

    if (!this.password.trim()) {
      promptAction.showToast({ message: $r("app.string.emptyPassword") });
      return false;
    }

    return true;
  }

  // 跳转到主页面
  private async redirectToMainPage() {
    try {
      await router.pushUrl({ url: 'pages/NavigationBar' });
    } catch (e) {
      console.error("Navigation failed:", e);
      promptAction.showToast({ message: $r("app.string.navigationError") });
    }
  }

  // 显示密码重置提示
  private showPasswordReset() {
    promptAction.showToast({ message: $r("app.string.resetPasswordHint") });
  }
}