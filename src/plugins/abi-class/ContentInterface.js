import BigNumber from 'bignumber.js'

class ContentsManager {
  constructor(abi, from) {
    this._contract = new web3.eth.Contract(abi);
    this._contract.options.from = from;
    this._contract.options.gas = 6000000;
  }

  updateContent(address, record) {
    this._contract.options.address = address;
    return this._contract.methods.updateContent(JSON.stringify(record), BigNumber(record.marketerRate)).send();
  }

  getRecord(address) {
    this._contract.options.address = address;
    return this._contract.methods.getRecord().call();
  }

  getMarketerRate(address) {
    this._contract.options.address = address;
    return this._contract.methods.getMarketerRate().call();
  }
}

export default ContentsManager;
