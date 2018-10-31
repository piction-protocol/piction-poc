import Writer from '@models/Writer'

export default class Comic {
  constructor(record = {title: null, thumbnail: '', genres: '', synopsis: ''}) {
    this.address;
    this.title = record.title
    this.thumbnail = record.thumbnail
    this.genres = record.genres
    this.synopsis = record.synopsis
    this.purchasedCount = 0;
    this.lastUploadedAt = 0;
    this.createdAt = 0;
    this.privateEpisodesCount = 0;
    this.publishedEpisodesCount = 0;
    this.totalPurchasedAmount = new web3.utils.BN(0);
    this.isBlock = false;
    this.writer = new Writer();
  }

  static genres = [
    {text: '액션', value: '액션'},
    {text: '멜로', value: '멜로'},
    {text: '드라마', value: '드라마'},
    {text: '판타지', value: '판타지'},
    {text: 'BL', value: 'BL'},
    {text: '성인', value: '성인'}
  ]
}