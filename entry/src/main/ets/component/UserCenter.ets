import User from '../model/Users'
import { router } from '@kit.ArkUI';

// 定义导航按钮参数接口
interface NavigationButtonParams {
  icon: Resource;   // 图标资源（资源格式）
  title: string;    // 按钮标题文本
}

@Component
@Preview
export struct UserCenterPage {
  // 双向绑定登录状态（与AppStorage同步）
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  // 双向绑定当前用户数据（与AppStorage同步）
  @StorageLink('currentUser') currentUser: User | null = null;

  // 构建组件界面
  build() {
    // 使用垂直布局作为根容器
    Column({ space: 0 }) {
      // 条件渲染：根据登录状态显示不同内容
      if (this.isLoggedIn && this.currentUser) {
        // 已登录状态界面 =================================

        // 用户信息卡片容器（堆叠布局）
        Stack() {
          // 渐变背景层
          Column()
            .linearGradient({  // 线性渐变背景
              angle: 90,       // 渐变角度（垂直方向）
              colors: [        // 渐变颜色配置
                [$r("app.color.primary"), 0.0],   // 起始颜色（从主题主色）
                [$r("app.color.secondary"), 1.0]  // 结束颜色（到主题辅色）
              ]
            })
            .height(180)      // 背景高度
            .width('100%')    // 背景宽度

          // 用户信息卡片内容
          Column() {
            // 头像容器（堆叠布局）
            Stack() {
              // 用户头像显示
              Image(this.currentUser.profile || $r("app.media.profile")) // 优先使用用户头像，否则显示默认
                .width(96)          // 头像尺寸
                .aspectRatio(1)     // 保持1:1宽高比
                .borderRadius(48)   // 圆形裁剪（半径设为宽度一半）
                .border({ width: 2, color: Color.White }) // 白色边框
                .shadow({          // 添加阴影效果
                  radius: 8,
                  color: Color.Black,
                  offsetX: 2,
                  offsetY: 2
                })

              // 条件渲染VIP徽章（积分超过1000显示）
              if ((this.currentUser.score ?? 0) > 10) {
                Image($r("app.media.vip"))  // VIP图标
                  .width(24)                 // 图标尺寸
                  .position({ x: '80%', y: '80%' }) // 定位在头像右下角
              }
            }
            .margin({ top: -48 })  // 上移使头像与背景重叠

            // 用户信息主体内容
            Column({ space: 8 }) { // 内部元素间距8
              // 用户名显示
              Text(this.currentUser.userName)
                .fontSize(24)                 // 字体大小
                .fontWeight(FontWeight.Bold)   // 加粗
                .fontColor($r("app.color.text_primary")) // 主题主文本色

              // 手机号行
              Row() {
                Image($r("app.media.ic_phone")) // 手机图标
                  .width(16)
                  .margin({ right: 4 })         // 右边距
                Text(this.currentUser.phoneNumber || '未绑定') // 显示手机号或提示
                  .fontSize(16)
                  .fontColor($r("app.color.text_secondary")) // 次级文本色
              }

              // 分隔线
              Divider()
                .strokeWidth(1)                            // 线宽
                .color($r("app.color.divider"))            // 颜色
                .margin({ top: 12, bottom: 12 })           // 上下边距

              // 积分展示区域
              Row() {
                Image($r("app.media.ic_diamond")) // 钻石图标
                  .width(24)
                  .margin({ right: 8 })           // 右侧间距
                Column() {                        // 垂直排列文本
                  Text('会员积分')
                    .fontSize(14)                 // 标题字体大小
                    .fontColor($r("app.color.text_secondary"))
                  Text(`${this.currentUser.score ?? 0}`) // 显示积分值
                    .fontSize(28)                 // 大号字体
                    .fontWeight(FontWeight.Medium) // 中等加粗
                }
              }
            }
            .padding(16)  // 内边距
          }
          .width('90%')   // 卡片宽度
          .backgroundColor(Color.White)  // 白色背景
          .borderRadius(16)              // 圆角
          .shadow({                     // 卡片阴影
            radius: 16,
            color: '#20000000',          // 带透明度的黑色
            offsetX: 0,
            offsetY: 4
          })
        }
        .height(280)        // 整体高度
        .margin({ bottom: 24 }) // 底部外边距

        // 功能按钮区域 ================================
        Column() {
          // 使用自定义方法构建导航按钮
          this.BuildNavigationButton({
            icon: $r("app.media.ic_edit"),
            title: '编辑资料'
          })
          this.BuildNavigationButton({
            icon: $r("app.media.ic_security"),
            title: '账户安全'
          })
          this.BuildNavigationButton({
            icon: $r("app.media.ic_gift"),
            title: '积分兑换'
          })
        }
        .width('100%')    // 充满父容器
        .padding(12)       // 内边距

        // 退出登录按钮
        Button('退出登录', { type: ButtonType.Capsule }) // 胶囊形状按钮
          .width('60%')     // 相对宽度
          .height(40)       // 固定高度
          .backgroundColor($r("app.color.primary")) // 主题主色
          .margin({ top: 24 })  // 顶部边距
          .onClick(() => {       // 点击事件
            // 更新全局登录状态
            AppStorage.setOrCreate('isLoggedIn', false)
            AppStorage.setOrCreate('currentUser', null)
            // 跳转至登录页
            router.pushUrl({ url: 'pages/LogIn' })
          })
      } else {
        // 未登录状态界面 ===============================
        Column() {
          // 登录插画
          Image($r("app.media.login_illustration"))
            .width(200)            // 固定宽度
            .margin({ bottom: 40 })// 下边距

          // 登录提示文本
          Text($r("app.string.login_prompt"))
            .fontSize(18)          // 字体大小
            .margin({ bottom: 30 }) // 下边距

          // 登录按钮
          Button($r("app.string.login_now"), { type: ButtonType.Capsule })
            .width(240)             // 固定宽度
            .height(45)            // 固定高度
            .backgroundColor($r("app.color.primary")) // 主题色
            .onClick(() => {        // 点击跳转登录页
              router.pushUrl({ url: 'pages/LogIn' })
            })
        }
        .height('100%')             // 充满容器高度
        .justifyContent(FlexAlign.Center) // 垂直居中
      }
    }
    // 根容器样式
    .width('100%')          // 全屏宽度
    .height('100%')         // 全屏高度
    .backgroundColor($r("app.color.background")) // 主题背景色
    .backdropBlur(10)       // 背景模糊效果（10像素）
  }

  // 自定义导航按钮构建器
  @Builder
  private BuildNavigationButton(params: NavigationButtonParams) {
    Button() {
      // 水平排列图标和文本
      Row() {
        Image(params.icon)  // 显示图标
          .width(24)        // 图标尺寸
          .margin({ right: 12 }) // 右侧间距
        Text(params.title)  // 按钮标题
          .fontSize(16)     // 字体大小
      }
      .width('100%')        // 占满按钮宽度
      .justifyContent(FlexAlign.Start) // 左对齐
    }
    // 按钮样式
    .width('100%')          // 占满父容器宽度
    .height(56)             // 固定高度
    .backgroundColor(Color.White) // 白色背景
    .borderRadius(12)       // 圆角
    .margin({ bottom: 8 })  // 下边距
    .stateEffect(true)      // 启用按压状态效果
  }
}