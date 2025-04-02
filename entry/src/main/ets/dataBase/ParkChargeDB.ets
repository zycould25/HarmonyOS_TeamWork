// ParkChargeDB.ts
// 导入ArkData的关系型数据库模块和UI提示模块
import { relationalStore } from '@kit.ArkData';
import { promptAction } from '@kit.ArkUI';
import { CarClass } from '../model/CarClass'; // 导入CarClass

/**
 * 停车收费账单数据库管理类（单例模式）
 * 封装账单数据的CRUD操作，支持以下功能：
 * - 数据库初始化及表结构管理
 * - 账单增删改查操作（支持按车牌号、日期等查询）
 */
export class ParkChargeDB {
  private static instance: ParkChargeDB;          // 单例实例
  private store: relationalStore.RdbStore = {} as relationalStore.RdbStore; // 数据库实例
  private config: relationalStore.StoreConfig = {  // 数据库配置
    name: "park_charge_db.db",     // 独立数据库文件
    securityLevel: relationalStore.SecurityLevel.S1
  };

  // 单例获取方法
  static async getInstance(): Promise<ParkChargeDB> {
    if (!ParkChargeDB.instance) {
      ParkChargeDB.instance = new ParkChargeDB();
      await ParkChargeDB.instance.initDB();
    }
    return ParkChargeDB.instance;
  }

  private constructor() {} // 私有构造函数确保单例

  /**
   * 初始化数据库（创建账单表）
   */
  private async initDB() {
    try {
      this.store = await relationalStore.getRdbStore(getContext(), this.config);

      // 创建停车账单表（主键为自增ID，日期作为普通字段）
      await this.store.executeSql(`
        CREATE TABLE IF NOT EXISTS parking_charges (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          licenseNumber TEXT NOT NULL,
          owner TEXT DEFAULT '未知车主',
          carModel TEXT NOT NULL,
          parkTime INTEGER NOT NULL,
          leftTime INTEGER DEFAULT 0,
          charge REAL DEFAULT 0,
          ratePerHour REAL DEFAULT 5,
          recordDate TEXT NOT NULL  -- 记录日期（YYYY-MM-DD格式）
        )
      `);

      console.info('Parking charges table initialized');
    } catch (e) {
      console.error("数据库初始化失败:", JSON.stringify(e));
      throw new Error("Parking charge DB init failed");
    }
  }

  /**
   * 添加停车账单（自动记录当前日期）
   * @param car 车辆信息对象
   * @returns Promise<number> 新账单ID
   */
  async addParkingCharge(car: CarClass): Promise<number> {
    try {
      const currentDate = new Date().toISOString().split('T')[0]; // 获取YYYY-MM-DD

      const values: relationalStore.ValuesBucket = {
        licenseNumber: car.licenseNumber,
        owner: car.owner,
        carModel: car.carModel,
        parkTime: car.parkTime,
        leftTime: car.leftTime,
        charge: car.charge,
        ratePerHour: car.ratePerHour,
        recordDate: currentDate
      };

      const insertId = await this.store.insert('parking_charges', values);
      promptAction.showToast({ message: '停车记录添加成功' });
      return insertId;
    } catch (e) {
      promptAction.showToast({ message: '添加失败，请重试' });
      console.error('Add charge error:', JSON.stringify(e));
      return -1;
    }
  }

  /**
   * 删除账单（根据ID）
   * @param id 账单ID
   * @returns 是否删除成功
   */
  async deleteChargeById(id: number): Promise<boolean> {
    try {
      const predicates = new relationalStore.RdbPredicates('parking_charges');
      predicates.equalTo('id', id);

      const rows = await this.store.delete(predicates);
      if (rows > 0) {
        promptAction.showToast({ message: '删除成功' });
        return true;
      }
      return false;
    } catch (e) {
      promptAction.showToast({ message: '删除失败' });
      console.error('Delete charge error:', JSON.stringify(e));
      return false;
    }
  }

  /**
   * 更新停车账单（如补录离开时间）
   * @param id 账单ID
   * @param updatedCar 更新后的车辆数据
   */
  async updateCharge(id: number, updatedCar: CarClass): Promise<boolean> {
    try {
      const predicates = new relationalStore.RdbPredicates('parking_charges');
      predicates.equalTo('id', id);

      const values: relationalStore.ValuesBucket = {
        leftTime: updatedCar.leftTime,
        charge: updatedCar.charge,
        owner: updatedCar.owner
      };

      const rows = await this.store.update(values, predicates);
      return rows > 0;
    } catch (e) {
      console.error('Update charge error:', JSON.stringify(e));
      return false;
    }
  }

  /**
   * 根据车牌号查询历史记录
   * @param license 车牌号
   * @returns 停车记录数组
   */
  async getChargesByLicense(license: string): Promise<CarClass[]> {
    const charges: CarClass[] = [];
    try {
      const predicates = new relationalStore.RdbPredicates('parking_charges');
      predicates.equalTo('licenseNumber', license);

      const result = await this.store.query(predicates,
        ['id', 'licenseNumber', 'owner', 'carModel', 'parkTime', 'leftTime', 'charge', 'ratePerHour']);

      while (result.goToNextRow()) {
        charges.push(this._resultToCar(result));
      }
      return charges;
    } catch (e) {
      console.error('Query charges error:', JSON.stringify(e));
      return charges;
    }
  }

  /**
   * 获取某天的所有停车记录
   * @param date 日期（YYYY-MM-DD）
   */
  async getChargesByDate(date: string): Promise<CarClass[]> {
    const charges: CarClass[] = [];
    try {
      const predicates = new relationalStore.RdbPredicates('parking_charges');
      predicates.equalTo('recordDate', date);

      const result = await this.store.query(predicates);
      // ...类似处理
      return charges;
    } catch (e) {
      // 错误处理
      return charges;
    }
  }

  /**
   * 将数据库结果转换为CarClass对象
   */
  private _resultToCar(result: relationalStore.ResultSet): CarClass {
    const car = new CarClass(
      result.getString(result.getColumnIndex('licenseNumber')),
      result.getString(result.getColumnIndex('carModel')),
      result.getDouble(result.getColumnIndex('parkTime')),
      result.getDouble(result.getColumnIndex('leftTime')),
      result.getString(result.getColumnIndex('owner')),
      result.getDouble(result.getColumnIndex('ratePerHour'))
    );
    car.charge = result.getDouble(result.getColumnIndex('charge'));
    return car;
  }

  // 其他方法：关闭数据库等（参考UserDBManager）
}