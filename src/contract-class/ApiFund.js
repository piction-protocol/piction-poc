import {abi} from '@contract-build-source/ApiFund'
import Fund from '@models/Fund';
import Web3Utils from '@utils/Web3Utils'
import BigNumber from 'bignumber.js'

class ApiFund {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getContract() {
    return this._contract;
  }

  // 펀드 목록 조회
  async getFunds(vue, address) {
    const comics = await vue.$contract.apiContents.getComics(vue);
    const filter = {};
    if (address) {
      filter._content = address;
    }
    const funds = [];
    let events = await this._contract.getPastEvents('CreateFund', {filter: filter, fromBlock: 0, toBlock: 'latest'});
    events.forEach(async event => {
      event = Web3Utils.prettyJSON(event.returnValues);
      let fund = new Fund();
      fund.address = event.fund;
      fund.startTime = event.startTime;
      fund.endTime = event.endTime;
      fund.maxcap = event.limit[0];
      fund.softcap = event.limit[1];
      fund.min = event.limit[2];
      fund.max = event.limit[3];
      fund.poolSize = event.poolSize;
      fund.interval = event.releaseInterval;
      fund.firstDistributionTime = event.supportFirstTime;
      fund.distributionRate = event.distributionRate;
      fund.detail = event.detail;
      fund.setComic(comics.find(comic => comic.address == event.content.toLowerCase()));
      funds.push(fund);
    });
    const rises = await this.getFundRise(funds.map(fund => fund.address));
    funds.map((fund, i) => fund.rise = rises[i]);
    return funds;
  }

  async getFund(vue, address) {
    let result = await this._contract.methods.getFundInfo(address).call();
    result = Web3Utils.prettyJSON(result);
    let fund = new Fund();
    fund.address = address;
    fund.startTime = result.startTime;
    fund.endTime = result.endTime;
    fund.maxcap = result.limit[0];
    fund.softcap = result.limit[1];
    fund.min = result.limit[2];
    fund.max = result.limit[3];
    fund.poolSize = result.poolSize;
    fund.interval = result.releaseInterval;
    fund.firstDistributionTime = result.supportFirstTime;
    fund.distributionRate = result.distributionRate;
    fund.detail = result.detail;
    fund.rise = result.fundRise;
    let comic = await vue.$contract.apiContents.getComic(result.content)
    fund.setComic(comic);
    return fund;
  }

  // 펀드 등록
  createFund(address, fund) {
    let hour = 60 * 60 * 1000;
    return this._contract.methods.createFund(
      address,
      new Date(fund.startTime).getTime(),
      new Date(fund.endTime).getTime(),
      [
        BigNumber(fund.maxcap * Math.pow(10, 18)),
        BigNumber(fund.softcap * Math.pow(10, 18)),
        BigNumber(fund.min * Math.pow(10, 18)),
        BigNumber(fund.max * Math.pow(10, 18)),
      ],
      fund.poolSize,
      fund.interval * hour,
      new Date(fund.firstDistributionTime).getTime(),
      BigNumber(fund.distributionRate * Math.pow(10, 18)),
      fund.detail
    ).send();
  }

  // 모집 금액 조회
  async getFundRise(funds) {
    return await this._contract.methods.getFundRise(funds).call();
  }

  // 서포터 목록 조회
  async getSupporters(vue, fund) {
    let supporters = await this._contract.methods.getSupporters(fund).call();
    supporters = Web3Utils.jsonToArray(supporters);
    let writers = await vue.$contract.accountManager.getUserNames(supporters.map(s => s.user));
    supporters.forEach((supporter, index) => supporter.userName = writers[index]);
    return supporters;
  }

  endFund(fund) {
    return this._contract.methods.endFund(fund).send();
  }

  releaseDistribution(fund) {
    return this._contract.methods.releaseDistribution(fund).send();
  }

  vote(fund, index) {
    return this._contract.methods.vote(fund, index).send();
  }
}

export default ApiFund;