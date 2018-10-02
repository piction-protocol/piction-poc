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

  getContentsFullList() {
    return this._contract.methods.getContentsFullList().call();
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

  getEpisodeFullList(contentsAddress) {
    return this._contract.methods.getEpisodeFullList(contentsAddress).call();
  }

  getInitialDeposit(writer) {
    return this._contract.methods.getInitialDeposit(writer).call();
  }

}

export default ApiContents;