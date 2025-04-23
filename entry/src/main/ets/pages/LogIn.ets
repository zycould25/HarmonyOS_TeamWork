import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';
import { UserDBManager } from '../dataBase/localDB'

import { HttpUtil } from '../net/http/Send';
import { http } from '@kit.NetworkKit';



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
      //华为账号一键登录
      Column({ space: 10 }) {

        Button($r('app.string.huaweiAccountLogIn'))
          .width('100%')
          .fontColor($r("app.color.write"))
          .backgroundColor($r("app.color.starBlue")) // 建议单独定义华为品牌色
          .onClick(() => {
            //TODO
          })
      }
      .width('100%')
      .margin({ top: 20 })

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
          .onClick(() => {
            router.pushUrl({url: 'pages/ForgetPassword' })
          })


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


  private async handleLogin() {
    if (!this.validateInput()) return;

    const loginPayload = JSON.stringify({
      "userName": this.username,
      "passWord": this.password,
    });

    HttpUtil(
      "http://8.155.47.127:8080/api/harmonyAddUser/login",
      http.RequestMethod.POST,
      loginPayload,
      async (success, result) => {
        if (success) {
          // 登录成功，保存状态和用户信息
          AppStorage.setOrCreate('isLoggedIn', true);
          AppStorage.setOrCreate('currentUser', result); // result 包含 id, userName, score 等
          await this.redirectToMainPage();
        } else {
          // 登录失败，提示用户
          promptAction.showToast({ message: result.message || $r("app.string.loginFailed") });
        }
      }
    );
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
      await router.pushUrl({ url: 'pages/BottomTab' });
    } catch (e) {
      console.error("Navigation failed:", e);
      promptAction.showToast({ message: $r("app.string.navigationError") });
    }
  }

}