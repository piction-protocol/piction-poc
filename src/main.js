// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Web3 from 'web3'

var provider = new Web3.providers.WebsocketProvider('ws://127.0.0.1:9545/')
// var provider = new Web3.providers.WebsocketProvider('ws://54.249.219.254:8546')
window.web3 = new Web3(provider);

import Vue from 'vue'
import Vuex from 'vuex'
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

Vue.config.productionTip = false

Vue.use(BootstrapVue);
Vue.use(Datetime)
Vue.use(Toast);
Vue.use(Vuex);

const getPictionConfig = async (network) => {
  const returnConfig = {};
  const councilAddress = councilSource.networks[network].address;
  const council = new web3.eth.Contract(councilSource.abi, councilAddress);
  const pictionConfig = await council.methods.getPictionConfig().call();

  returnConfig.account = store.getters.publicKey.toLowerCase();

  returnConfig.pictionAddress = {
    council: councilAddress,
    pxl: pictionConfig.pxlAddress_,
    userPaybackPool: pictionConfig.pictionAddress_[0],
    depositPool: pictionConfig.pictionAddress_[1],
    pixelDistributor: pictionConfig.pictionAddress_[2],
    marketer: pictionConfig.pictionAddress_[3],
    report: pictionConfig.pictionAddress_[4],
  };

  returnConfig.managerAddress = {
    contentsManager: pictionConfig.managerAddress_[0],
    fundManager: pictionConfig.managerAddress_[1],
    accountManager: pictionConfig.managerAddress_[2],
  };

  returnConfig.pictionValue = {
    initialDeposit: Number(pictionConfig.pictionValue_[0]),
    reportRegistrationFee: Number(pictionConfig.pictionValue_[1]),
    defaultGas: 6000000,
  };

  return returnConfig;
}

(async () => {
  if (store.getters.isLoggedIn) {
    await web3.eth.accounts.wallet.add(store.getters.token);
  } else {
    console.log('not logged in')
  }
  const pictionConfig = await getPictionConfig(4447) // local: 4447 / private: 2880
  console.log(pictionConfig)
  Vue.use(PictionNetworkPlugin, pictionConfig);

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
    methods: {
      reload() {
        this.$router.push('/')
        window.location.reload()
      }
    },
    components: {App},
    template: '<App/>',
    created() {
    }
  });
})()