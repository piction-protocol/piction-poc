import BigNumber from 'bignumber.js'

class ContentsManager {
  constructor(abi, address, from) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = 6000000;
  }

  getContents() {
    return this._contract.methods.getContents().call();
  }

  addContents(record) {
    return this._contract.methods.addContents(JSON.stringify(record), BigNumber(record.marketerRate)).send();
  }
}

export default ContentsManager;
