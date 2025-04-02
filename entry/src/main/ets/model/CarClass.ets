export class CarClass {
  owner: string; // 车主人
  licenseNumber: string; // 车牌号
  carModel: string; // 车型
  parkTime: number; // 停车开始时间（时间戳）
  leftTime: number; // 开走时间（时间戳）
  charge: number; // 停车费用
  ratePerHour: number; // 停车单价（元/小时）

  constructor(
    licenseNumber: string,
    carModel: string,
    parkTime: number,
    leftTime?: number,
    owner: string = "未知车主",
    ratePerHour: number = 5 // 默认 5 元/小时
  ) {
    if (parkTime <= 0) {
      throw new Error("停车时间必须是有效的时间戳");
    }

    this.licenseNumber = licenseNumber;
    this.carModel = carModel;
    this.parkTime = parkTime;
    this.leftTime = leftTime && leftTime >= parkTime ? leftTime : 0;
    this.owner = owner;
    this.ratePerHour = ratePerHour;
    this.charge = 0;
  }

  // 计算停车时长（单位：分钟）
  getDuration(): number {
    if (this.leftTime > this.parkTime) {
      return Math.ceil((this.leftTime - this.parkTime) / 60000); // 向上取整（以分钟计算）
    }
    return 0;
  }

  // 计算停车费用（按小时计费，向上取整）
  calculateCharge(): number {
    const durationInHours = Math.ceil(this.getDuration() / 60); // 计算小时数（向上取整）
    this.charge = durationInHours * this.ratePerHour;
    return this.charge;
  }

  // 车辆离开停车场（更新 leftTime 并计算收费）
  leaveParking(leftTime: number): void {
    if (leftTime <= this.parkTime) {
      throw new Error("离开时间必须晚于停车时间");
    }
    this.leftTime = leftTime;
    this.calculateCharge();
  }
}
