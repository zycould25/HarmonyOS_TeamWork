

export class CarClass{
  licenseNumber: string = "";
  carModel:string = "";
  parkTime:number = 0;
  leftTIme:number = 0;
  constructor(licenseNumber:string,carModel:string,parkTime:number,leftTime:number) {
    this.licenseNumber = licenseNumber;
    this.carModel = carModel;
    this.parkTime = parkTime;
    this.leftTIme = leftTime;
  }
}