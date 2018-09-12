// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Web3 from 'web3'

var provider = new Web3.providers.HttpProvider("https://private.piction.network:8545/");
// var provider = new Web3.providers.HttpProvider("http://52.203.39.129:8545");
web3 = new Web3(provider);
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
import councilInterfaceSource from '../build/contracts/CouncilInterface.json'

Vue.config.productionTip = false

Vue.use(BootstrapVue);
Vue.use(Datetime)
Vue.use(Toast);
Vue.use(Vuex);

// web3.eth.accounts.wallet.add(`0x441CAA3B82A5ED3D67D96FCD6971491D1887C3B1B416A61D55D844DE48BF3FBF`);

(async () => {
  if (store.getters.isLoggedIn) {
    await web3.eth.accounts.wallet.add(store.getters.token);
  } else {
    console.log('not logged in')
  }

  const network = '2880';
  const councilAddress = councilSource.networks[network].address;
  const council = new web3.eth.Contract(councilInterfaceSource.abi, councilAddress);
  const pictionAddress = {};
  pictionAddress.council = councilAddress;
  pictionAddress.account = store.getters.publicKey.toLowerCase();
  pictionAddress.pxl = await council.methods.getToken().call();
  pictionAddress.pixelDistributor = await council.methods.getPixelDistributor().call();
  pictionAddress.userPaybackPool = await council.methods.getUserPaybackPool().call();
  pictionAddress.depositPool = await council.methods.getDepositPool().call();
  pictionAddress.contentsManager = await council.methods.getContentsManager().call();
  pictionAddress.fundManager = await council.methods.getFundManager().call();
  pictionAddress.accountManager = await council.methods.getAccountManager().call();
  pictionAddress.report = await council.methods.getReport().call();
  const pictionValue = {}
  pictionValue.initialDeposit = Number(await council.methods.getInitialDeposit().call());
  pictionValue.reportRegistrationFee = Number(await council.methods.getReportRegistrationFee().call());
  pictionValue.defaultGas = 4700000;
  console.log('pictionAddress', pictionAddress);
  console.log('pictionValue', pictionValue);
  Vue.use(PictionNetworkPlugin, pictionAddress, pictionValue);

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