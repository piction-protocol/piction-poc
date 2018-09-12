class AccountManager {
  constructor(abi, address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
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

export default AccountManager;
