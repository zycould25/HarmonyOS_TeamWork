import { router } from "@kit.ArkUI"

import User  from '../model/Users'

@Component
export struct UserCenterPage {
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false;
  @StorageLink('currentUser') currentUser: User | null = null;

  build() {
    Column({ space: 12 }) {
      if (this.isLoggedIn && this.currentUser) {
        // 用户信息展示
        Image($r("app.media.profile")) // 用户头像
          .width(80)
          .margin({ bottom: 16 })

        Text(this.currentUser.userName)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)

        Text(`手机号: ${this.currentUser.phoneNumber || '未绑定'}`)
          .fontSize(16)


        Button($r("app.string.logout"))
          .width('60%')
          .margin({ top: 30 })
          .onClick(() => {
            // 清除登录状态
            AppStorage.set('isLoggedIn', false);
            AppStorage.set('currentUser', null);
            router.back(); // 返回登录页或首页
          })
      } else {
        // 未登录状态显示登录按钮
        Button($r("app.string.login"))
          .width('60%')
          .onClick(() => {
            router.pushUrl({ url: 'pages/LogIn' });
          })
      }
    }
    .width('100%')
    .padding(20)
    .alignItems(HorizontalAlign.Center)
  }
}
