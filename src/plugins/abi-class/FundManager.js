class FundManager {
  constructor(abi, address, from) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = 6000000;
  }

  addFund(contentAddress, writerAddress, startTime, endTime, poolSize, interval, distributionRate, detail) {
    console.log(contentAddress, writerAddress, startTime, endTime, poolSize, interval, distributionRate, detail)
    return this._contract.methods.addFund(
      contentAddress, writerAddress, startTime, endTime, poolSize, interval, distributionRate, detail
    ).send();
  }

  getFunds(contentAddress) {
    return this._contract.methods.getFunds(contentAddress).call();
  }
}

export default FundManager;
