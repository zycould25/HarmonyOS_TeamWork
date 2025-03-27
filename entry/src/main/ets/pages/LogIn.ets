
import router from '@ohos.router';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
@Preview
struct LogIn{
  @State username:String= "";
  @State password:String = "";
  @State registerUsername:String = "";
  @State registerPassword:String = ""
  build() {
    Column({space:10}) {
      Image($r("app.media.profile")) //用户的头像
        .width(80)

      TextInput({
        placeholder: $r("app.string.loginTips")
      }).type(InputType.USER_NAME) //提示用户登录
        .onChange(value=>{
          this.username = value;
        })

      TextInput({
        placeholder: $r("app.string.passwordTips")
      }).type(InputType.Password) //提示用户密码
        .onChange(value=>{
          this.password = value;
        })

      Button('登录')
        .width('100%')
        .fontColor($r("app.color.write"))
        .backgroundColor($r("app.color.starBlue"))
        .onClick(()=>{
          if(this.username == "chapaofan" && this.password== "111"){
              router.pushUrl({
                url:'pages/NavigationBar'  //这里的逻辑想的是用户输入完账号密码后直接点击登录就可以跳转至首页
              })
          } else {
            promptAction.showToast({
              message:$r("app.string.errorInput")
            })
          }


        })
      Row({space:10}) { //忘记密码和注册提示
        Text($r("app.string.ForgetPassword"))
          .onClick(()=>{

          })
        Text('|')
        Text($r("app.string.GoToRegister"))
          .onClick(()=>{
            router.pushUrl({
              url:'pages/RegisterPage'
            })
          })
      }
    }

    .width('100%') //100
    .padding({left:30,top:100,right:50}) //边距50
  }
}