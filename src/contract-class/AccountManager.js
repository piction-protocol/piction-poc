import {abi} from '@contract-build-source/AccountManager'
import Web3Utils from '@utils/Web3Utils'

class AccountManager {
  constructor(address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getUserName(address) {
    return this._contract.methods.getUserName(address).call();
  }

  async getUserNames(addrs) {
    var result = await this._contract.methods.getUserNames(addrs).call();
    if (result.writerName_ == '')
      return [];
    else
      return Web3Utils.bytesToArray(result.writerName_, result.spos_, result.epos_);
  }

  isRegistered(userName) {
    return this._contract.methods.isRegistered(userName).call();
  }

  login(userName, password) {
    return this._contract.methods.login(userName, password).call();
  }

  createNewAccount(userName, password, privateKey, publicKey) {
    this._contract.options.from = publicKey;
    return this._contract.methods.createNewAccount(userName, password, privateKey, publicKey).send();
  }
}

export default AccountManager;