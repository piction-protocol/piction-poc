import Account from './abi-class/Account.js'
import accountSource from '../../build/contracts/Account.json'

const PictionNetworkPlugin = {
  install(Vue, options) {
    Vue.prototype.$contract = {};

    const account = new Account(
      accountSource.abi,
      accountSource.networks['3'].address,
      options.account
    )
    Vue.prototype.$contract.account = account
  }
}

export default PictionNetworkPlugin;
