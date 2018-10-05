import {abi} from '../../../build/contracts/ApiContents.json'
import BigNumber from 'bignumber.js'

class ApiContents {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
    this.registerContents = (() => {})
    this.episodeCreation = (() => {})
    this._contract.events.RegisterContents({fromBlock: 'latest'}, (error, event) => this.registerContents(error, event))
    this._contract.events.EpisodeCreation({fromBlock: 'latest'}, (error, event) => this.episodeCreation(error, event))
  }

  getContract() {
    return this._contract;
  }

  setRegisterContents(f) {
    this.registerContents = f;
  }

  setEpisodeCreation(f) {
    this.episodeCreation = f;
  }

  addContents(record) {
    return this._contract.methods.addContents(JSON.stringify(record), BigNumber(record.marketerRate).multipliedBy(Math.pow(10, 18))).send();
  }

  updateContent(contentsAddress, record) {
    return this._contract.methods.updateContent(contentsAddress, JSON.stringify(record), BigNumber(record.marketerRate).multipliedBy(Math.pow(10, 18))).send();
  }

  getContentsFullList() {
    return this._contract.methods.getContentsFullList().call();
  }

  getContentsRecord(contentsAddress) {
    return this._contract.methods.getContentsRecord(contentsAddress).call();
  }

  getContentsWriterName(contentsAddress) {
    return this._contract.methods.getContentsWriterName(contentsAddress).call();
  }

  getContentsDetail(contentsAddress) {
    return this._contract.methods.getContentsDetail(contentsAddress).call();
  }

  addEpisode(contentsAddress, record, cuts, price) {
    return this._contract.methods.addEpisode(
      contentsAddress,
      JSON.stringify(record),
      JSON.stringify(cuts),
      BigNumber(price * Math.pow(10, 18))
    ).send();
  }

  updateEpisode(contentsAddress, index, record, cuts, price) {
    return this._contract.methods.updateEpisode(
      contentsAddress,
      index,
      JSON.stringify(record),
      JSON.stringify(cuts),
      BigNumber(price * Math.pow(10, 18))
    ).send();
  }

  getEpisodeDetail(contentsAddress, index, buyer) {
    return this._contract.methods.getEpisodeDetail(contentsAddress, index, buyer).call();
  }

  getEpisodeFullList(contentsAddress) {
    return this._contract.methods.getEpisodeFullList(contentsAddress).call();
  }

  getEpisodeCuts(contentsAddress, index) {
    return this._contract.methods.getEpisodeCuts(contentsAddress, index).call();
  }

  getContentsWriterName(contentsAddress) {
    return this._contract.methods.getContentsWriterName(contentsAddress).call();
  }

  getInitialDeposit(writer) {
    return this._contract.methods.getInitialDeposit(writer).call();
  }

}

export default ApiContents;