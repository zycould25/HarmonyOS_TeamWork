// 在这个文件里面写停车的界面嗷
import { Banner } from '../model/Banner'
import {GetNearParkingLot} from './getNearParkingLot'

// 地点数据类型
interface Place {
  id: number
  name: string
  description: string
  image: Resource
}



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
  @State cardHeight: number = 0.6  // 卡片高度占比，默认显示60%
  private minCardHeight: number = 0.4  // 最小高度
  private maxCardHeight: number = 0.8  // 最大高度
  // Swiper控制器
  private swiperController: SwiperController = new SwiperController()

  build() {
    Column() { // 使用Column作为根容器
      Scroll() {
        Column() {
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

          GetNearParkingLot()
          .width('100%')
          .height(600) // 固定高度，内部元素通过比例缩放
          .margin({ bottom: 20 })

          // 预留底部空间
          Column()
            .height(20)
        }
        .width('100%')
      }
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}


@Component
struct todayToGo {
  @State isDialogVisible: boolean = false
  @State selectedPlace: Place | null = null

  // 模拟地点数据
  private places: Place[] = [
    {
      id: 1,
      name: '杭州西湖',
      description: '中国十大风景名胜之一，三面云山一面城的景观格局',
      image: $r("app.media.west_lake")
    },
    {
      id: 2,
      name: '敦煌莫高窟',
      description: '世界上现存规模最大、内容最丰富的佛教艺术圣地',
      image: $r("app.media.mogao_caves")
    }
  ]

  build() {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        Button("随机出发去一个地方")
          .width(120)
          .flexShrink(0)
          .fontColor($r("app.color.write"))
          .backgroundColor($r("app.color.starBlue"))
          .onClick(() => {
            // 随机选择地点
            const randomIndex = Math.floor(Math.random() * this.places.length)
            this.selectedPlace = this.places[randomIndex]
            this.isDialogVisible = true
          })
      }.width('100%')
      .justifyContent(FlexAlign.Center)

      // 弹窗层
      if (this.isDialogVisible) {
        Column() {
          Column({ space: 20 }) {
            // 图片
            Image(this.selectedPlace?.image)
              .height(200)
              .width('100%')
              .objectFit(ImageFit.Cover)
              .borderRadius({ topLeft: 16, topRight: 16 })
            // 文字内容
            Column({ space: 12 }) {
              Text(this.selectedPlace?.name)
                .fontSize(24)
                .fontColor(Color.Black)

              Text(this.selectedPlace?.description)
                .fontSize(16)
                .fontColor('#666666')
                .lineHeight(24)
            }
            .padding({ left: 20, right: 20 })
            // 关闭按钮
            Button('关闭')
              .width(120)
              .fontColor($r("app.color.write"))
              .backgroundColor($r("app.color.starBlue"))
              .onClick(() => this.isDialogVisible = false)
          }
          .width('80%')
          .backgroundColor($r("app.color.starBlue"))
          .borderRadius(16)
          .clip(true)
          .align(Alignment.Center) // 使用对齐方式代替绝对定位
          .margin({ left: 24, right: 24 }) // 添加边距防止贴边
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 }) // 使用坐标定位代替 Fixed
      }
    }
  }
}

