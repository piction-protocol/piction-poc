// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Web3 from 'web3'

// local: ws://127.0.0.1:9545 / private: ws://54.249.219.254:8546
var provider = new Web3.providers.WebsocketProvider('ws://54.249.219.254:8546')
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
import Loading from 'vue-loading-overlay';
import 'vue-loading-overlay/dist/vue-loading.css';
import Toasted from 'vue-toasted';
import Datetime from 'vue-datetime'
import 'vue-datetime/dist/vue-datetime.css'
import config from './config.js'

Vue.config.productionTip = false

Vue.use(BootstrapVue);
Vue.use(Datetime);
Vue.use(Loading, {
  container: null,
  loader: 'dots',
  color: '#0095FF',
  opacity: 0.7,
  backgroundColor: '#000000'
});
Vue.use(Toasted, {
  iconPack: 'material', // set your iconPack, defaults to material. material|fontawesome
  theme: "primary",
  position: "top-right",
  duration: 5000,
});
Vue.use(Vuex);

(async () => {
  if (store.getters.isLoggedIn) {
    await web3.eth.accounts.wallet.add(store.getters.token);
  } else {
    console.log('not logged in')
  }
  Vue.use(Utils);
  // local: 4447 / private: 2880
  Vue.use(PictionNetworkPlugin, await config(2880));
  Vue.use(FirebasePlugin, {
    apiKey: "AIzaSyAmq4aDivflyokSUzdDCPmmKBu_3LFTmkU",
    authDomain: "battlecomics-dev.firebaseapp.com",
    databaseURL: "https://battlecomics-dev.firebaseio.com",
    projectId: "battlecomics-dev",
    storageBucket: "battlecomics-dev.appspot.com",
    messagingSenderId: "312406426508"
  });

  /* eslint-disable no-new */
  new Vue({
    el: '#app',
    router,
    store,
    data() {
      return {
        now: new Date().getTime(),
      }
    },
    methods: {
      reload() {
        this.$router.push('/')
        window.location.reload()
      }
    },
    components: {App},
    template: '<App/>',
    async created() {
      setInterval(() => {
        this.now = new Date().getTime();
      }, 1000);
    }
  });
})()