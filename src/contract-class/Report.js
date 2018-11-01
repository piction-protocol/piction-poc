import {abi} from '@contract-build-source/Report'
import Web3Utils from '@utils/Web3Utils'

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

  async getComicReportList(vue, address) {
    let sendReport = [];
    let completeReport = [];
    
    const filter = {};
    filter._content = address;
    
    const reports = await this._contract.getPastEvents('SendReport', {filter: filter, fromBlock: 0, toBlock: 'latest'});
    const councilReports = await vue.$contract.council.getReportDisposalEvent(address);

    let users = [];
    reports.forEach(report => {
      report = Web3Utils.prettyJSON(report.returnValues);
      report.completeDetail = '';
      report.selected = null;
      report.result = false;
      report.isCompleted = false;
      users.push(report.from);
      sendReport.push(report);      
    });

    let userNames = await vue.$contract.accountManager.getUserNames(users);
    sendReport.forEach((result, i) => {
      result.userName = userNames[i];
    });

    users = [];
    councilReports.forEach((event, i) => {
      event = Web3Utils.prettyJSON(event.returnValues);
      var idx = sendReport.map(f => f.index).indexOf(event.index);
      sendReport[idx].isCompleted = true;
      event.detail = sendReport[idx].detail;
      users.push(event.reporter);
      completeReport.push(event);
    });

    userNames = await vue.$contract.accountManager.getUserNames(users);
    completeReport.forEach((result, i) => {
      result.userName = userNames[i];
    });

    sendReport = sendReport.filter(f => (f.isCompleted == false));

    return [sendReport, completeReport];
  }
}

export default Report;
