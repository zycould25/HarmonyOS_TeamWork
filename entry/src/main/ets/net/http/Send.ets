import { http } from '@kit.NetworkKit';

interface ResponseData {
  id?: number;
  userName?: string;
  score?: number;
  message?: string;
}

export function HttpUtil(
  rul: string,
  method: http.RequestMethod,
  requestData: string,
  callback?: (success: boolean, result: ResponseData) => void
): void {
  const httpRequest = http.createHttp();

  httpRequest.on('headersReceive', (header) => {
    console.info('header:' + JSON.stringify(header));
  });

  httpRequest.request(rul, {
    method: method,
    header: {
      "Content-type": "application/json"
    },
    extraData: requestData,
    connectTimeout: 6000,
    readTimeout: 10000,
  }, (error: Error, data: http.HttpResponse) => {
    let result: ResponseData = {};

    if (!error && data.responseCode === 200) {
      if (typeof data.result === 'object') {
        result = data.result as ResponseData;
      } else {
        result = { message: String(data.result) };
      }
      callback?.(true, result);
    } else {
      result = { message: error?.message || "请求失败" };
      callback?.(false, result);
    }

    httpRequest.off('headersReceive');
    httpRequest.destroy();
  });
}
