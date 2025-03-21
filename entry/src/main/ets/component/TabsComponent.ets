//在这个文件里面写首页的界面嗷
import router from '@ohos.router';


@Component
export struct frontPage  {
  @Prop title: string; // 传递参数

  build() {
    Column() {
      Text("this is font page")
        .width('100%')
        .padding(10)
      Button('Click me')
        .onClick(()=>{
          router.pushUrl({
            url:'component/WebView'
          })
        })


    }
  }
}

// import {BannerClass} from '../model/Banner';
//
//
//
//
// @Preview
// @Component
// struct Banner{
//   @State bannerList:Array<BannerClass> = [
//     new BannerClass('pic0',$r('app.media.test1'),'https//:bilibili.com'),
//     new BannerClass('pic1',$r('app.media.test2'),'https//:ilibili.com'),
//     new BannerClass('pic2',$r('app.media.test3'),'https//:bilibili.com'),
//   ];
//   build() {
//     Swiper(){
//       ForEach(this.bannerList,(item: BannerClass)=>{
//         Image(item.imageSrc)
//           .objectFit(ImageFit.Contain)
//           .width('100%')
//           .padding({left:10,right:10,top:10})
//           .borderRadius(16)
//       },(item:BannerClass)=>item.id)
//     }
//     .autoPlay(true)
//     .loop(true)
//     .indicator(
//       new DotIndicator()
//         .color('#55bb8a')
//         .selectedColor('#f8d86a')
//     )
//   }
// }
//
//
//
// @Preview
// @Component
// struct TutorialItem{
//   private title:string = "介绍"
//   private brief:string ="hhhh"
//   build() {
//
//
//   }
// }