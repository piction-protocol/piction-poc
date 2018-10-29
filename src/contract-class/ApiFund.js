import {abi} from '@contract-build-source/ApiFund'
import Fund from '@models/Fund';
import Writer from '@models/Writer';
import Supporter from '@models/Supporter';
import SupporterPool from '@models/SupporterPool';
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
      fund.startTime = new Date(Number(event.startTime)).toISOString();
      fund.endTime = new Date(Number(event.endTime)).toISOString();
      fund.maxcap = Number(event.limit[0]) / Math.pow(10, 18);
      fund.softcap = Number(event.limit[1]) / Math.pow(10, 18);
      fund.min = Number(event.limit[2]) / Math.pow(10, 18);
      fund.max = Number(event.limit[3]) / Math.pow(10, 18);
      fund.poolSize = Number(event.poolSize);
      fund.interval = Number(event.releaseInterval);
      fund.firstDistributionTime = new Date(Number(event.supportFirstTime)).toISOString();
      fund.distributionRate = Number(event.distributionRate) / Math.pow(10, 18);
      fund.detail = event.detail;
      fund.setComic(comics.find(comic => comic.address == event.content.toLowerCase()));
      funds.push(fund);
    });
    const rises = await this.getFundRise(funds.map(fund => fund.address));
    funds.map((fund, i) => fund.rise = Number(rises[i]) / Math.pow(10, 18));
    return funds;
  }

  async getFundAddress(address) {
    let result = await this._contract.methods.getFund(address).call();
    return (result == 0) ? null : result
  }

  async getFund(vue, address) {
    let result = await this._contract.methods.getFundInfo(address).call();
    result = Web3Utils.prettyJSON(result);
    let fund = new Fund();
    fund.address = address;
    fund.startTime = new Date(Number(result.startTime)).toISOString();
    fund.endTime = new Date(Number(result.endTime)).toISOString();
    fund.maxcap = Number(result.limit[0]) / Math.pow(10, 18);
    fund.softcap = Number(result.limit[1]) / Math.pow(10, 18);
    fund.min = Number(result.limit[2]) / Math.pow(10, 18);
    fund.max = Number(result.limit[3]) / Math.pow(10, 18);
    fund.poolSize = Number(result.poolSize);
    fund.interval = Number(result.releaseInterval);
    fund.firstDistributionTime = new Date(Number(result.supportFirstTime)).toISOString();
    fund.distributionRate = Number(result.distributionRate) / Math.pow(10, 18);
    fund.detail = result.detail;
    fund.rise = Number(result.fundRise) / Math.pow(10, 18);
    let comic = await vue.$contract.apiContents.getComic(result.content)
    fund.setComic(comic);
    return fund;
  }

  // 펀드 등록
  createFund(address, fund) {
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
      fund.interval,
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
  async getSupporters(vue, address) {
    const supporters = [];
    let results = await this._contract.methods.getSupporters(address).call();
    results = Web3Utils.jsonToArray(results);
    let writers = await vue.$contract.accountManager.getUserNames(results.map(s => s.user));
    results.forEach((r, index) => {
      let supporter = new Supporter(r);
      supporter.writer = new Writer(r.user, writers[index]);
      supporters.push(supporter)
    });
    return supporters;
  }

  // 내 투자 정보
  async getMySupporter(vue, address) {
    const supporters = await this.getSupporters(vue, address);
    const supporter = supporters.find(s => s.writer.address == this._contract.options.from);
    return supporter ? supporter : new Supporter();
  }

  async getDistributions(fund) {
    let distributions = await this._contract.methods.getDistributions(fund.address).call();
    distributions = Web3Utils.jsonToArray(distributions).map((d, index) => new SupporterPool(fund, index, d));
    return distributions;
  }

  // 투자 종료 처리, 서포터 풀 생성
  endFund(fund) {
    return this._contract.methods.endFund(fund).send();
  }

  // 서포터 풀 회수
  releaseDistribution(address) {
    return this._contract.methods.releaseDistribution(address).send();
  }

  vote(fund, index) {
    return this._contract.methods.vote(fund, index).send();
  }
}

export default ApiFund;