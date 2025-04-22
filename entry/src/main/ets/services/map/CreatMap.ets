import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';

@Component
export struct HuaweiMapDemo {
  private TAG = "HuaweiMapDemo";
  private mapOptions?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;

  private currentTypeIndex: number = 0;  // 当前地图类型索引
  private mapTypes: mapCommon.MapType[] = [
    mapCommon.MapType.STANDARD,
    mapCommon.MapType.TERRAIN,
    mapCommon.MapType.NONE
  ];

  aboutToAppear(): void {
    this.mapOptions = {
      position: {
        target: {
          latitude: 29.453167,
          longitude: 106.532072
        },
        zoom: 10
      },
      mapType: this.mapTypes[this.currentTypeIndex],
      myLocationControlsEnabled: true,
      dayNightMode: mapCommon.DayNightMode.AUTO
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapEventManager = mapController.getEventManager();
        this.mapEventManager.on("mapLoad", () => {
          console.info(this.TAG, `on-mapLoad`);
        });
      }
    };
  }

  changeMapType(): void {
    this.currentTypeIndex = (this.currentTypeIndex + 1) % this.mapTypes.length;
    const nextType = this.mapTypes[this.currentTypeIndex];
    if (this.mapController) {
      this.mapController.setMapType(nextType);
      console.info(this.TAG, `地图类型切换为：${nextType}`);
    }
  }

  onPageShow(): void {
    if (this.mapController) {
      this.mapController.show();
    }
  }

  onPageHide(): void {
    if (this.mapController) {
      this.mapController.hide();
    }
  }

  build() {
    Stack() {
      // 地图组件
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.callback })
        .width('100%')
        .height('100%');

      // 使用Stack配合Align实现定位按钮
      Column() {
        Button("切换地图类型")
          .onClick(() => this.changeMapType())
          .width(200)
          .height(50)
      }
      .align(Alignment.BottomEnd)
      .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
  }
}
