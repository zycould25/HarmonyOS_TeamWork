// ParkingLotDB.ets
// 导入ArkData的关系型数据库模块和UI提示模块
import { relationalStore } from '@kit.ArkData';
import { promptAction } from '@kit.ArkUI';
import { ParkingLot } from '../model/ParkingLot'; // 导入ParkingLot实体类

/**
 * 停车场数据库管理类（单例模式）
 * 封装停车场数据的CRUD操作，支持以下功能：
 * - 数据库初始化及表结构管理
 * - 停车场信息的增删改查操作
 */
export class ParkingLotDB {
  private static instance: ParkingLotDB;          // 单例实例
  private store: relationalStore.RdbStore = {} as relationalStore.RdbStore; // 数据库实例
  private config: relationalStore.StoreConfig = {  // 数据库配置
    name: "parking_lot_db.db",     // 独立数据库文件
    securityLevel: relationalStore.SecurityLevel.S1
  };

  // 单例获取方法
  static async getInstance(): Promise<ParkingLotDB> {
    if (!ParkingLotDB.instance) {
      ParkingLotDB.instance = new ParkingLotDB();
      await ParkingLotDB.instance.initDB();
    }
    return ParkingLotDB.instance;
  }

  private constructor() {} // 私有构造函数确保单例

  /**
   * 初始化数据库（创建停车场表）
   */
  private async initDB() {
    try {
      this.store = await relationalStore.getRdbStore(getContext(), this.config);

      // 创建停车场表
      await this.store.executeSql(`
        CREATE TABLE IF NOT EXISTS parking_lots (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          location TEXT NOT NULL,
          totalSpaces INTEGER NOT NULL,
          availableSpaces INTEGER NOT NULL,
          hourlyRate REAL DEFAULT 5.0,
          openTime TEXT DEFAULT '00:00',
          closeTime TEXT DEFAULT '23:59',
          isOpen INTEGER DEFAULT 1,
          contactPhone TEXT,
          description TEXT
        )
      `);

      console.info('Parking lots table initialized');
    } catch (e) {
      console.error("停车场数据库初始化失败:", JSON.stringify(e));
      throw new Error("Parking lot DB init failed");
    }
  }

  /**
   * 添加新停车场
   * @param parkingLot 停车场信息对象
   * @returns Promise<number> 新停车场ID
   */
  async addParkingLot(parkingLot: ParkingLot): Promise<number> {
    try {
      const values: relationalStore.ValuesBucket = {
        name: parkingLot.name,
        location: parkingLot.location,
        totalSpaces: parkingLot.totalSpaces,
        availableSpaces: parkingLot.availableSpaces,
        hourlyRate: parkingLot.hourlyRate,
        openTime: parkingLot.openTime,
        closeTime: parkingLot.closeTime,
        isOpen: parkingLot.isOpen ? 1 : 0,
        contactPhone: parkingLot.contactPhone,
        description: parkingLot.description
      };

      const insertId = await this.store.insert('parking_lots', values);
      promptAction.showToast({ message: '停车场添加成功' });
      return insertId;
    } catch (e) {
      // 处理唯一性约束异常（名称重复）
      if (e.code === 201) {
        promptAction.showToast({ message: '停车场名称已存在' });
      } else {
        promptAction.showToast({ message: '添加失败，请重试' });
      }
      console.error('Add parking lot error:', JSON.stringify(e));
      return -1;
    }
  }

  /**
   * 删除停车场（根据ID）
   * @param id 停车场ID
   * @returns 是否删除成功
   */
  async deleteParkingLot(id: number): Promise<boolean> {
    try {
      const predicates = new relationalStore.RdbPredicates('parking_lots');
      predicates.equalTo('id', id);

      const rows = await this.store.delete(predicates);
      if (rows > 0) {
        promptAction.showToast({ message: '停车场删除成功' });
        return true;
      }
      return false;
    } catch (e) {
      promptAction.showToast({ message: '删除失败' });
      console.error('Delete parking lot error:', JSON.stringify(e));
      return false;
    }
  }

  /**
   * 更新停车场信息
   * @param parkingLot 更新后的停车场数据（需包含id）
   */
  async updateParkingLot(parkingLot: ParkingLot): Promise<boolean> {
    try {
      const predicates = new relationalStore.RdbPredicates('parking_lots');
      predicates.equalTo('id', parkingLot.id);

      const values: relationalStore.ValuesBucket = {
        name: parkingLot.name,
        location: parkingLot.location,
        totalSpaces: parkingLot.totalSpaces,
        availableSpaces: parkingLot.availableSpaces,
        hourlyRate: parkingLot.hourlyRate,
        openTime: parkingLot.openTime,
        closeTime: parkingLot.closeTime,
        isOpen: parkingLot.isOpen ? 1 : 0,
        contactPhone: parkingLot.contactPhone,
        description: parkingLot.description
      };

      const rows = await this.store.update(values, predicates);
      if (rows > 0) {
        promptAction.showToast({ message: '停车场信息更新成功' });
        return true;
      }
      return false;
    } catch (e) {
      promptAction.showToast({ message: '更新失败' });
      console.error('Update parking lot error:', JSON.stringify(e));
      return false;
    }
  }

  /**
   * 更新停车场可用车位数量
   * @param id 停车场ID
   * @param availableSpaces 新的可用车位数量
   */
  async updateAvailableSpaces(id: number, availableSpaces: number): Promise<boolean> {
    try {
      const predicates = new relationalStore.RdbPredicates('parking_lots');
      predicates.equalTo('id', id);

      const values: relationalStore.ValuesBucket = {
        availableSpaces: availableSpaces
      };

      const rows = await this.store.update(values, predicates);
      return rows > 0;
    } catch (e) {
      console.error('Update spaces error:', JSON.stringify(e));
      return false;
    }
  }

  /**
   * 根据ID获取停车场信息
   * @param id 停车场ID
   * @returns 停车场对象或null
   */
  async getParkingLotById(id: number): Promise<ParkingLot | null> {
    try {
      const predicates = new relationalStore.RdbPredicates('parking_lots');
      predicates.equalTo('id', id);

      const result = await this.store.query(predicates);
      if (result.rowCount <= 0) return null;

      result.goToFirstRow();
      return this._resultToParkingLot(result);
    } catch (e) {
      console.error('Query parking lot error:', JSON.stringify(e));
      return null;
    }
  }

  /**
   * 根据名称查询停车场
   * @param name 停车场名称
   * @returns 停车场对象或null
   */
  async getParkingLotByName(name: string): Promise<ParkingLot | null> {
    try {
      const predicates = new relationalStore.RdbPredicates('parking_lots');
      predicates.equalTo('name', name);

      const result = await this.store.query(predicates);
      if (result.rowCount <= 0) return null;

      result.goToFirstRow();
      return this._resultToParkingLot(result);
    } catch (e) {
      console.error('Query parking lot error:', JSON.stringify(e));
      return null;
    }
  }

  /**
   * 获取所有停车场列表
   * @returns 停车场数组
   */
  async getAllParkingLots(): Promise<ParkingLot[]> {
    const parkingLots: ParkingLot[] = [];
    try {
      const predicates = new relationalStore.RdbPredicates('parking_lots');
      
      const result = await this.store.query(predicates);
      while (result.goToNextRow()) {
        parkingLots.push(this._resultToParkingLot(result));
      }
      return parkingLots;
    } catch (e) {
      console.error('Get all parking lots error:', JSON.stringify(e));
      return parkingLots;
    }
  }

  /**
   * 获取有可用车位的停车场列表
   * @returns 有空位的停车场数组
   */
  async getAvailableParkingLots(): Promise<ParkingLot[]> {
    const parkingLots: ParkingLot[] = [];
    try {
      const predicates = new relationalStore.RdbPredicates('parking_lots');
      predicates.greaterThan('availableSpaces', 0);
      predicates.equalTo('isOpen', 1);
      
      const result = await this.store.query(predicates);
      while (result.goToNextRow()) {
        parkingLots.push(this._resultToParkingLot(result));
      }
      return parkingLots;
    } catch (e) {
      console.error('Get available parking lots error:', JSON.stringify(e));
      return parkingLots;
    }
  }

  /**
   * 将数据库结果转换为ParkingLot对象
   */
  private _resultToParkingLot(result: relationalStore.ResultSet): ParkingLot {
    return new ParkingLot(
      result.getString(result.getColumnIndex('name')),
      result.getString(result.getColumnIndex('location')),
      result.getDouble(result.getColumnIndex('totalSpaces')),
      result.getDouble(result.getColumnIndex('availableSpaces')),
      result.getDouble(result.getColumnIndex('hourlyRate')),
      result.getString(result.getColumnIndex('openTime')),
      result.getString(result.getColumnIndex('closeTime')),
      result.getDouble(result.getColumnIndex('isOpen')) === 1,
      result.getString(result.getColumnIndex('contactPhone')),
      result.getString(result.getColumnIndex('description')),
      result.getDouble(result.getColumnIndex('id'))
    );
  }

  /**
   * 关闭数据库连接
   */
  async close() {
    try {
      await this.store.close();
    } catch (e) {
      console.error('Close DB error:', JSON.stringify(e));
    }
  }
} 