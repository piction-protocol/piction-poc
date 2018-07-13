class Content {
  constructor(abi, from, bytecode) {
    this._contract = new web3.eth.Contract(abi);
    this._contract.options.from = from;
    this._contract.options.data = bytecode;
  }

  deploy(_arguments) {
    return this._contract.deploy({
      arguments: _arguments
    }).send()
  }

  update(_arguments) {
    return this._contract.methods.resetContent(
      _arguments[0],
      _arguments[1],
      _arguments[2],
      _arguments[3],
      _arguments[4],
      _arguments[5],
      _arguments[6],
    ).send();
  }

  getTitle(address) {
    this._contract.options.address = address;
    return this._contract.methods.name().call();
  }

  getThumbnail(address) {
    this._contract.options.address = address;
    return this._contract.methods.titleImage().call();
  }

  getTitleImage(address) {
    this._contract.options.address = address;
    return this._contract.methods.titleImage().call();
  }

  getSynopsis(address) {
    this._contract.options.address = address;
    return this._contract.methods.synopsis().call();
  }

  getGenres(address) {
    this._contract.options.address = address;
    return this._contract.methods.genres().call();
  }

  getMarketerRate(address) {
    this._contract.options.address = address;
    return this._contract.methods.marketerRate().call();
  }

  getTranslatorRate(address) {
    this._contract.options.address = address;
    return this._contract.methods.translatorRate().call();
  }
}

export default Content;
