import Comic from '@models/Comic'

export default class Council {
  constructor() {
    this.comic = new Comic();
    this.uncompletedReportCount = 0;
    this.lastReportTime = 0;
  }
}