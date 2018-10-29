export default class Episode {
  constructor(record = {title: null, thumbnail: '',}) {
    this.id = null;
    this.number = 0;
    this.title = record.title;
    this.thumbnail = record.thumbnail;
    this.price = 0;
    this.isPurchased = false;
    this.cuts = [];
    this.publishedAt = 0;
    this.status = false;
    this.createdAt = 0;
    this.purchasedAmount = 0;
  }
}