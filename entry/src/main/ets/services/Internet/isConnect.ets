//此文件夹包含一个判断是否联网函数

import { connection } from '@kit.NetworkKit';
import {hilog} from '@kit.PerformanceAnalysisKit'

const TAG = '[isConnect]'

export function  judgeHasNet(): boolean {
  try {
    let netHandle = connection.getDefaultNetSync();
    if (!netHandle || netHandle.netId === 0) {
      return false;
    }
    let netCapability = connection.getNetCapabilitiesSync(netHandle);
    let cap = netCapability.networkCap || [];
    if (cap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
      return true;
    } else {
      return false;
    }
  } catch (err) {
    hilog.error(0x0000, TAG, `JudgeHasNet failed, code: ${err.code}, message: ${err.message}`);
  }
  return false;
}