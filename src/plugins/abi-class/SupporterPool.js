class SupporterPool {
  constructor(abi, from, gas) {
    this._contract = new web3.eth.Contract(abi);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getDistributions(address) {
    this._contract.options.address = address;
    return this._contract.methods.getDistributions().call()
  }

  distribution(address) {
    this._contract.options.address = address;
    return this._contract.methods.distribution().send()
  }

  vote(address, index) {
    this._contract.options.address = address;
    return this._contract.methods.vote(index).send()
  }

  isVoting(address, index) {
    this._contract.options.address = address;
    return this._contract.methods.isVoting(index).call()
  }
}

export default SupporterPool;
