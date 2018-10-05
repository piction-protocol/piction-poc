import {abi} from '../../../build/contracts/FundManager.json'
import BigNumber from 'bignumber.js'

class FundManager {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  addFund(contentAddress, writerAddress, startTime, endTime, poolSize, interval, distributionRate, detail) {
    return this._contract.methods.addFund(
      contentAddress, writerAddress, startTime, endTime, poolSize, interval, BigNumber(distributionRate * Math.pow(10, 18)), detail
    ).send();
  }

  getFunds(contentAddress) {
    return this._contract.methods.getFunds(contentAddress).call();
  }
}

export default FundManager;
