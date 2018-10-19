export default class Writer {
  constructor(address, name) {
    this.address = address ? address.toLowerCase() : '';
    this.name = name;
  }

  toJSON() {
    return {
      address: this.address,
      name: this.name
    };
  }
}