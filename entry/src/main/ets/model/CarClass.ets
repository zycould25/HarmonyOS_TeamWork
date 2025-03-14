

export class CarClass{
  licenseNumber: string = ""; //车牌号
  carModel:string = ""; //车型号
  parkTime:number = 0; //停车时的时间
  leftTIme:number = 0; //开走时的时间
  constructor(licenseNumber:string,carModel:string,parkTime:number,leftTime:number) {
    this.licenseNumber = licenseNumber;
    this.carModel = carModel;
    this.parkTime = parkTime;
    this.leftTIme = leftTime;
  }
}