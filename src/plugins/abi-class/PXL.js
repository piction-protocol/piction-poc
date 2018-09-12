class PXL {
  constructor(abi, address, from, gas) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = gas;
  }

  getTokenTransferable() {
    return this._contract.methods.getTokenTransferable().call();
  }

  balanceOf(address) {
    return this._contract.methods.balanceOf(address).call();
  }

  approveAndCall(to, value, data) {
    console.log(to, value, data)
    return this._contract.methods.approveAndCall(to, value, data ? data : '0x00').send()
  }
}

export default PXL;
