import PXL from '@contract-class/PXL'
import AccountManager from '@contract-class/AccountManager'
import Fund from '@contract-class/Fund'
import Report from '@contract-class/Report'
import DepositPool from '@contract-class/DepositPool'
import UserPaybackPool from '@contract-class/UserPaybackPool'
import Council from '@contract-class/Council'
import ApiReport from '@contract-class/ApiReport'
import ApiContents from '@contract-class/ApiContents'
import ApiFund from '@contract-class/ApiFund'
import ContentsManager from '@contract-class/ContentsManager'

const PictionNetworkPlugin = {
  install(Vue, pictionConfig) {


    Vue.prototype.web3 = window.web3;

    console.log(pictionConfig);
    Vue.prototype.pictionConfig = pictionConfig;
    Vue.prototype.$contract = {};

    Vue.prototype.$contract.apiReport = new ApiReport(
      pictionConfig.apiAddress.apiReport,
      pictionConfig.account,
      pictionConfig.pictionValue.defaultGas
    )

    Vue.prototype.$contract.apiContents = new ApiContents(
      pictionConfig.apiAddress.apiContents,
      pictionConfig.account,
      pictionConfig.pictionValue.defaultGas
    )

    Vue.prototype.$contract.apiFund = new ApiFund(
      pictionConfig.apiAddress.apiFund,
      pictionConfig.account,
      pictionConfig.pictionValue.defaultGas
    )

    Vue.prototype.$contract.pxl = new PXL(
      pictionConfig.pictionAddress.pxl,
      pictionConfig.account,
      pictionConfig.pictionValue.defaultGas
    )

    Vue.prototype.$contract.accountManager = new AccountManager(
      pictionConfig.managerAddress.accountManager,
      pictionConfig.account,
      pictionConfig.pictionValue.defaultGas
    )

    Vue.prototype.$contract.contentsManager = new ContentsManager(
      pictionConfig.managerAddress.contentsManager,
      pictionConfig.account,
      pictionConfig.pictionValue.defaultGas
    )

    Vue.prototype.$contract.fund = new Fund(
      pictionConfig.account,
      pictionConfig.pictionValue.defaultGas
    )

    Vue.prototype.$contract.report = new Report(
      pictionConfig.pictionAddress.report,
      pictionConfig.account,
      pictionConfig.pictionValue.defaultGas
    )

    Vue.prototype.$contract.depositPool = new DepositPool(
      pictionConfig.pictionAddress.depositPool,
      pictionConfig.account,
      pictionConfig.pictionValue.defaultGas
    )

    Vue.prototype.$contract.userPaybackPool = new UserPaybackPool(
      pictionConfig.pictionAddress.userPaybackPool,
      pictionConfig.account,
      pictionConfig.pictionValue.defaultGas
    )

    Vue.prototype.$contract.council = new Council(
      pictionConfig.pictionAddress.council,
      pictionConfig.account,
      pictionConfig.pictionValue.defaultGas
    )
  }
}

export default PictionNetworkPlugin;
