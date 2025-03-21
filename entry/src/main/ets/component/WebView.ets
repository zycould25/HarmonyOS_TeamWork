import webview from '@ohos.web.webview';



webview.once("webInited", () => {
  console.log("configCookieSync");
  webview.WebCookieManager.configCookieSync("192.168.56.186:8080/app", "a=b");
})

@Component
@Preview
@Entry
struct WebView{
  controller: webview.WebviewController = new webview.WebviewController();
  build() {
    Column(){
      Web({ src: '192.168.56.186:8080/app', controller: this.controller })
    }
  }
}