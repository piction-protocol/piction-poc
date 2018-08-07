import BigNumber from 'bignumber.js'

class PXL {
  constructor(abi, address, from) {
    this._contract = new web3.eth.Contract(abi, address);
    this._contract.options.from = from;
    this._contract.options.gas = 6000000;
  }

  getTokenTransferable() {
    return this._contract.methods.getTokenTransferable().call();
  }

  balanceOf(address) {
    return this._contract.methods.balanceOf(address).call();
  }

  approveAndCall(to, value, jsonData) {
    return this._contract.methods.approveAndCall(to, BigNumber(value * Math.pow(10, 18)), jsonData).send()
  }
}

export default PXL;
