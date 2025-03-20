//在这个文件里面写停车的界面嗷

@Component
export struct parkingPage  {
  @Prop title: string; // 传递参数

  build() {
    Column() {
      Text("this is parking page")
        .width('100%')
        .padding(10)
    }
  }
}
