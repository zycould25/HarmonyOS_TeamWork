//这个类用来模拟摄像头捕捉到车牌号
export class Camera {
  licenseNumber: string = '';

  // 生成随机车牌号
  captureLicenseNumber(): void {
    const provinces = [
      '京', '津', '沪', '渝', '冀', '豫', '云', '辽', '黑',
      '湘', '皖', '鲁', '新', '苏', '浙', '赣', '鄂', '桂',
      '甘', '晋', '陕', '吉', '闽', '贵', '粤', '青', '藏',
      '川', '宁', '琼'
    ];

    // 发牌机关代号（改为数组形式）
    const agencyCodes = ['A','B','C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','W','X','Y','Z'];

    // 车牌后缀字符集（改为数组形式）
    const suffixChars = [
      'A','B','C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','W','X','Y','Z',
      '0','1','2','3','4','5','6','7','8','9'
    ];

    // 随机生成组件
    const province = provinces[Math.floor(Math.random() * provinces.length)];
    const agencyCode = agencyCodes[Math.floor(Math.random() * agencyCodes.length)];

    let suffix = '';
    for (let i = 0; i < 5; i++) {
      suffix += suffixChars[Math.floor(Math.random() * suffixChars.length)];
    }

    this.licenseNumber = province + agencyCode + suffix;
  }

  getLicenseInfo(): string {
    return this.licenseNumber || '请先调用 captureLicenseNumber() 采集车牌';
  }
}
// // 使用示例
// const camera = new Camera();
// camera.captureLicenseNumber();
// console.log('识别到车牌：' + camera.getLicenseInfo());  // 输出示例：识别到车牌：粤B5H8K