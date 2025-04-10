import {http} from '@kit.NetworkKit';


export function HttpUtil(rul:string, method:http.RequestMethod, requestData:string){
  const httpRequest = http.createHttp();//新建一个对象

  //监听头
  httpRequest.on('headersReceive',(header)=>{
    console.info('header:'+JSON.stringify(header))
  })


  httpRequest.request(rul,{
    method:http.RequestMethod.POST,
    header:{
      //前端请求后端所需要的数据格式
      "Content-type":"application/json"
    },
    extraData:requestData, //设置请求要传递给后端的数据
    connectTimeout:6000, //超时
    readTimeout:10000,

  },(error:Error,data:http.HttpResponse)=>{
    //没有内容则是代表了成功，否则就说明有问题
    if(!error){
      console.log(JSON.stringify(data))
      httpRequest.destroy()
    } else {
      httpRequest.off('headersReceive')
      console.log(JSON.stringify(error))
      httpRequest.destroy()
    }

  })

}
