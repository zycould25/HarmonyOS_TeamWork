import router from '@ohos.router';

@Entry
@Component
@Preview
struct LogIn{
  build() {
    Column({space:10}) {
      Image($r("app.media.profile")) //用户的头像
        .width(80)

      TextInput({
        placeholder: $r("app.string.loginTips")
      }).type(InputType.USER_NAME) //提示用户登录

      TextInput({
        placeholder: $r("app.string.passwordTips")
      }).type(InputType.Password) //提示用户密码

      Button('登录')
        .width('100%')
        .fontColor($r("app.color.write"))
        .backgroundColor($r("app.color.starBlue"))
        .onClick(()=>{
          router.pushUrl({
            url:'pages/NavigationBar'  //这里的逻辑想的是用户输入完账号密码后直接点击登录就可以跳转至首页
          })

        })
      Row({space:10}) { //忘记密码和注册提示
        Text($r("app.string.ForgetPassword"))
          .onClick(()=>{
            //待实现忘记密码
          })
        Text('|')
        Text($r("app.string.GoToRegister"))
          .onClick(()=>{
            //待实现注册
          })
      }
    }

    .width('100%') //100
    .padding({left:30,top:100,right:50}) //边距50
  }
}