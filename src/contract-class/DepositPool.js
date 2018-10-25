import {abi} from '@contract-build-source/DepositPool'
import DepositHistory from '@models/DepositHistory'
import Web3Utils from '@utils/Web3Utils'

class DepositPool {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  // 예치금 조회
  async getDeposit(address) {
    let result = await this._contract.methods.getDeposit(address).call();
    return Number(result) / Math.pow(10, 18);
  }

  // 예치금 반환 가능 일 조회
  async getReleaseDate(address) {
    return Number(await this._contract.methods.getReleaseDate(address).call());
  }

  // 예치금 내역 조회
  async getDepositHistory(address) {
    let events = await this._contract.getPastEvents('DepositChange', {
      filter: {_content: address},
      fromBlock: 0,
      toBlock: 'latest'
    });
    const result = [];
    events.forEach(event => {
      event = Web3Utils.prettyJSON(event.returnValues);
      let history = new DepositHistory();
      history.date = event.date;
      history.type = event.type;
      history.amount = event.amount / Math.pow(10, 18);
      history.description = event.description;
      result.push(history);
    });
    return result;
  }
  
  // 예치금 회수
  release(content) {
    return this._contract.methods.release(content).send();
  }
  
  // 여기까지

  getRegFee() {
    return this._contract.methods.getRegFee().call();
  }

  sendReport(content, detail) {
    return this._contract.methods.sendReport(content, detail).send();
  }
}

export default DepositPool;
