

@Observed
export default  class User{
    userName:string = "";
    passWord:string = "";
    phoneNumber:string = ""
    score: number = 0;
    profile:string =""
    constructor(userName:string,passWord:string,phoneNumber:string,score:number,profile:string) {
      this.userName = userName;
      this.passWord = passWord;
      this.phoneNumber = phoneNumber;
      this.score = score;
      this.profile = profile;
    }
}