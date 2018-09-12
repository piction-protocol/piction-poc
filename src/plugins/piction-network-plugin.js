import PXL from './abi-class/PXL.js'
import pxlSource from '../../build/contracts/PXL.json'

import AccountManager from './abi-class/AccountManager.js'
import accountManagerSource from '../../build/contracts/AccountManager.json'

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

import Report from './abi-class/Report.js'
import reportSource from '../../build/contracts/Report.json'

import DepositPool from './abi-class/DepositPool.js'
import depositPoolSource from '../../build/contracts/DepositPool.json'

import UserPaybackPool from './abi-class/UserPaybackPool.js'
import userPaybackPoolSource from '../../build/contracts/UserPaybackPool.json'

import Council from './abi-class/Council.js'
import councilSource from '../../build/contracts/Council.json'

const PictionNetworkPlugin = {
  install(Vue, pictionAddress, pictionValue) {
    Vue.prototype.pictionAddress = pictionAddress;
    Vue.prototype.pictionValue = pictionValue;

    Vue.prototype.$contract = {};

    Vue.prototype.$contract.pxl = new PXL(
      pxlSource.abi,
      pictionAddress.pxl,
      pictionAddress.account,
      pictionValue.defaultGas
    )

    Vue.prototype.$contract.accountManager = new AccountManager(
      accountManagerSource.abi,
      pictionAddress.accountManager,
      pictionAddress.account,
      pictionValue.defaultGas
    )

    Vue.prototype.$contract.contentInterface = new ContentInterface(
      contentInterfaceSource.abi,
      pictionAddress.account,
      pictionValue.defaultGas
    )

    Vue.prototype.$contract.contentsManager = new ContentsManager(
      contentsManagerSource.abi,
      pictionAddress.contentsManager,
      pictionAddress.account,
      pictionValue.defaultGas
    )

    Vue.prototype.$contract.fund = new Fund(
      fundSource.abi,
      pictionAddress.account,
      pictionValue.defaultGas
    )

    Vue.prototype.$contract.fundManager = new FundManager(
      fundManagerSource.abi,
      pictionAddress.fundManager,
      pictionAddress.account,
      pictionValue.defaultGas
    )

    Vue.prototype.$contract.supporterPool = new SupporterPool(
      supporterPoolSource.abi,
      pictionAddress.account,
      pictionValue.defaultGas
    )

    Vue.prototype.$contract.report = new Report(
      reportSource.abi,
      pictionAddress.report,
      pictionAddress.account,
      pictionValue.defaultGas
    )

    Vue.prototype.$contract.depositPool = new DepositPool(
      depositPoolSource.abi,
      pictionAddress.depositPool,
      pictionAddress.account,
      pictionValue.defaultGas
    )

    Vue.prototype.$contract.userPaybackPool = new UserPaybackPool(
      userPaybackPoolSource.abi,
      pictionAddress.userPaybackPool,
      pictionAddress.account,
      pictionValue.defaultGas
    )

    Vue.prototype.$contract.council = new Council(
      councilSource.abi,
      pictionAddress.council,
      pictionAddress.account,
      pictionValue.defaultGas
    )
  }
}

export default PictionNetworkPlugin;
