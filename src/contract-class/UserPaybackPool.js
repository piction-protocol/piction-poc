import {abi} from '@contract-build-source/UserPaybackPool'

class UserPaybackPool {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getPaybackInfo() {
    return this._contract.methods.getPaybackInfo().call();
  }

  release() {
    return this._contract.methods.release().send();
  }
}

export default UserPaybackPool;