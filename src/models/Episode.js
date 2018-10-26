export default class Episode {
  constructor(key, number = 1, record = {
    title: null,
    thumbnail: '',
  }, price = 0, isPurchased = false, cuts = [], publishedAt = new Date(), status = true, createdAt = null) {
    this.key = key;
    this.number = number;
    this.title = record.title;
    this.thumbnail = record.thumbnail;
    this.price = price;
    this.isPurchased = isPurchased;
    this.cuts = cuts;
    this.publishedAt = publishedAt.toISOString();
    this.status = status;
    this.createdAt = createdAt;
    this.purchasedAmount = 0;
  }
}