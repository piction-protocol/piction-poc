import {abi} from '@contract-build-source/UserPaybackPool'
import Web3Utils from '@utils/Web3Utils'

class UserPaybackPool {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getPaybackInfo() {
    return this._contract.methods.getPaybackInfo().call();
  }

  getReleaseInterval() {
    return this._contract.methods.getReleaseInterval().call();
  }

  async getRewardsEvents(vue) {
    const comics = await vue.$contract.apiContents.getComics(vue);

    const filter = {};
    filter._userAddress = this._contract.options.from;
    
    const rewardEvent = [];
    let events = await this._contract.getPastEvents('AddPayback', {filter: filter, fromBlock: 0, toBlock: 'latest'});
    events.forEach(async event => {
      event = Web3Utils.prettyJSON(event.returnValues);
      let comic = comics.find(comic => comic.address == event.contentAddress.toLowerCase());
      event.contentName = comic.title;
      event.episodeIndex = parseInt(event.episodeIndex) + 1;
      rewardEvent.push(event);
    });
    return rewardEvent;
  }

  release() {
    return this._contract.methods.release().send();
  }
}

export default UserPaybackPool;