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

  addEpisode(address, record, cuts, price) {
    this._contract.options.address = address;
    return this._contract.methods.addEpisode(
      JSON.stringify(record),
      JSON.stringify(cuts),
      BigNumber(price * Math.pow(10, 18))
    ).send();
  }

  updateEpisode(address, index, record, cuts, price) {
    this._contract.options.address = address;
    return this._contract.methods.updateEpisode(
      index,
      JSON.stringify(record),
      JSON.stringify(cuts),
      BigNumber(price * Math.pow(10, 18))
    ).send();
  }

  getEpisodeLength(address) {
    this._contract.options.address = address;
    return this._contract.methods.getEpisodeLength().call();
  }

  getEpisodeDetail(address, index) {
    this._contract.options.address = address;
    return this._contract.methods.getEpisodeDetail(index).call();
  }
}

export default ContentsManager;
