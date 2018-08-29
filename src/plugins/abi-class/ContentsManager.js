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

  getWriterContentsAddress(address) {
    return this._contract.methods.getWriterContentsAddress(address).call();
  }

  addContents(record) {
    return this._contract.methods.addContents(JSON.stringify(record), BigNumber(record.marketerRate)).send();
  }

  getInitialDeposit(writer) {
    return this._contract.methods.getInitialDeposit(writer).call();
  }
}

export default ContentsManager;
