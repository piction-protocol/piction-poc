class Report {
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

  getUserReport() {
    return this._contract.methods.getUserReport().call();
  }

  getReport(index) {
    return this._contract.methods.getReport(index).call();
  }

  returnRegFee() {
    return this._contract.methods.returnRegFee().send();
  }
}

export default Report;
