class UserPaybackPool {
  constructor(abi, address, from) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = 6000000;
  }

  getPaybackInfo() {
    return this._contract.methods.getPaybackInfo().call();
  }

  release() {
    return this._contract.methods.release().send();
  }
}

export default UserPaybackPool;