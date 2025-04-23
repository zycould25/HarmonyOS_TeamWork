// ParkingLot.ets
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

// 网络请求函数
function fetchParkingLots(callback: (success: boolean, data: ParkingLot[] | string) => void): void {
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
      if (!error && data.responseCode === 200) {
        let result: ParkingLot[] = []
        if (typeof data.result === 'string') {
          try {
            result = JSON.parse(data.result) as ParkingLot[]
          } catch (e) {
            callback(false, '解析数据失败')
            return
          }
        } else {
          result = data.result as ParkingLot[]
        }
        callback(true, result)
      } else {
        callback(false, error?.message || '请求失败')
      }
    }
  )
}

// 单项组件
@Component
struct ParkingLotItem {
  @Prop item: ParkingLot

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.item.name)
          .fontSize(18)
          .fontColor(Color.Black)
          .flexGrow(1)

        Text(`${this.item.location}m`)
          .fontSize(14)
          .fontColor('#666')
      }

      Row() {
        Text(`¥${this.item.price}/小时`)
          .fontColor('#FF5722')

        Text(`剩余车位：${this.item.availableSpots}/${this.item.totalSpots}`)
          .margin({ left: 20 })
          .fontColor(this.item.availableSpots > 0 ? '#4CAF50' : '#F44336')
      }
      .margin({ top: 8 })

      Row() {
        if (this.item.isOpen) {
          Text('营业中')
            .fontColor('#4CAF50')
            .border({ width: 1, color: '#4CAF50' })
            .padding(4)
        } else {
          Text('已关闭')
            .fontColor('#9E9E9E')
            .border({ width: 1, color: '#9E9E9E' })
            .padding(4)
        }
      }
      .margin({ top: 8 })
    }
    .padding(16)
    .backgroundColor(Color.White)
    .margin({ top: 8, bottom: 8, left: 12, right: 12 })
    .borderRadius(8)
    .shadow({
      radius: 8,
      color: '#20000000',
      offsetY: 2
    })
    .height(120)
  }
}

// 页面组件
@Component
export struct GetNearParkingLot {
  @State parkingLots: ParkingLot[] = []

  aboutToAppear() {
    fetchParkingLots((success, data) => {
      if (success) {
        this.parkingLots = data as ParkingLot[]
      } else {
        promptAction.showToast({ message: `获取数据失败：${data}` })
      }
    })
  }

  build() {
    Column() {
      Text("附近停车场")
        .fontSize(24)
        .fontColor(Color.Black)
        .margin({ top: 2, bottom: 16 })

      Scroll() {
        List({ space: 2 }) {
          ForEach(
            this.parkingLots,
            (item: ParkingLot) => {
              ListItem() {
                ParkingLotItem({ item: item })
              }
              .border({ width: 0.5, color: '#EEEEEE' })
            },
            (item: ParkingLot) => `${item.id}`
          )
        }
        .width('100%')
      }
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
