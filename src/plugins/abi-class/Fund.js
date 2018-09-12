class Fund {
  constructor(abi, from, gas) {
    this._contract = new web3.eth.Contract(abi);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getInfo(address) {
    this._contract.options.address = address;
    return this._contract.methods.info().call()
  }

  getSupporters(address) {
    this._contract.options.address = address;
    return this._contract.methods.getSupporters().call()
  }

  createSupporterPool(address) {
    this._contract.options.address = address;
    return this._contract.methods.createSupporterPool().send()
  }
}

export default Fund;
