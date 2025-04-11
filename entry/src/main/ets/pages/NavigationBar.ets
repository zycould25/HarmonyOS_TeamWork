
import {hilog} from  '@kit.PerformanceAnalysisKit'
import {frontPage} from '../component/TabsComponent'
import {HuaweiMapDemo} from '../component/Parking'
import {UserCenterPage} from '../component/UserCenter'
import { bundleManager } from '@kit.AbilityKit';


@Entry
@Component
@Preview
struct BottomTab {//底部导航栏
  @State message: string = '智能停车场管理系统 '; //目前还不知道这条语句有什么用，或许以后有大用？
  // @State appid:string = ""
  @State currentIndex: number = 0;//动态标识当前页
  private  tabsController: TabsController = new TabsController();

  @Builder
  tabBuilder(title: string, index: number, selectedImg: Resource, normalImg:Resource){//标签页构建
    Column(){
      Image(this.currentIndex === index ? selectedImg :normalImg)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(title)
        .margin({top: 4 })
        .fontSize(10)
        .fontColor(this.currentIndex === index ? $r("app.color.ChunMeiHong") : $r("app.color.SongShiLv"))
    }
    .justifyContent(FlexAlign.Center)//
    .height(52)
    .width('100%')
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }

  @Builder
  tabContentBuilder(text: string, index: number, selectedImg: Resource, normalImg:Resource){
    TabContent(){
      Row(){
        if (index == 0){
          frontPage()
        } else if(index == 1){
          HuaweiMapDemo()
        } else if(index ==2 ){
          UserCenterPage()
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .padding({left: 12, right: 12})
    .backgroundColor(Color.White)
    .tabBar(this.tabBuilder(text, index,selectedImg,normalImg))
  }

  build() {
    Tabs({
      barPosition:BarPosition.End,
      controller:this.tabsController //绑定当前控制器
  }){//调用三次tabContentBuilder,创建三个标签页
      this.tabContentBuilder("首页",
        0,$r('app.media.activeHome'),$r('app.media.home'))
      this.tabContentBuilder("停车",
        1,$r('app.media.activePark'),$r('app.media.park'))
      this.tabContentBuilder("我的",
        2,$r('app.media.activePeople'),$r('app.media.people'))
    }
    .width('100%')
    .backgroundColor('#F34F5')
    .barHeight(52)
    .barMode(BarMode.Fixed)//固定模式，标签栏等分屏幕宽度
    .onAnimationStart((index: number, targetIndex: number) =>{
      hilog.info(0x0000,'index',index.toString());
      this.currentIndex = targetIndex;
    })
  }
  // aboutToAppear(): void {
  //   let flag = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO;
  //   let bundleInfo = bundleManager.getBundleInfoForSelfSync(flag)
  //   let appId = bundleInfo.signatureInfo.appId;
  //   this.appid=appId
  //   console.log(appId)
  // }

}
