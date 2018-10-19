import {abi} from '@contract-build-source/Report'

class Report {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
    this._f = (() => {})
    this._contract.events.SendReport({fromBlock: 'latest'}, (error, event) => this._f(error, event))
  }

  getContract() {
    return this._contract;
  }

  setCallback(f) {
    this._f = f;
  }
}

export default Report;
