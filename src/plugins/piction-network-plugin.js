import Account from './abi-class/Account.js'
import Content from './abi-class/Content.js'
import ContentInterface from './abi-class/ContentInterface.js'
import ContentsManager from './abi-class/ContentsManager.js'
import accountSource from '../../build/contracts/Account.json'
import contentSource from '../../build/contracts/Content.json'
import contentsManagerSource from '../../build/contracts/ContentsManager.json'
import ContentInterfaceSource from '../../build/contracts/ContentInterface.json'

const PictionNetworkPlugin = {
  install(Vue, options) {
    Vue.prototype.$contract = {};

    Vue.prototype.$contract.account = new Account(
      accountSource.abi,
      accountSource.networks['4447'].address,
      options.account
    )

    Vue.prototype.$contract.content = new Content(
      contentSource.abi,
      options.account,
      contentSource.bytecode
    )

    Vue.prototype.$contract.contentsManager = new ContentsManager(
      contentsManagerSource.abi,
      contentsManagerSource.networks['4447'].address,
      options.account
    )

    Vue.prototype.$contract.contentInterface = new ContentInterface(
      ContentInterfaceSource.abi,
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
