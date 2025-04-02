// ParkingLot.ets
// 停车场数据类型定义
interface ParkingLot {
  id: string
  name: string
  distance: number // 单位：米
  price: number    // 单位：元/小时
  availableSpots: number
  totalSpots: number
  isOpen: boolean
}

// 安全的手动模拟数据
function generateMockData(): ParkingLot[] {
  return [
    {
      id: '1',
      name: '世纪广场停车场',
      distance: 450,
      price: 8,
      availableSpots: 23,
      totalSpots: 150,
      isOpen: true
    },
    {
      id: '2',
      name: '智慧大厦地下车库',
      distance: 780,
      price: 12,
      availableSpots: 5,
      totalSpots: 200,
      isOpen: true
    },
    {
      id: '3',
      name: '市民中心停车场',
      distance: 1200,
      price: 6,
      availableSpots: 0,
      totalSpots: 300,
      isOpen: false
    },
    {
      id: '4',
      name: '国际会展中心停车场',
      distance: 1500,
      price: 10,
      availableSpots: 15,
      totalSpots: 180,
      isOpen: true
    },
    {
      id: '5',
      name: '金融中心停车场',
      distance: 2000,
      price: 15,
      availableSpots: 8,
      totalSpots: 200,
      isOpen: true
    }
  ];
}

// 列表项组件
@Component
struct ParkingLotItem {
  @Prop item: ParkingLot

  build() {
    Column({ space: 8 }) {
      // 顶部信息行
      Row() {
        Text(this.item.name)
          .fontSize(18)
          .fontColor(Color.Black)
          .flexGrow(1)

        Text(`${this.item.distance}m`)
          .fontSize(14)
          .fontColor('#666')
      }

      // 中部状态行
      Row() {
        Text(`¥${this.item.price}/小时`)
          .fontColor('#FF5722')

        Text(`剩余车位：${this.item.availableSpots}/${this.item.totalSpots}`)
          .margin({ left: 20 })
          .fontColor(this.item.availableSpots > 0 ? '#4CAF50' : '#F44336')
      }
      .margin({ top: 8 })

      // 底部状态栏
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

@Component
export struct GetNearParkingLot {
  @State parkingLots: ParkingLot[] = generateMockData()

  build() {
    Column() {
      // 列表标题
      Text("附近停车场")
        .fontSize(24)
        .fontColor(Color.Black)
        .margin({ top: 2, bottom: 20 })

      // 修改后的列表部分
      List({ space: 2 }) {
        ForEach(
          this.parkingLots,
          (item: ParkingLot) => {
            ListItem() {
              ParkingLotItem({ item: item })
            }
            .border({ width: 0.5, color: '#EEEEEE' })
          },
          (item: ParkingLot) => item.id
        )
      }
      .width('100%')
      .height('85%')
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
