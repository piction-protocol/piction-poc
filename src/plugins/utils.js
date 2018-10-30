import moment from 'moment';
import BigNumber from 'bignumber.js'

const Utils = {
  install(Vue, options) {

    Number.prototype.between = function (a, b, inclusive) {
      var min = Math.min(a, b), max = Math.max(a, b);
      return inclusive ? this >= min && this <= max : this > min && this < max;
    }

    Vue.prototype.$utils = {
      getImageDimensions(dataUri) {
        return new Promise((resolved, rejected) => {
          const i = new Image();
          i.onload = () => {
            resolved({w: i.width, h: i.height})
          };
          i.src = dataUri
        })
      },
      structArrayToJson(_result, _fields) {
        var result = new Array(_result[0].length).fill().map(() => JSON.parse('{}'));
        _fields.forEach((f, i) => _result[i].forEach((v, j) => result[j][f] = v));
        return result;
      },
      dateFmt: function (timestamp) {
        timestamp = Number(timestamp)
        return (timestamp && timestamp > 0) ? moment(timestamp).format('YYYY-MM-DD HH:mm') : null;
      },
      toPXL: function (amount) {
        return BigNumber(amount).div(Math.pow(10, 18)).toNumber();
      },
      appendDecimals: function (amount) {
        return BigNumber(amount).multipliedBy(Math.pow(10, 18));
      },
      toPercent: function (number) {
        return BigNumber(number).multipliedBy(100).toString();
      },
      toHexString: function (dec, padding = 40) {
        return BigNumber(0x10).pow(padding).plus(dec).toString(16).replace('1', '0x');
      },
      bytesToArray: function (bytes, spos, epos) {
        const arr = [];
        spos.forEach((o, i) => {
          let str = bytes.substring(spos[i], epos[i]);
          if (str.indexOf("0x") == -1) str = "0x" + str;
          arr.push(web3.utils.hexToUtf8(str));
        });
        return arr;
      },
    }
  }
}

export default Utils;
