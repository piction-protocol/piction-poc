import {abi} from '../../../build/contracts/Report.json'

class Report {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getRegFee() {
    return this._contract.methods.getRegFee().call();
  }

  sendReport(content, detail) {
    return this._contract.methods.sendReport(content, detail).send();
  }

  getReportsLength() {
    return this._contract.methods.getReportsLength().call();
  }

  getUserReport() {
    return this._contract.methods.getUserReport().call();
  }

  getReport(index) {
    return this._contract.methods.getReport(index).call();
  }

  returnRegFee() {
    return this._contract.methods.returnRegFee().send();
  }
}

export default Report;
