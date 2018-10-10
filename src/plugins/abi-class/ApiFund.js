import {abi} from '../../../build/contracts/ApiFund.json'
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
   * @returns [{fund}] 펀드 목록
   */
  async getFunds() {
    let events = await this._contract.getPastEvents('AddFund', {fromBlock: 0, toBlock: 'latest'});
    return events.map(event => event.returnValues).pretty();
  }

  /**
   * 모집 금액 조회
   * @param {Address.<Array>} funds - 펀드 주소 목록
   * @returns {Number.<Array>} - 모집 금액 목록
   */
  async getFundRise(funds) {
    return await this._contract.methods.getFundRise(funds).call();
  }
}

export default ApiFund;