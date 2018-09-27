import {abi} from '../../../build/contracts/Council.json'

class Council {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
    this._f = (() => {})
    this._contract.events.ReportReword({fromBlock: 'latest'}, (error, event) => this._f(error, event))
  }

  setCallback(f) {
    this._f = f;
  }
}

export default Council;
