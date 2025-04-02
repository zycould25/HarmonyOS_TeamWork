// export class Place {
//   // 私有属性（通过方法访问）
//   private _id: number;
//   private _name: string = "";
//   private _description: string="";
//   private _image: Resource = "";
//
//   // 基础校验规则
//   private static MIN_NAME_LENGTH = 2;
//   private static MAX_NAME_LENGTH = 20;
//   private static MAX_DESC_LENGTH = 200;
//
//   private constructor(id: number, name: string, description: string, image: Resource) {
//     this._id = id;
//     this.setName(name);
//     this.setDescription(description);
//     this.setImage(image);
//   }
//
//   // ************ 工厂方法 ************
//   static create(id: number, name: string, description: string, image: Resource): Place | null {
//     try {
//       return new Place(id, name, description, image);
//     } catch (error) {
//       console.error('创建Place失败:', error);
//       return null;
//     }
//   }
//
//   // ************ 校验方法 ************
//   private static isValidName(name: string): boolean {
//     return name.length >= this.MIN_NAME_LENGTH &&
//       name.length <= this.MAX_NAME_LENGTH;
//   }
//
//   private static isValidDescription(desc: string): boolean {
//     return desc.length <= this.MAX_DESC_LENGTH;
//   }
//
//   // ************ Setter/Getter ************
//   setImage(image: Resource): void {
//     if (!image?.id) {
//       throw new Error('无效的图片资源');
//     }
//     this._image = image;
//   }
//
//   setName(name: string): void {
//     if (!Place.isValidName(name)) {
//       throw new Error(`地名长度需在${Place.MIN_NAME_LENGTH}-${Place.MAX_NAME_LENGTH}之间`);
//     }
//     this._name = name;
//   }
//
//   setDescription(desc: string): void {
//     if (!Place.isValidDescription(desc)) {
//       throw new Error(`描述不能超过${Place.MAX_DESC_LENGTH}字符`);
//     }
//     this._description = desc;
//   }
//
//   get id(): number { return this._id; }
//   get name(): string { return this._name; }
//   get description(): string { return this._description; }
//   get image(): Resource { return this._image; }
//
//   // ************ 实用方法 ************
//   // 生成示例数据
//   static samplePlaces(): Place[] {
//     return [
//       Place.create(1, '杭州西湖', '中国十大风景名胜之一', $r("app.media.west_lake"))!,
//       Place.create(2, '敦煌莫高窟', '佛教艺术圣地', $r("app.media.mogao_caves"))!,
//       Place.create(3, '西安兵马俑', '世界第八大奇迹', $r("app.media.terracotta"))!
//     ];
//   }
//
//   // 随机获取地点
//   static getRandomPlace(): Place {
//     const places = this.samplePlaces();
//     const index = Math.floor(Math.random() * places.length);
//     return places[index];
//   }
// }
