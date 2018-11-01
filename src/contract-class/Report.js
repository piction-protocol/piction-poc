import {abi} from '@contract-build-source/Report'

class Report {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getContract() {
    return this._contract;
  }

  //자신의 신고 내역 조회
  async getMyReportList() {
    return await this._contract.getPastEvents('SendReport', {
      filter: {_from: this._contract.options.from},
      fromBlock: 0,
      toBlock: 'latest'
    });
  }

  //자신의 신고 처리완료 조회
  async getMyCompleteReportList() {
    return await this._contract.getPastEvents('CompleteReport', {
      filter: {_from: this._contract.options.from},
      fromBlock: 0,
      toBlock: 'latest'
    });
  }

  //작품 신고 내역 조회
  async getReportList(address) {
    return await this._contract.getPastEvents('SendReport', {
      filter: {_content: address},
      fromBlock: 0,
      toBlock: 'latest'
    });
  }
}

export default Report;
