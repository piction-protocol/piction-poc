import Writer from '@models/Writer'

export default class Comic {
  constructor(address, record = {
    title: null,
    thumbnail: '',
    genres: '',
    synopsis: ''
  }, purchasedCount = 0, lastUploadedAt = 0, createdAt = 0) {
    this.address = address ? address.toLowerCase() : '';
    this.title = record.title
    this.thumbnail = record.thumbnail
    this.genres = record.genres
    this.synopsis = record.synopsis
    this.purchasedCount = purchasedCount;
    this.lastUploadedAt = lastUploadedAt;
    this.createdAt = createdAt;
    this.writer = new Writer();
  }

  setWriter(address, name) {
    this.writer = new Writer(address, name);
  }

  static genres = [
    {text: '액션', value: '액션'},
    {text: '멜로', value: '멜로'},
    {text: '드라마', value: '드라마'},
    {text: '판타지', value: '판타지'},
    {text: 'BL', value: 'BL'},
    {text: '성인', value: '성인'}
  ]

  toJSON() {
    return {
      address: this.address,
      title: this.title,
      thumbnail: this.thumbnail,
      genres: this.genres,
      synopsis: this.synopsis,
      purchasedCount: this.purchasedCount,
      lastUploadedAt: this.lastUploadedAt,
      createdAt: this.createdAt,
      writer: this.writer
    };
  }
}