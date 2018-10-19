import {abi} from '@contract-build-source/Fund'

class Fund {
  constructor(from, gas) {
    this._contract = new web3.eth.Contract(abi);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getContract(address) {
    this._contract.options.address = address;
    return this._contract;
  }
}

export default Fund;
