class DepositPool {
  constructor(abi, address, from) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = 6000000;
  }

  getRegFee() {
    return this._contract.methods.getRegFee().call();
  }

  sendReport(content, detail) {
    return this._contract.methods.sendReport(content, detail).send();
  }

  getDeposit(content) {
    return this._contract.methods.getDeposit(content).call();
  }

  release(content) {
    return this._contract.methods.release(content).send();
  }
}

export default DepositPool;
