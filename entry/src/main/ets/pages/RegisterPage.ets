import { User} from '../model/Users'

@Component
struct Register{
  @Prop registerUsername:String = "huaweiUser"
  @Prop registerPassword:String = "12345678"
  @State user:User("ggg","sss","sss")
  build() {

  }
}