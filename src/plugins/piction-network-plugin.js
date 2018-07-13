import Account from './abi-class/Account.js'
import Content from './abi-class/Content.js'
import accountSource from '../../build/contracts/Account.json'
import contentSource from '../../build/contracts/Content.json'

const PictionNetworkPlugin = {
  install(Vue, options) {
    Vue.prototype.$contract = {};

    const account = new Account(
      accountSource.abi,
      accountSource.networks['3'].address,
      options.account
    )
    Vue.prototype.$contract.account = account

    const content = new Content(
      contentSource.abi,
      options.account,
      contentSource.bytecode
    )
    Vue.prototype.$contract.content = content

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
