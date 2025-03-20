//在这个文件里面写用户中心的界面嗷

@Component
export struct UserCenterPage  {
  @Prop title: string; // 传递参数

  build() {
    Column() {
      Text("this is userCenter page")
        .width('100%')
        .padding(10)
    }
  }
}
