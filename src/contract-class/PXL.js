import {abi} from '@contract-build-source/PXL'
import Web3Utils from '@utils/Web3Utils'

class PXL {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getEvents() {
    return this._contract.events;
  }

  getTokenTransferable() {
    return this._contract.methods.getTokenTransferable().call();
  }

  balanceOf(address) {
    return this._contract.methods.balanceOf(address).call();
  }

  approveAndCall(to, value, data) {
    return this._contract.methods.approveAndCall(to, value, data ? data : '0x00').send()
  }

  async getPxlTransferEvents() {
    const fromFilter = {};
    const toFilter = {};
    fromFilter._from = this._contract.options.from;
    toFilter._to = this._contract.options.from;

    const transferEvents = [];
    let fromEvents = await this._contract.getPastEvents('PxlTransfer', {filter: fromFilter, fromBlock: 0, toBlock: 'latest'});
    let toEvents = await this._contract.getPastEvents('PxlTransfer', {filter: toFilter, fromBlock: 0, toBlock: 'latest'});

    fromEvents.forEach(async event =>{
      event = Web3Utils.prettyJSON(event.returnValues);
      event.isPlus = false;
      transferEvents.push(event);
    });

    toEvents.forEach(async event =>{
      event = Web3Utils.prettyJSON(event.returnValues);
      event.isPlus = true;
      transferEvents.push(event);
    });

    transferEvents.sort(function(a,b) {
      if (a.time > b.time) {
        return 1;
      }
      if (a.time < b.time) {
        return -1;
      }
      // a must be equal to b
      return 0;
    });

    return transferEvents;
  }
}

export default PXL;
