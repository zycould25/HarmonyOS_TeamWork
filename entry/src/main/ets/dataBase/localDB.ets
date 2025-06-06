// 茶泡饭
// 2025 3 28

// 导入ArkData的关系型数据库模块和UI提示模块
import { relationalStore } from '@kit.ArkData';
import { promptAction } from '@kit.ArkUI';
import User from '../model/Users';

/**
 * 用户数据库管理类（单例模式）
 * 封装用户数据的CRUD操作，支持以下功能：
 * - 数据库初始化及表结构管理
 * - 用户增删改查操作
 */
export class UserDBManager {
  private static instance: UserDBManager;          // 单例实例
  private store: relationalStore.RdbStore = {} as relationalStore.RdbStore; // 数据库实例
  private config: relationalStore.StoreConfig = {  // 数据库配置
    name: "user_db.db",            // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1 // 安全级别S1
  };

  /**
   * 获取单例实例（异步初始化）
   * @returns Promise<UserDBManager> 返回数据库管理实例
   */
  static async getInstance(): Promise<UserDBManager> {
    if (!UserDBManager.instance) {
      UserDBManager.instance = new UserDBManager();
      await UserDBManager.instance.initDB(); // 首次实例化时初始化数据库
    }
    return UserDBManager.instance;
  }

  private constructor() {} // 私有构造函数确保单例模式

  /**
   * 初始化数据库（内部方法）
   * 创建表结构并处理字段变更
   */
  private async initDB() {
    try {
      // 获取或创建数据库连接
      this.store = await relationalStore.getRdbStore(getContext(), this.config);

      // 创建核心用户表（如果不存在）
      await this.store.executeSql(`
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userName TEXT NOT NULL UNIQUE,
          passWord TEXT NOT NULL,
          phoneNumber TEXT,
          score INTEGER DEFAULT 0,
          profile TEXT
        )
      `);

      //在真机模拟测试的时候，之前没有引入这个积分机制，这里防止它出现问题，补充之前的数据库的表
      try {
        await this.store.executeSql(`ALTER TABLE users ADD COLUMN score INTEGER DEFAULT 0`);
      } catch (alterError) {
        // 忽略字段已存在的错误（错误码1表示重复字段）
        console.info('Score column already exists or alter failed');
      }
      console.info('User table initialized');
    } catch (e) {
      console.error("数据库初始化失败:", JSON.stringify(e));
      throw new Error("Database initialization failed"); // 抛出异常让调用方处理
    }
  }

  /**
   * 添加新用户
   * @param user 用户对象
   * @returns Promise<number> 返回插入的用户ID（失败返回-1）
   */
  async addUser(user: User): Promise<number> {//十分的方便啊，你只需要传入一个我定义好了的User实例就可以将新用户加入数据库
    try {
      // 1. 前置校验：检查用户名是否已存在
      const existingUser = await this.getUserByName(user.userName);
      if (existingUser !== null) {
        promptAction.showToast({ message: '用户名已被使用' });
        return -1; // 提前终止，避免插入
      }
      // 2. 构建插入数据
      const values: relationalStore.ValuesBucket = {
        userName: user.userName,
        passWord: user.passWord,
        phoneNumber: user.phoneNumber,
        score: user.score,
        profile: user.profile
      };
      // 3. 执行插入
      const insertId = await this.store.insert('users', values);
      promptAction.showToast({ message: '用户添加成功' });
      return insertId;
    } catch (e) {
      // 4. 处理唯一性约束异常（防止并发冲突）
      if (e.code === 201) { // 201 是鸿蒙的唯一性错误码
        promptAction.showToast({ message: '用户名已被使用' });
      } else {
        promptAction.showToast({ message: '用户添加失败' });
      }
      console.error('Add user error:', JSON.stringify(e));
      return -1;
    }
  }

/*常见系统错误码参考
  201	BUSINESS_ERROR_USER_CANCEL	用户主动取消操作	无需处理，记录日志即可
  401	BUSINESS_ERROR_PARAM_CHECK	参数错误（如无效的context）	检查传入参数合法性
  801	BUSINESS_ERROR_HARDWARE_UNSUPPORTED	设备不支持该功能	提示用户或隐藏相关功能入口
  12100003	ERROR_PERMISSION_DENIED	权限被拒绝	引导用户前往设置页授权
*/




  /**
   * 删除用户（根据用户名）
   * @param userName 用户名
   * @returns Promise<boolean> 是否删除成功
   */
  async deleteUser(userName: string): Promise<boolean> {
    try {
      // 构建查询条件
      const predicates = new relationalStore.RdbPredicates('users');
      predicates.equalTo('userName', userName);

      // 执行删除并获取影响行数
      const rows = await this.store.delete(predicates);
      if (rows > 0) {
        promptAction.showToast({ message: '用户删除成功' });
        return true;
      }
      return false; // 用户不存在
    } catch (e) {
      promptAction.showToast({ message: '用户删除失败' });
      console.error('Delete user error:', JSON.stringify(e));
      return false;
    }
  }

  /**
   * 更新用户信息
   * @param user 用户对象（需包含用户名）
   * @returns Promise<boolean> 是否更新成功
   */
  async updateUser(user: User): Promise<boolean> {
    try {
      // 构建查询条件
      const predicates = new relationalStore.RdbPredicates('users');
      predicates.equalTo('userName', user.userName);

      // 构建更新字段（不更新用户名）
      const values: relationalStore.ValuesBucket = {
        passWord: user.passWord,
        phoneNumber: user.phoneNumber,
        profile: user.profile,
        score: user.score  // 更新积分
      };

      const rows = await this.store.update(values, predicates);
      if (rows > 0) {
        promptAction.showToast({ message: '用户更新成功' });
        return true;
      }
      return false; // 用户不存在
    } catch (e) {
      promptAction.showToast({ message: '用户更新失败' });
      console.error('Update user error:', JSON.stringify(e));
      return false;
    }
  }

  /**
   * 根据用户名查询用户
   * @param userName 用户名
   * @returns Promise<User|null> 用户对象或null
   */
  async getUserByName(userName: string): Promise<User | null> {
    try {
      const predicates = new relationalStore.RdbPredicates('users');
      predicates.equalTo('userName', userName);

      // 执行查询（指定返回字段）
      const result = await this.store.query(predicates,
        ['userName', 'passWord', 'phoneNumber', 'score', 'profile']);

      if (result.rowCount <= 0) return null;

      // 读取第一条结果
      result.goToFirstRow();
      return new User(
        result.getString(result.getColumnIndex('userName')),
        result.getString(result.getColumnIndex('passWord')),
        result.getString(result.getColumnIndex('phoneNumber')),
        result.getDouble(result.getColumnIndex('score')), // 读取积分
        result.getString(result.getColumnIndex('profile'))
      );
    } catch (e) {
      console.error('Query user error:', JSON.stringify(e));
      return null;
    }
  }

  /**
   * 获取全部用户列表
   * @returns Promise<User[]> 用户数组（可能为空）
   */
  async getAllUsers(): Promise<User[]> {
    const users: User[] = [];
    try {
      const predicates = new relationalStore.RdbPredicates('users');
      // 查询所有记录
      const result = await this.store.query(predicates,
        ['userName', 'passWord', 'phoneNumber', 'score', 'profile']);

      if (result.rowCount <= 0) return users;

      // 遍历结果集
      while (result.goToNextRow()) {
        users.push(new User(
          result.getString(result.getColumnIndex('userName')),
          result.getString(result.getColumnIndex('passWord')),
          result.getString(result.getColumnIndex('phoneNumber')),
          result.getDouble(result.getColumnIndex('score')),
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