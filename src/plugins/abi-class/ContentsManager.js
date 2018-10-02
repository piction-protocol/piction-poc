import {abi} from '../../../build/contracts/ContentsManager.json'

class ContentsManager {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
    this._f = (() => {})
    this._contract.events.RegisterContents({fromBlock: 'latest'}, (error, event) => this._f(error, event))
  }

  setCallback(f) {
    this._f = f;
  }

  // emit RegisterContents(contentsAddress.length.sub(1), contractAddress, _writer, _writerName, _record, _marketerRate);

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
