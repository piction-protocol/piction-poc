import Comic from '@models/Comic'

export default class Fund {
  constructor(address,
              startTime,
              endTime,
              rise = 0,
              maxcap = 0,
              softcap = 0,
              min = 0,
              max = 0,
              poolSize = 3,
              interval = 1000 * 60 * 60,
              firstDistributionTime,
              distributionRate = 0.01,
              detail) {
    this.address = address ? address.toLowerCase() : '';
    this.startTime = startTime;
    this.endTime = endTime;
    this.rise = rise;
    this.maxcap = maxcap;
    this.softcap = softcap;
    this.min = min;
    this.max = max;
    this.poolSize = poolSize;
    this.interval = interval;
    this.firstDistributionTime = firstDistributionTime;
    this.distributionRate = distributionRate;
    this.detail = detail;

    this.comic = new Comic();
    this.supporters = [];
    this.distributions = [];
  }

  getRisePercent() {
    return (this.rise / this.maxcap * 100).toFixed(0);
  }

  getSoftcapPercent() {
    return (this.softcap / this.maxcap * 100).toFixed(0);
  }

  setComic(comic) {
    this.comic = comic;
  }
}