import User from '../model/Users'
import { router } from '@kit.ArkUI';

interface NavigationButtonParams {
  icon: Resource;
  title: string;
}
@Component
@Preview
export struct UserCenterPage {
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('currentUser') currentUser: User | null = null;

  build() {
    Column({ space: 0 }) {
      if (this.isLoggedIn && this.currentUser) {
        // 登录状态显示的内容
        Stack() {
          // 渐变背景
          Column()
            .linearGradient({
              angle: 90,
              colors: [
                [$r("app.color.primary"), 0.0],
                [$r("app.color.secondary"), 1.0]
              ]
            })
            .height(180)
            .width('100%')

          // 用户信息卡片
          Column() {
            // 头像容器
            Stack() {
              Image(this.currentUser.profile || $r("app.media.profile"))
                .width(96)
                .aspectRatio(1)
                .borderRadius(48)
                .border({ width: 2, color: Color.White })
                .shadow({ radius: 8, color: Color.Black, offsetX: 2, offsetY: 2 })

              // 会员徽章
              if ((this.currentUser.score ?? 0) > 1000) {
                Image($r("app.media.vip_badge"))
                  .width(24)
                  .position({ x: '80%', y: '80%' })
              }
            }
            .margin({ top: -48 })

            // 用户信息主体
            Column({ space: 8 }) {
              Text(this.currentUser.userName)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor($r("app.color.text_primary"))

              Row() {
                Image($r("app.media.ic_phone"))
                  .width(16)
                  .margin({ right: 4 })
                Text(this.currentUser.phoneNumber || '未绑定')
                  .fontSize(16)
                  .fontColor($r("app.color.text_secondary"))
              }

              Divider()
                .strokeWidth(1)
                .color($r("app.color.divider"))
                .margin({ top: 12, bottom: 12 })

              // 积分展示
              Row() {
                Image($r("app.media.ic_diamond"))
                  .width(24)
                  .margin({ right: 8 })
                Column() {
                  Text('会员积分')
                    .fontSize(14)
                    .fontColor($r("app.color.text_secondary"))
                  Text(`${this.currentUser.score ?? 0}`)
                    .fontSize(28)
                    .fontWeight(FontWeight.Medium)
                }
              }
            }
            .padding(16)
          }
          .width('90%')
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({ radius: 16, color: '#20000000', offsetX: 0, offsetY: 4 })
        }
        .height(280)
        .margin({ bottom: 24 })

        // 功能操作区
        Column() {
          this.BuildNavigationButton({ icon: $r("app.media.ic_edit"), title: '编辑资料' })
          this.BuildNavigationButton({ icon: $r("app.media.ic_security"), title: '账户安全' })
          this.BuildNavigationButton({ icon: $r("app.media.ic_gift"), title: '积分兑换' })
        }
        .width('100%')
        .padding(12)

        // 退出登录按钮
        Button('退出登录', { type: ButtonType.Capsule })
          .width('60%')
          .height(40)
          .backgroundColor($r("app.color.primary"))
          .margin({ top: 24 })
          .onClick(() => {
            AppStorage.setOrCreate('isLoggedIn', false)
            AppStorage.setOrCreate('currentUser', null)
            router.pushUrl({ url: 'pages/LogIn' })
          })
      } else {
        // 未登录状态显示登录按钮
        Column() {
          Image($r("app.media.login_illustration"))
            .width(200)
            .margin({ bottom: 40 })

          Text($r("app.string.login_prompt"))
            .fontSize(18)
            .margin({ bottom: 30 })

          Button($r("app.string.login_now"), { type: ButtonType.Capsule })
            .width(240)
            .height(45)
            .backgroundColor($r("app.color.primary"))
            .onClick(() => {
              router.pushUrl({ url: 'pages/LogIn' })
            })
        }
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r("app.color.background"))
    .backdropBlur(10)
  }

  @Builder
  private BuildNavigationButton(params: NavigationButtonParams) {
    Button() {
      Row() {
        Image(params.icon)
          .width(24)
          .margin({ right: 12 })
        Text(params.title)
          .fontSize(16)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height(56)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .stateEffect(true)
  }
}