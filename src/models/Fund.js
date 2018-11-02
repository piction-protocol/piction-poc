import Comic from '@models/Comic'

export default class Fund {
  constructor(fund) {
    this.address = null;
    this.startTime = fund ? Number(fund.startTime) : 0;
    this.endTime = fund ? Number(fund.endTime) : 0;
    this.rise = 0
    this.maxcap = fund ? Number(web3.utils.fromWei(fund.limit[0])) : 0;
    this.softcap = fund ? Number(web3.utils.fromWei(fund.limit[1])) : 0;
    this.min = fund ? Number(web3.utils.fromWei(fund.limit[2])) : 0;
    this.max = fund ? Number(web3.utils.fromWei(fund.limit[3])) : 0;
    this.poolSize = fund ? Number(fund.poolSize) : 0;
    this.interval = fund ? Number(fund.releaseInterval) : 0;
    this.firstDistributionTime = fund ? Number(fund.supportFirstTime) : 0;
    this.distributionRate = fund ? Number(web3.utils.fromWei(fund.distributionRate)) : 0;
    this.needEndProcessing = fund ? fund.needEndProcessing : false;
    this.detail = fund ? fund.detail : '';
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
}