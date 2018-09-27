import {abi} from '../../../build/contracts/ContentsManager.json'
import BigNumber from 'bignumber.js'

class ContentsManager {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getContents() {
    return this._contract.methods.getContents().call();
  }

  getWriterContentsAddress(address) {
    return this._contract.methods.getWriterContentsAddress(address).call();
  }

  addContents(record) {
    return this._contract.methods.addContents(JSON.stringify(record), BigNumber(record.marketerRate).multipliedBy(Math.pow(10, 18))).send();
  }

  getInitialDeposit(writer) {
    return this._contract.methods.getInitialDeposit(writer).call();
  }
}

export default ContentsManager;
