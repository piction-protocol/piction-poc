import Writer from '@models/Writer'

export default class CouncilComic {
  constructor(record = {title: null, thumbnail: ''}) {
    this.address;
    this.title = record.title
    this.thumbnail = record.thumbnail
    this.uncompletedReportCount = 0;
    this.lastReportTime = 0;
    this.isBlock = false;
    this.writer = new Writer();
  }
}