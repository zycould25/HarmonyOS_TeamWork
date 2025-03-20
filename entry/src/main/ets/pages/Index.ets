

@Entry
@Component
@Preview
struct Index {
  @State message: string = '智能停车场管理系统 ';
  build() {
    Column(){
      Tabs({barPosition:BarPosition.End}){
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
