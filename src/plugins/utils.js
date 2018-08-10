import moment from 'moment';
import BigNumber from 'bignumber.js'

const Utils = {
  install(Vue, options) {
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
        return (timestamp && timestamp > 0) ? moment(timestamp).format('YYYY-MM-DD HH:mm') : null;
      },
      toPXL: function (amount) {
        return BigNumber(amount).div(Math.pow(10, 18)).toString();
      },
      toDOT: function (amount) {
        return BigNumber(amount).multipliedBy(Math.pow(10, 18)).toString();
      },
      toPercent: function (number) {
        return BigNumber(number).multipliedBy(100).toString();
      }
    }
  }
}

export default Utils;
