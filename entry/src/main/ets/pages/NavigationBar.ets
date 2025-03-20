import router from '@ohos.router';

@Entry
@Component
@Preview
struct Home {
  @State message: string = '智能停车场管理系统 '; //目前还不知道这条语句有什么用，或许以后有大用？
  build() {
    Column(){
      Tabs({barPosition:BarPosition.End}){ //bars 的颜色采用互补色，视觉冲击力要好一些
        TabContent(){

        }.tabBar(SubTabBarStyle.of('首页')
          .labelStyle({
            unselectedColor:$r("app.color.SongShiLv"),
            selectedColor:$r("app.color.ChunMeiHong")
          })
          .indicator({
            color:$r("app.color.starBlue")
          })
        )

        TabContent(){
          //待添加内容
        }.tabBar(SubTabBarStyle.of('引导')
          .labelStyle({
            unselectedColor:$r("app.color.TealGreen"),
            selectedColor:$r("app.color.ZhangHuaHong")
          })
          .indicator({
            color:$r("app.color.starBlue")
          })
        )

        TabContent(){
            //待添加内容
        }.tabBar(SubTabBarStyle.of('我的')
          .labelStyle({
            unselectedColor:$r("app.color.BoHeLv"),
            selectedColor:$r("app.color.JieHuaZi")
          })
          .indicator({
            color:$r("app.color.starBlue")
          })
        )
      }

    }

  }
}
