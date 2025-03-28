

@Observed
export default  class User{
    userName:string = "";
    passWord:string = "";
    phoneNumber:string = ""
    profile:string =""
    constructor(userName:string,passWord:string,phoneNumber:string,profile:string) {
      this.userName = userName;
      this.passWord = passWord;
      this.phoneNumber = phoneNumber;
      this.profile = profile;
    }

}