import {abi} from '../../../build/contracts/ApiFund.json'
import BigNumber from 'bignumber.js'
import Web3Utils from '../../utils/Web3Utils.js'

class ApiFund {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getContract() {
    return this._contract;
  }

  /**
   * 펀드 등록
   * @param {Address} contentAddress - 작품 주소
   * @param {Number} startTime - 모집 시작 시간
   * @param {Number} endTime - 모집 종료 시간
   * @param {Number} maxcap - maxcap
   * @param {Number} softcap - softcap
   * @param {Number} poolSize - 회수 횟수
   * @param {Number} interval - 회수 간격
   * @param {Number} distributionRate - 분배비율
   * @param {String} detail - 상세내용
   */
  addFund(contentAddress, startTime, endTime, maxcap, softcap, poolSize, interval, distributionRate, detail) {
    return this._contract.methods.addFund(
      contentAddress,
      startTime,
      endTime,
      BigNumber(maxcap * Math.pow(10, 18)),
      BigNumber(softcap * Math.pow(10, 18)),
      poolSize,
      interval,
      BigNumber(distributionRate * Math.pow(10, 18)),
      detail
    ).send();
  }

  /**
   * 펀드 목록 조회
   * @returns [{Fund}] 펀드 목록
   */
  async getFunds(contentAddress) {
    const filter = {};
    if (contentAddress) {
      filter._content = contentAddress;
    }
    let events = await this._contract.getPastEvents('AddFund', {filter: filter, fromBlock: 0, toBlock: 'latest'});
    return events.map(event => Web3Utils.prettyJSON(event.returnValues));
  }

  /**
   * 모집 금액 조회
   * @param {Address.<Array>} funds - 펀드 주소 목록
   * @returns {Number.<Array>} - 모집 금액 목록
   */
  async getFundRise(funds) {
    return await this._contract.methods.getFundRise(funds).call();
  }

  /**
   * 펀드 상세 정보 조회
   * @param {Address} fund - 펀드 주소
   * @returns {Fund} - 펀드 상세 정보
   */
  async fundInfo(fund) {
    var fund = await this._contract.methods.fundInfo(fund).call();
    return Web3Utils.prettyJSON(fund);
  }

  /**
   *  서포터 정보 조회
   * @param {Address} fund - 펀드 주소
   * @returns {Support.<Array>} - 펀드 상세 정보
   */
  async getSupporters(fund) {
    var supporters = await this._contract.methods.getSupporters(fund).call();
    return Web3Utils.jsonToArray(supporters);
  }

  /**
   * 서포터 풀 정보 조회
   * @param {Address} fund - 펀드 주소
   * @returns {Distribution.<Array>} - 서포터 풀 정보
   */
  async getDistributions(fund) {
    var distributions = await this._contract.methods.getDistributions(fund).call();
    return Web3Utils.jsonToArray(distributions);
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