// 修正后的综合实现版
import picker from '@ohos.file.picker';
import camera from '@ohos.multimedia.camera';
import image from '@ohos.multimedia.image';
import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct EnhancedAvatarComponent {
  // 状态管理
  @State avatarUri: string = 'resources/base/media/avatar_default.png';
  @State isLoading: boolean = false;
  @State isPressed: boolean = false;
  @State showSourceSelector: boolean = false;

  // 上下文获取
  private context = getContext() as common.UIAbilityContext;

  // 生命周期：加载保存的头像
  aboutToAppear() {
    this.loadAvatarPath();
  }

  build() {
    // 唯一根节点容器
    Stack() {
      // 主内容容器
      Column() {
        // 头像显示区域
        Stack() {
          Image(this.isLoading ? '' : this.avatarUri)
            .width(150)
            .height(150)
            .borderRadius(75)
            .backgroundColor(Color.Gray)
            .opacity(this.isPressed ? 0.7 : 1)
            .clip(new Circle({ width: 150, height: 150 }))
            .onClick(() => this.showSourceSelector = true)
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.isPressed = true;
              } else if (event.type === TouchType.Up) {
                this.isPressed = false;
              }
            })

          if (this.isLoading) {
            LoadingProgress()
              .width(50)
              .height(50)
              .position({ x: '50%', y: '50%' })
          }
        }
        .margin(20)

        // 操作提示
        Text('点击头像更换')
          .fontSize(16)
          .fontColor(Color.Gray)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)

      // 图片来源选择弹窗（保持在Stack内）
      if (this.showSourceSelector) {
        ActionSheet({
          title: '选择图片来源',
          cancel: () => this.showSourceSelector = false,
          gestures: [PanGesture({ direction: PanDirection.Down, distance: 5 })]
        }) {
          Button('从相册选择') {
            this.showSourceSelector = false;
            this.selectFromGallery();
          }.margin(10)

          Button('拍照') {
            this.showSourceSelector = false;
            this.takePhoto();
          }.margin(10)

          Button('取消')
            .onClick(() => this.showSourceSelector = false)
            .margin(10)
        }
        .onCancel(() => this.showSourceSelector = false)
        .position({ x: 0, y: 0 }) // 确保弹窗定位正确
      }
    }
    .width('100%')
    .height('100%')
  }

  // 其他方法保持不变...
}

  // 从相册选择
  private async selectFromGallery() {
    this.isLoading = true;
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      const result = await new picker.PhotoViewPicker().select(photoSelectOptions);
      if (result.photoUris.length > 0) {
        await this.handleNewImage(result.photoUris[0]);
      }
    } catch (err) {
      this.showError('选择图片失败');
    } finally {
      this.isLoading = false;
    }
  }

  // 拍照功能
  private async takePhoto() {
    this.isLoading = true;
    try {
      const cameraManager = await camera.getCameraManager(this.context);
      const cameras = cameraManager.getSupportedCameras();
      const cameraInput = cameraManager.createCameraInput(cameras[0]);

      const photoOutput = await cameraManager.createPhotoOutput();
      const session = await cameraManager.createCaptureSession();
      await session.beginConfig();
      await session.addInput(cameraInput);
      await session.addOutput(photoOutput);
      await session.commitConfig();
      await session.start();

      const photo = await photoOutput.capture();
      const fileUri = await this.savePhoto(photo);
      await this.handleNewImage(fileUri);

      await session.stop();
    } catch (err) {
      this.showError('拍照失败');
    } finally {
      this.isLoading = false;
    }
  }

  // 处理新图片
  private async handleNewImage(uri: string) {
    try {
      // 简单裁剪（示例：转为圆形）
      const imageSource = image.createImageSource(uri);
      const pixelMap = await imageSource.createPixelMap();
      this.avatarUri = pixelMap; // 实际需要转换为可显示URI

      // 持久化存储
      await this.saveAvatarPath(uri);
    } catch (err) {
      this.showError('图片处理失败');
    }
  }

  // 保存头像路径
  private async saveAvatarPath(uri: string) {
    try {
      const pref = await dataPreferences.getPreferences(this.context, 'user_prefs');
      await pref.put('avatarUri', uri);
      await pref.flush();
    } catch (err) {
      console.error('保存失败:', err);
    }
  }

  // 加载保存的头像
  private async loadAvatarPath() {
    try {
      const pref = await dataPreferences.getPreferences(this.context, 'user_prefs');
      const uri = await pref.get('avatarUri', '');
      if (uri) this.avatarUri = uri;
    } catch (err) {
      console.error('加载失败:', err);
    }
  }

  // 错误提示
  private showError(message: string) {
    promptAction.showToast({ message, duration: 2000 });
  }

  // 保存照片文件
  private async savePhoto(photo: camera.Photo) {
    // 实际需实现文件保存逻辑
    return 'file://temp/photo.jpg';
  }
}