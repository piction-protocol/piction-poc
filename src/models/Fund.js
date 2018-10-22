import Comic from '@models/Comic'

export default class Fund {
  constructor(address,
              startTime = 0,
              endTime = 0,
              rise = 0,
              maxcap = 0,
              softcap = 0,
              min = 0,
              max = 0,
              poolSize = 3,
              interval = 1,
              firstDistributionTime = 0,
              distributionRate = 0.01,
              detail) {
    this.address = address ? address.toLowerCase() : '';
    this.startTime = startTime;
    this.endTime = endTime;
    this.rise = Number(rise);
    this.maxcap = Number(maxcap);
    this.softcap = Number(softcap);
    this.min = Number(min);
    this.max = Number(max);
    this.poolSize = Number(poolSize);
    this.interval = Number(interval);
    this.firstDistributionTime = firstDistributionTime;
    this.distributionRate = Number(distributionRate);
    this.detail = detail;
    this.comic = new Comic();
  }

  setComic(comic) {
    this.comic = comic;
  }
}