import {abi} from '@contract-build-source/ApiReport'

class ApiReport {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  withdrawRegistration() {
    return this._contract.methods.withdrawRegistration().send();
  }

  getRegistrationAmount() {
    return this._contract.methods.getRegistrationAmount().call();
  }

  getReportResult(ids) {
    return this._contract.methods.getReportResult(ids).call();
  }

  sendReport(content, detail) {
    return this._contract.methods.sendReport(content, detail).send();
  }

  reportDisposal(index, content, reporter, type, description) {
    return this._contract.methods.reportDisposal(index, content, reporter, type, description).send();
  }

  getUncompletedReportCount(content) {
    return this._contract.methods.getUncompletedReportCount(content).call();
  }

  getUncompletedReportCounts(content) {
    return this._contract.methods.getUncompletedReportCounts(content).call();
  }

}

export default ApiReport;