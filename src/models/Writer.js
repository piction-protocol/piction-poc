export default class Writer {
  constructor(address, name) {
    this.address = address ? address.toLowerCase() : '';
    this.name = name;
  }
}