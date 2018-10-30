export default class ComicForm {
  constructor() {
    this.startTime = new Date().toISOString();
    this.endTime = '';
    this.maxcap;
    this.softcap;
    this.min;
    this.max;
    this.poolSize = 3;
    this.interval = 1000 * 60 * 60;
    this.firstDistributionTime = '';
    this.distributionRate = 0.1;
    this.detail = '';
  }
}