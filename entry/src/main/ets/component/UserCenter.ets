import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import router from '@ohos.router';

@Component
export struct UserCenterPage {
  @State private  fileName: string = "/UserInfo.json";
  build() {
    Button("登录").onClick(()=>{
        router.pushUrl({
          url:"pages/LogIn"
        })

    })
  }
  private createNewFile(info: string): number {
    // 判断参数都能允许为空
    if (info == null) {
      console.info("参数不能为空");
      return 0;
    }
    // 获取应用文件路径
    let context = getContext(this) as common.UIAbilityContext;
    let filesDir = context.filesDir;
    // 新建并打开文件
    let file = fileIo.openSync(filesDir.concat(this.fileName), fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE);
    // 将集合转换成json序列化对象存储到文件中
    let writeLen = fileIo.writeSync(file.fd, info);
    console.info("字符串长度: " + writeLen);
    // 从文件读取一段内容
    console.info(filesDir)
    // 关闭文件
    fileIo.closeSync(file);
    // 返回写入长度
    return writeLen;
  }
}