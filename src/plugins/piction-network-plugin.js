import PXL from './abi-class/PXL.js'
import pxlSource from '../../build/contracts/PXL.json'

import AccountManager from './abi-class/AccountManager.js'
import accountManagerSource from '../../build/contracts/AccountManager.json'

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

    Vue.prototype.pictionAddress = options;

    Vue.prototype.$contract.pxl = new PXL(
      pxlSource.abi,
      options.pxl,
      options.account
    )

    Vue.prototype.$contract.accountManager = new AccountManager(
      accountManagerSource.abi,
      options.accountManager,
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
      options.contentsManager,
      options.account
    )

    Vue.prototype.$contract.fund = new Fund(
      fundSource.abi,
      options.account
    )

    Vue.prototype.$contract.fundManager = new FundManager(
      fundManagerSource.abi,
      options.fundManager,
      options.account
    )

    Vue.prototype.$contract.supporterPool = new SupporterPool(
      supporterPoolSource.abi,
      options.account
    )
  }
}

export default PictionNetworkPlugin;
