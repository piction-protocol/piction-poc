import {abi} from '../../../build/contracts/ApiReport.json'

class ApiReport {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  withdrawRegistration() {
    return this._contract.methods.withdrawRegistration().call();
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

  judge(index, content, reporter, deductionRate) {
    return this._contract.methods.judge(index, content, reporter, deductionRate).send();
  }

}

export default ApiReport;