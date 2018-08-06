import PXL from './abi-class/PXL.js'
import pxlSource from '../../build/contracts/PXL.json'

import Account from './abi-class/Account.js'
import accountSource from '../../build/contracts/Account.json'

import Content from './abi-class/Content.js'
import contentSource from '../../build/contracts/Content.json'

import ContentInterface from './abi-class/ContentInterface.js'
import contentInterfaceSource from '../../build/contracts/ContentInterface.json'

import ContentsManager from './abi-class/ContentsManager.js'
import contentsManagerSource from '../../build/contracts/ContentsManager.json'

import Fund from './abi-class/Fund.js'
import fundSource from '../../build/contracts/Fund.json'

import FundManager from './abi-class/FundManager.js'
import fundManagerSource from '../../build/contracts/FundManager.json'

import SupporterPool from './abi-class/SupporterPool.js'
import supporterPoolSource from '../../build/contracts/SupporterPool.json'


const PictionNetworkPlugin = {
  install(Vue, options) {
    Vue.prototype.$contract = {};

    var network = '4447';

    Vue.prototype.$contract.pxl = new PXL(
      pxlSource.abi,
      pxlSource.networks[network].address,
      options.account
    )

    Vue.prototype.$contract.account = new Account(
      accountSource.abi,
      accountSource.networks[network].address,
      options.account
    )

    Vue.prototype.$contract.content = new Content(
      contentSource.abi,
      options.account,
      contentSource.bytecode
    )

    Vue.prototype.$contract.contentInterface = new ContentInterface(
      contentInterfaceSource.abi,
      options.account
    )

    Vue.prototype.$contract.contentsManager = new ContentsManager(
      contentsManagerSource.abi,
      contentsManagerSource.networks[network].address,
      options.account
    )

    Vue.prototype.$contract.fund = new Fund(
      fundSource.abi,
      options.account
    )

    Vue.prototype.$contract.fundManager = new FundManager(
      fundManagerSource.abi,
      fundManagerSource.networks[network].address,
      options.account
    )

    Vue.prototype.$contract.supporterPool = new SupporterPool(
      supporterPoolSource.abi,
      options.account
    )


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
      }
    }
  }
}

export default PictionNetworkPlugin;
