//茶泡饭
//2025 3 28

import { relationalStore } from '@kit.ArkData'; // 导入关系型数据库模块
import { promptAction } from '@kit.ArkUI'; // 导入 UI 提示模块
import User from '../model/Users'; // 导入 User 类

export class UserDBManager {
  private static instance: UserDBManager; // 存储 UserDBManager 的单例实例
  private store: relationalStore.RdbStore = {} as relationalStore.RdbStore; // 数据库存储对象
  private config: relationalStore.StoreConfig = {
    name: "user_db.db", // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1 // 设置安全级别
  };

  /**
   * 获取 UserDBManager 单例实例
   * @returns {Promise<UserDBManager>} 返回数据库管理实例
   */
  static async getInstance(): Promise<UserDBManager> {
    if (!UserDBManager.instance) {
      UserDBManager.instance = new UserDBManager(); // 创建新实例
      await UserDBManager.instance.initDB(); // 初始化数据库
    }
    return UserDBManager.instance;
  }

  // 私有构造函数，防止外部实例化
  private constructor() {}

  /**
   * 初始化数据库，创建 users 表（如果不存在）
   */
  private async initDB() {
    try {
      this.store = await relationalStore.getRdbStore(getContext(), this.config); // 获取数据库实例
      await this.store.executeSql(`
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userName TEXT NOT NULL UNIQUE,
          passWord TEXT NOT NULL,
          phoneNumber TEXT,
          profile TEXT
        )
      `); //id为主键，依次是用户名，密码，电话号码，头像存储位置
      console.info('User table created');
    } catch (e) {
      console.error("数据库初始化失败")
      //promptAction.showToast({ message: '数据库初始化失败' }); // 其实这个toast可以提示给用户的，但是不美观
      console.error('DB init error:', JSON.stringify(e));
    }
  }

  /**
   * 添加用户
   * @param {User} user - 用户对象
   * @returns {Promise<number>} 返回插入的用户 ID，失败返回 -1
   */
  async addUser(user: User): Promise<number> {
    try {
      const values: relationalStore.ValuesBucket = {
        userName: user.userName,
        passWord: user.passWord,
        phoneNumber: user.phoneNumber,
        profile: user.profile
      };
      const insertId = await this.store.insert('users', values); // 插入数据
      promptAction.showToast({ message: '用户添加成功' });
      return insertId;
    } catch (e) {
      promptAction.showToast({ message: '用户添加失败' });
      console.error('Add user error:', JSON.stringify(e));
      return -1;
    }
  }

  /**
   * 根据用户名删除用户
   * @param {string} userName - 用户名
   * @returns {Promise<boolean>} 成功删除返回 true，失败返回 false
   */
  async deleteUser(userName: string): Promise<boolean> {
    try {
      const predicates = new relationalStore.RdbPredicates('users');
      predicates.equalTo('userName', userName);
      const rows = await this.store.delete(predicates); // 执行删除操作
      if (rows > 0) {
        promptAction.showToast({ message: '用户删除成功' });
        return true;
      }
      return false;
    } catch (e) {
      promptAction.showToast({ message: '用户删除失败' });
      console.error('Delete user error:', JSON.stringify(e));
      return false;
    }
  }

  /**
   * 更新用户信息
   * @param {User} user - 用户对象
   * @returns {Promise<boolean>} 成功返回 true，失败返回 false
   */
  async updateUser(user: User): Promise<boolean> {
    try {
      const predicates = new relationalStore.RdbPredicates('users');
      predicates.equalTo('userName', user.userName);
      const values: relationalStore.ValuesBucket = {
        passWord: user.passWord,
        phoneNumber: user.phoneNumber,
        profile: user.profile
      };
      const rows = await this.store.update(values, predicates); // 更新数据
      if (rows > 0) {
        promptAction.showToast({ message: '用户更新成功' });
        return true;
      }
      return false;
    } catch (e) {
      promptAction.showToast({ message: '用户更新失败' });
      console.error('Update user error:', JSON.stringify(e));
      return false;
    }
  }

  /**
   * 根据用户名查询用户
   * @param {string} userName - 用户名
   * @returns {Promise<User | null>} 返回 User 对象或 null
   */
  async getUserByName(userName: string): Promise<User | null> {
    try {
      const predicates = new relationalStore.RdbPredicates('users');
      predicates.equalTo('userName', userName);
      const result = await this.store.query(predicates, ['userName', 'passWord', 'phoneNumber', 'profile']);
      if (result.rowCount <= 0) return null;
      result.goToFirstRow();
      return new User(
        result.getString(result.getColumnIndex('userName')),
        result.getString(result.getColumnIndex('passWord')),
        result.getString(result.getColumnIndex('phoneNumber')),
        result.getString(result.getColumnIndex('profile'))
      );
    } catch (e) {
      console.error('Query user error:', JSON.stringify(e));
      return null;
    }
  }

  /**
   * 获取所有用户
   * @returns {Promise<User[]>} 返回用户列表
   */
  async getAllUsers(): Promise<User[]> {
    const users: User[] = [];
    try {
      const predicates = new relationalStore.RdbPredicates('users');
      const result = await this.store.query(predicates, ['userName', 'passWord', 'phoneNumber', 'profile']);
      if (result.rowCount <= 0) return users;
      while (result.goToNextRow()) {
        users.push(new User(
          result.getString(result.getColumnIndex('userName')),
          result.getString(result.getColumnIndex('passWord')),
          result.getString(result.getColumnIndex('phoneNumber')),
          result.getString(result.getColumnIndex('profile'))
        ));
      }
      return users;
    } catch (e) {
      console.error('Get all users error:', JSON.stringify(e));
      return users;
    }
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
//数据来源于：https://blog.csdn.net/qq_44925904/article/details/144274397
//参考chatGPT