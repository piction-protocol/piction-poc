// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Web3 from 'web3'

web3 = new Web3(web3.currentProvider);
import Vue from 'vue'
import App from './App'
import PictionNetworkPlugin from './plugins/piction-network-plugin'
import router from './router'
import store from './store'
import BootstrapVue from 'bootstrap-vue'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'
import Toast from 'vue2-toast';
import 'vue2-toast/lib/toast.css';

Vue.config.productionTip = false

Vue.use(BootstrapVue);
Vue.use(Toast);

(async () => {
  const accounts = await web3.eth.getAccounts();
  const account = accounts[0].toLowerCase();
  Vue.use(PictionNetworkPlugin, {account: account});

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
      web3.currentProvider.publicConfigStore.on('update', (provider) => {
        if (this.account != provider.selectedAddress.toLowerCase()) this.reload();
      });
    }
  });
})()
