
@Entry
@Component
@Preview
struct LogIn{
  build() {
    Column({space:10}) {
      Image($r("app.media.profile"))
        .width(80)
      TextInput({
        placeholder: $r("app.string.loginTips")
      }).type(InputType.USER_NAME)
      TextInput({
        placeholder: $r("app.string.passwordTips")
      }).type(InputType.Password)
      Button('登录')
        .width('100%')
      Row({space:10}) {
        Text($r("app.string.ForgetPassword"))
        Text($r("app.string.GoToRegister"))
      }
    }
    .width('100%')
    .padding(50)
  }
}