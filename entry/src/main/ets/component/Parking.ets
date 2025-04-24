import { HuaweiMapDemo } from '../services/map/CreatMap'
import display from '@ohos.display';
import { http } from '@kit.NetworkKit'
import promptAction from '@ohos.promptAction'

// 停车场数据类型定义
interface ParkingLot {
  id: number
  name: string
  location: number
  price: number
  availableSpots: number
  totalSpots: number
  isOpen: boolean
}

@Component
export struct Parking{
  @State cardPosition: number = 0.4; // 默认显示40%
  @State startY: number = 0;
  @State parkingLots: ParkingLot[] = [] // 停车场数据
  @State isLoading: boolean = true // 加载状态
  private minCardHeight: number = 0.15; // 调整最小高度，确保搜索框完全可见
  private maxCardHeight: number = 0.9; // 最大高度，几乎全屏

  aboutToAppear() {
    this.fetchParkingLots()
  }

  // 获取停车场数据
  fetchParkingLots(): void {
    this.isLoading = true
    const httpRequest = http.createHttp()
    httpRequest.request(
      "http://8.155.47.127:8080/api/parking/list",
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        connectTimeout: 5000,
        readTimeout: 10000
      },
      (error: Error, data: http.HttpResponse) => {
        httpRequest.destroy()
        this.isLoading = false
        if (!error && data.responseCode === 200) {
          let result: ParkingLot[] = []
          if (typeof data.result === 'string') {
            try {
              result = JSON.parse(data.result) as ParkingLot[]
            } catch (e) {
              promptAction.showToast({ message: '解析数据失败' })
              return
            }
          } else {
            result = data.result as ParkingLot[]
          }

          // 按距离排序，距离最近的排在前面
          result.sort((a, b) => a.location - b.location)

          this.parkingLots = result
          console.info(`获取到${result.length}个停车场数据，已按距离排序`)
        } else {
          promptAction.showToast({ message: error?.message || '请求失败' })
        }
      }
    )
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      HuaweiMapDemo()

      Column() {
        // 滑动指示条
        Row() {
          Column()
            .width(40)
            .height(4)
            .backgroundColor('#DDDDDD')
            .borderRadius(2)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 10, bottom: 6 })

        // Search box
        Row() {
          Image($r('app.media.search'))
            .width(24)
            .height(24)
            .margin({ left: 12 })

          TextInput({ placeholder: '搜索停车场' })
            .placeholderFont({ size: 16 })
            .padding({ left: 8 })
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .height(40)
        }
        .width('90%')
        .height(50)
        .borderRadius(25)
        .backgroundColor('#F5F5F5')
        .margin({ top: 10, bottom: 16 })

        // Location recommendations
        Column() {
          Row() {
            Text('附近停车场')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)

            if (!this.isLoading && this.parkingLots.length > 0) {
              Text(`(按距离排序)`)
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 4 })
            }
          }
          .alignSelf(ItemAlign.Start)
          .margin({ left: 16, top: 8, bottom: 16 })

          if (this.isLoading) {
            Row() {
              LoadingProgress()
                .width(24)
                .height(24)
              Text('正在加载停车场数据...')
                .fontSize(14)
                .margin({ left: 8 })
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .padding(20)
          } else if (this.parkingLots.length === 0) {
            Text('暂无停车场数据')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 20 })
          } else {
            List() {
              ForEach(this.parkingLots, (item: ParkingLot) => {
                ListItem() {
                  this.buildParkingItem(item.name, `距离您${item.location}米`, `¥${item.price}/小时`, item.availableSpots, item.totalSpots, item.isOpen)
                }
              }, (item: ParkingLot) => item.id.toString())
            }
            .width('100%')
            .layoutWeight(1)
          }
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height(`${this.cardPosition * 100}%`)
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 24, topRight: 24 })
      .animation({
        duration: 200,
        curve: Curve.Ease
      })
      .gesture(
        PanGesture()
          .onActionStart(() => {
            // 记录初始位置，但不需要记录具体值，因为我们使用deltaY
          })
          .onActionUpdate((event: GestureEvent) => {
            // 使用offsetY获取垂直移动的距离
            let deltaY = event.offsetY;
            // 计算新的位置比例
            let newPosition = this.cardPosition - deltaY / this.getScreenHeight();

            // 限制在最小和最大高度之间
            if (newPosition >= this.minCardHeight && newPosition <= this.maxCardHeight) {
              this.cardPosition = newPosition;
            }
          })
          .onActionEnd(() => {
            // 根据当前位置决定是展开还是收起
            if (this.cardPosition < 0.25) {
              this.cardPosition = this.minCardHeight; // 收起，只显示搜索框
            } else if (this.cardPosition > 0.6) {
              this.cardPosition = this.maxCardHeight; // 展开到最大
            } else {
              this.cardPosition = 0.4; // 默认位置
            }
          })
      )
    }
    .width('100%')
    .height('100%')
  }

  private getScreenHeight(): number {
    let screenHeight = 1000; // 默认值
    try {
      const defaultDisplay = display.getDefaultDisplaySync();
      screenHeight = defaultDisplay.height;
    } catch (error) {
      console.error('Failed to get screen height: ' + JSON.stringify(error));
    }
    return screenHeight;
  }

  @Builder
  private buildParkingItem(name: string, distance: string, price: string, availableSpots: number, totalSpots: number, isOpen: boolean) {
    Row() {
      Column() {
        Text(name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(distance)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 4 })
        Row() {
          Text(`剩余车位：${availableSpots}/${totalSpots}`)
            .fontSize(14)
            .fontColor(availableSpots > 0 ? '#4CAF50' : '#F44336')
            .margin({ top: 4 })

          if (isOpen) {
            Text('营业中')
              .fontSize(12)
              .fontColor('#4CAF50')
              .border({ width: 1, color: '#4CAF50' })
              .borderRadius(4)
              .padding(2)
              .margin({ left: 8 })
          } else {
            Text('已关闭')
              .fontSize(12)
              .fontColor('#9E9E9E')
              .border({ width: 1, color: '#9E9E9E' })
              .borderRadius(4)
              .padding(2)
              .margin({ left: 8 })
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(price)
        .fontSize(16)
        .fontColor('#FF6B00')
    }
    .width('90%')
    .padding(16)
    .backgroundColor('#F8F8F8')
    .borderRadius(12)
    .margin({ bottom: 12 })
  }
}
