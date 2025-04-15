export class ParkingLot {
  id: number;                 // 停车场ID
  name: string;               // 停车场名称
  location: string;           // 停车场位置
  totalSpaces: number;        // 总车位数量
  availableSpaces: number;    // 可用车位数量
  hourlyRate: number;         // 每小时收费标准（元）
  openTime: string;           // 开放时间（格式：HH:MM）
  closeTime: string;          // 关闭时间（格式：HH:MM）
  isOpen: boolean;            // 是否开放
  contactPhone: string;       // 联系电话
  description: string;        // 描述信息

  constructor(
    name: string,
    location: string,
    totalSpaces: number,
    availableSpaces: number = totalSpaces,
    hourlyRate: number = 5,
    openTime: string = "00:00",
    closeTime: string = "23:59",
    isOpen: boolean = true,
    contactPhone: string = "",
    description: string = "",
    id: number = 0
  ) {
    if (totalSpaces < 0) {
      throw new Error("总车位数不能为负数");
    }
    
    if (availableSpaces > totalSpaces) {
      throw new Error("可用车位数不能超过总车位数");
    }

    this.id = id;
    this.name = name;
    this.location = location;
    this.totalSpaces = totalSpaces;
    this.availableSpaces = availableSpaces;
    this.hourlyRate = hourlyRate;
    this.openTime = openTime;
    this.closeTime = closeTime;
    this.isOpen = isOpen;
    this.contactPhone = contactPhone;
    this.description = description;
  }

  // 车辆进入停车场，可用车位减1
  carEnter(): boolean {
    if (this.availableSpaces > 0 && this.isOpen) {
      this.availableSpaces--;
      return true;
    }
    return false; // 没有可用车位或停车场已关闭
  }

  // 车辆离开停车场，可用车位加1
  carLeave(): boolean {
    if (this.availableSpaces < this.totalSpaces) {
      this.availableSpaces++;
      return true;
    }
    return false; // 异常情况：已达总车位数（不应该发生）
  }

  // 设置停车场开放状态
  setOpenStatus(isOpen: boolean): void {
    this.isOpen = isOpen;
  }

  // 更新收费标准
  updateHourlyRate(newRate: number): void {
    if (newRate >= 0) {
      this.hourlyRate = newRate;
    }
  }

  // 获取车位占用率
  getOccupancyRate(): number {
    return this.totalSpaces > 0 ? 
      ((this.totalSpaces - this.availableSpaces) / this.totalSpaces) * 100 : 0;
  }
} 