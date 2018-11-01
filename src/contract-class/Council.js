import {abi} from '@contract-build-source/Council'

class Council {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  reportDisposal(index, content, reporter, type, desc) {
    return this._contract.methods.reportDisposal(index, content, reporter, type, desc).send();
  }

  async getReportDisposalEvent(address) {
    const filter = {};
    filter._content = address;
    
    return await this._contract.getPastEvents('ReportDisposal', {filter: filter, fromBlock: 0, toBlock: 'latest'});
  }
}

export default Council;
