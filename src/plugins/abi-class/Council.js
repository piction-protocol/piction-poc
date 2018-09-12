class Council {
  constructor(abi, address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  judge(index, content, reporter, deductionRate) {
    console.log(index, content, reporter, deductionRate)
    return this._contract.methods.judge(index, content, reporter, deductionRate).send();
  }
}

export default Council;
