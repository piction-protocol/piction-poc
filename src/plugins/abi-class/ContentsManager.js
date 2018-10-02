import {abi} from '../../../build/contracts/ContentsManager.json'

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

  getInitialDeposit(writer) {
    return this._contract.methods.getInitialDeposit(writer).call();
  }
}

export default ContentsManager;
