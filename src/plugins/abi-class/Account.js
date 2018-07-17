class Account {
  constructor(abi, address, from) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
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

  clone() {
    return this._contract.clone();
  }
}

export default Account;
