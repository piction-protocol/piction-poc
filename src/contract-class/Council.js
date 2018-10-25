import {abi} from '@contract-build-source/Council'

class Council {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }
}

export default Council;
