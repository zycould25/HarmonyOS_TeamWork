import { promptAction } from "@kit.ArkUI";

@Preview
@Component
export struct parkingPage {
  @Prop title: string;
  @State searchText: string = "";
  @State isRefreshing: boolean = false;

  @State vehicleLocation: VehicleLocation | null = {
    plateNumber: "沪A·12345",
    location: "上海中心大厦B2层A区012车位",
    timestamp: "2025-04-1 14:30:00"
  }; // 模拟数据


  build() {
    Column() {
      Row() {
        TextInput({ placeholder: "寻找停车场" })
          .placeholderColor("#999999")
          .placeholderFont({ size: 16 })
          .height(40)
          .flexGrow(1)
          .borderColor(Color.Transparent) // 隐藏输入框原生边框
          .margin({ left: 5, right: 8 }) // 左侧留出间距
          .onSubmit(() => {
            this.handleSearch();
          })
          .onChange(value => {
            this.searchText = value;
          })
        Image($r("app.media.ic_public_search"))
          .width(20)
          .height(20)
          .margin({ right: 8 }) // 左侧留出间距
          .onClick(()=>{
            this.handleSearch()
          })

      }
      .width('100%')
      .margin({ top: 10,right: 5 })
      CarLocationComponent({ locationData: this.vehicleLocation })
    }
    .width('100%')
    .height('100%')
    .padding(10)
    .backgroundColor(Color.White)
  }

  async handleSearch() {
    if (this.searchText.trim()) {

      console.log("开始搜索停车场：", this.searchText);
      //TODO
      // 1. 调用搜索API
      // 2. 过滤本地数据
      // 3. 跳转到搜索结果页
    } else {
      console.log("null input");
      promptAction.showToast({ message: '搜索内容不能为空' });
    }
  }
}


// 车辆位置数据类型定义
interface VehicleLocation {
  plateNumber: string;  // 车牌号
  location: string;    // 具体位置
  timestamp: string;   // 更新时间
}

@Component
export struct CarLocationComponent {
  @Prop locationData: VehicleLocation | null; // 接收位置数据
  @State isRefreshing: boolean = false;
  build() {
    Column() {
      Text("我的车辆位置")
        .fontSize(18)
        .fontColor("#333333")
        .margin({ bottom: 8 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Column() {
        if (this.locationData) {
          // 有数据时的显示
          Text(this.locationData.plateNumber)
            .fontSize(16)
            .fontColor("#222222")
            .margin({ bottom: 6 })

          Text(this.locationData.location)
            .fontSize(14)
            .fontColor("#666666")
            .margin({ bottom: 4 })

          Text(`最后更新：${this.locationData.timestamp}`)
            .fontSize(12)
            .fontColor("#999999")
            .onClick(() => {
              if (!this.isRefreshing) {
                this.isRefreshing = true;
                //TODO 执行数据刷新逻辑
                setTimeout(() => {
                  this.isRefreshing = false;
                }, 1000);
              }
            })
        } else {
          Text("等待获取车辆位置...")
            .fontSize(16)
            .fontColor("#AAAAAA")
            .margin(12)
        }
      }

      .width('100%')
      .padding(12)
      .backgroundColor("#f8f8f8")
      .borderRadius(12)
      .border({
        width: 1,
        color: "#eeeeee",
        radius: 12
      })
      Button("到这里去")
        .width('100%')
        .fontColor($r("app.color.write"))
        .backgroundColor($r("app.color.starBlue"))
        .onClick(async () => {
          //
        })

    }
    .width('100%')
    .margin({ top: 20 })
  }
}

