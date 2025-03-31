// 茶泡饭
// 2025 3 28

import { relationalStore } from '@kit.ArkData';
import { promptAction } from '@kit.ArkUI';
import User from '../model/Users';

export class UserDBManager {
  private static instance: UserDBManager;
  private store: relationalStore.RdbStore = {} as relationalStore.RdbStore;
  private config: relationalStore.StoreConfig = {
    name: "user_db.db",
    securityLevel: relationalStore.SecurityLevel.S1
  };

  static async getInstance(): Promise<UserDBManager> {
    if (!UserDBManager.instance) {
      UserDBManager.instance = new UserDBManager();
      await UserDBManager.instance.initDB();
    }
    return UserDBManager.instance;
  }

  private constructor() {}

  private async initDB() {
    try {
      this.store = await relationalStore.getRdbStore(getContext(), this.config);
      // 创建新表结构
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
      // 兼容旧表结构：尝试添加score列
      try {
        await this.store.executeSql(`ALTER TABLE users ADD COLUMN score INTEGER DEFAULT 0`);
      } catch (alterError) {
        console.info('Score column already exists or alter failed');
      }
      console.info('User table initialized');
    } catch (e) {
      console.error("数据库初始化失败:", JSON.stringify(e));
    }
  }

  async addUser(user: User): Promise<number> {
    try {
      const values: relationalStore.ValuesBucket = {
        userName: user.userName,
        passWord: user.passWord,
        phoneNumber: user.phoneNumber,
        score: user.score,  // 新增积分
        profile: user.profile
      };
      const insertId = await this.store.insert('users', values);
      promptAction.showToast({ message: '用户添加成功' });
      return insertId;
    } catch (e) {
      promptAction.showToast({ message: '用户添加失败' });
      console.error('Add user error:', JSON.stringify(e));
      return -1;
    }
  }

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

  async updateUser(user: User): Promise<boolean> {
    try {
      const predicates = new relationalStore.RdbPredicates('users');
      predicates.equalTo('userName', user.userName);
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
      return false;
    } catch (e) {
      promptAction.showToast({ message: '用户更新失败' });
      console.error('Update user error:', JSON.stringify(e));
      return false;
    }
  }

  async getUserByName(userName: string): Promise<User | null> {
    try {
      const predicates = new relationalStore.RdbPredicates('users');
      predicates.equalTo('userName', userName);
      const result = await this.store.query(predicates,
        ['userName', 'passWord', 'phoneNumber', 'score', 'profile']); // 包含score
      if (result.rowCount <= 0) return null;
      result.goToFirstRow();
      return new User(
        result.getString(result.getColumnIndex('userName')),
        result.getString(result.getColumnIndex('passWord')),
        result.getString(result.getColumnIndex('phoneNumber')),
        result.getDouble(result.getColumnIndex('score')), // 读取score
        result.getString(result.getColumnIndex('profile'))
      );
    } catch (e) {
      console.error('Query user error:', JSON.stringify(e));
      return null;
    }
  }

  async getAllUsers(): Promise<User[]> {
    const users: User[] = [];
    try {
      const predicates = new relationalStore.RdbPredicates('users');
      const result = await this.store.query(predicates,
        ['userName', 'passWord', 'phoneNumber', 'score', 'profile']); // 包含score
      if (result.rowCount <= 0) return users;
      while (result.goToNextRow()) {
        users.push(new User(
          result.getString(result.getColumnIndex('userName')),
          result.getString(result.getColumnIndex('passWord')),
          result.getString(result.getColumnIndex('phoneNumber')),
          result.getDouble(result.getColumnIndex('score')), // 读取score
          result.getString(result.getColumnIndex('profile'))
        ));
      }
      return users;
    } catch (e) {
      console.error('Get all users error:', JSON.stringify(e));
      return users;
    }
  }

  async close() {
    try {
      await this.store.close();
    } catch (e) {
      console.error('Close DB error:', JSON.stringify(e));
    }
  }
}
