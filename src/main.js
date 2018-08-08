// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Web3 from 'web3'

var provider = new Web3.providers.HttpProvider("http://127.0.0.1:9545");
window.web3 = new Web3(provider);
// web3 = new Web3(web3.currentProvider);
import Vue from 'vue'
import App from './App'
import PictionNetworkPlugin from './plugins/piction-network-plugin'
import FirebasePlugin from './plugins/firebase-plugin'
import Utils from './plugins/utils'
import router from './router'
import store from './store'
import BootstrapVue from 'bootstrap-vue'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'
import Toast from 'vue2-toast';
import 'vue2-toast/lib/toast.css';
import Datetime from 'vue-datetime'
import 'vue-datetime/dist/vue-datetime.css'
import councilSource from '../build/contracts/Council.json'
import councilInterfaceSource from '../build/contracts/CouncilInterface.json'

Vue.config.productionTip = false

Vue.use(BootstrapVue);
Vue.use(Datetime)
Vue.use(Toast);

(async () => {
  const accounts = await web3.eth.getAccounts();
  if (accounts.length == 0) {
    alert('Log in to the Metamask.')
  }
  const network = '4447';
  const council = new web3.eth.Contract(councilInterfaceSource.abi, councilSource.networks[network].address);
  const account = accounts[0].toLowerCase();
  const pxl = await council.methods.getToken().call();
  const contentsManager = await council.methods.getContentsManager().call();
  const fundManager = await council.methods.getFundManager().call();
  const accountManager = await council.methods.getAccountManager().call();
  console.log('=== address info ===')
  console.log(`account : ${account}`)
  console.log(`pxl : ${pxl}`)
  console.log(`contentsManager : ${contentsManager}`)
  console.log(`fundManager : ${fundManager}`)
  console.log(`accountManager : ${accountManager}`)

  Vue.use(PictionNetworkPlugin, {
    account: account,
    pxl: pxl,
    contentsManager: contentsManager,
    fundManager: fundManager,
    accountManager: accountManager
  });
  Vue.use(FirebasePlugin, {
    apiKey: "AIzaSyAmq4aDivflyokSUzdDCPmmKBu_3LFTmkU",
    authDomain: "battlecomics-dev.firebaseapp.com",
    databaseURL: "https://battlecomics-dev.firebaseio.com",
    projectId: "battlecomics-dev",
    storageBucket: "battlecomics-dev.appspot.com",
    messagingSenderId: "312406426508"
  });
  Vue.use(Utils);

  /* eslint-disable no-new */
  new Vue({
    el: '#app',
    router,
    store,
    data: {
      account: account
    },
    methods: {
      reload() {
        this.$router.push('/')
        window.location.reload()
      }
    },
    components: {App},
    template: '<App/>',
    created() {
      // web3.currentProvider.publicConfigStore.on('update', (provider) => {
      //   if (this.account != provider.selectedAddress.toLowerCase()) this.reload();
      // });
    }
  });
})()
