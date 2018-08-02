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


const PictionNetworkPlugin = {
  install(Vue, options) {
    Vue.prototype.$contract = {};

    var network = '4447';

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


    Vue.prototype.$utils = {
      getImageDimensions(dataUri) {
        return new Promise((resolved, rejected) => {
          const i = new Image();
          i.onload = () => {
            resolved({w: i.width, h: i.height})
          };
          i.src = dataUri
        })
      }
    }
  }
}

export default PictionNetworkPlugin;
