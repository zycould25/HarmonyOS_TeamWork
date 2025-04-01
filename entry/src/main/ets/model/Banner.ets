export class Banner {
  id: string;
  imageSrc: ResourceStr;
  url: string;
  description: string; // 新增说明字段

  constructor(id: string, imageSrc: ResourceStr, url: string, description: string) {
    this.id = id;
    this.imageSrc = imageSrc;
    this.url = url;
    this.description = description;
  }
}