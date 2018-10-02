import {abi} from '../../../build/contracts/ApiContents.json'
import BigNumber from 'bignumber.js'

class ApiContents {
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

  addContents(record) {
    return this._contract.methods.addContents(JSON.stringify(record), BigNumber(record.marketerRate).multipliedBy(Math.pow(10, 18))).send();
  }

  getContentsFullList() {
    return this._contract.methods.getContentsFullList().call();
  }

  getContentsWriterName(contentsAddress) {
    return this._contract.methods.getContentsWriterName(contentsAddress).call();
  }

  getInitialDeposit(writer) {
    return this._contract.methods.getInitialDeposit(writer).call();
  }

}

export default ApiContents;