//在这个文件里面写首页的界面嗷

@Component
export struct frontPage  {
  @Prop title: string; // 传递参数

  build() {
    Column() {
      Text("this is font page")
        .width('100%')
        .padding(10)
    }
  }
}
