// 在这个文件里面写停车的界面嗷
import { Banner } from '../model/Banner'


@Preview
@Component
export struct frontPage {
  // 轮播图数据（添加description字段）
  @State bannerList: Array<Banner> = [
    new Banner('pic0', $rawfile('promotion/treeHotel.jpg'), 'https://bilibili.com', '瑞典北部的树屋酒店'),
    new Banner('pic1', $rawfile('promotion/Longyearbyen.png'), 'https://bilibili.com', '人类最北的城市朗伊尔城'),
    new Banner('pic2', $rawfile('promotion/Aomori.png'), 'https://bilibili.com', '世界年降雪量第一的日本青森县'),
  ];

  @State currentIndex: number = 0  // 当前显示索引
  // Swiper控制器
  private swiperController: SwiperController = new SwiperController()

  build() {
    Column() { // 使用Column作为根容器
      // 轮播图区域
      Text(this.bannerList[this.currentIndex]?.description || '')
        .fontSize(16)
        .fontColor('#333')
        .margin({ top: 8, bottom: 1 })
        .width('90%')
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Swiper(this.swiperController) {
        ForEach(this.bannerList, (item: Banner) => {
          Column() {
            Image(item.imageSrc)
              .objectFit(ImageFit.Contain)
              .width('100%')
              .height(200)
              .padding({ left: 10, right: 10, top: 10 })
              .borderRadius(16)
          }
        }, (item: Banner) => item.id)
      }
      .margin({ bottom: 12 })
      .autoPlay(true)
      .interval(3000) // 3秒切换
      .loop(true)
      .indicator(new DotIndicator()
        .color('#55bb8a')
        .selectedColor('#f8d86a')
      )
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .height(240) // 总高度计算：200图片 + 20上下padding + 20指示器

      // 以下可以继续添加其他停车场界面组件
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}

@Component
struct todayToGo{
  build() {
    Column({space:10}){
      Row({space:8}){
        Button()
          .width(120)
          .flexShrink(0)
          .fontColor($r("app.color.write"))
          .backgroundColor($r("app.color.starBlue"))
          .onClick(()=>{

        })
      }.width('100%')
    }

  }
}