export default class Web3Utils {

  static prettyJSON(obj) {
    [...Array(20).keys()].forEach(i => delete obj[i]);
    for (let k of Object.keys(obj)) {
      obj[k.replace('_', '')] = obj[k];
      delete obj[k];
    }
    return obj;
  }

  static jsonToArray(obj) {
    obj = Web3Utils.prettyJSON(obj);
    var length = obj[Object.keys(obj)[0]].length;
    var result = new Array(length).fill().map(() => JSON.parse('{}'));
    Object.keys(obj).forEach((k, i) => obj[k].forEach((v, j) => result[j][k] = v));
    return result;
  }


  static structArrayToJson(_result, _fields) {
    var result = new Array(_result[0].length).fill().map(() => JSON.parse('{}'));
    _fields.forEach((f, i) => _result[i].forEach((v, j) => result[j][f] = v));
    return result;
  }

  static bytesToArray(bytes, spos, epos) {
    const arr = [];
    spos.forEach((o, i) => {
      let str = bytes.substring(spos[i], epos[i]);
      if (str.indexOf("0x") == -1) str = "0x" + str;
      arr.push(web3.utils.hexToUtf8(str));
    });
    return arr;
  }
}