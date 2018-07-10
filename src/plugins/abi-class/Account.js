import Contract from './Contract'

class Account extends Contract {
  constructor(abi, address, from) {
    super(abi, address, from);
  }

  getUserName(address) {
    return this._contract.methods.getUserName(address).call();
  }

  getUserAddress(userName) {
    return this._contract.methods.getUserAddress(userName).call();
  }

  createAccount(userName) {
    return this._contract.methods.createAccount(userName).send();
  }
}

export default Account;
