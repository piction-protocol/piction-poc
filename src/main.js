// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Web3 from 'web3'

web3 = new Web3(web3.currentProvider);
import Vue from 'vue'
import App from './App'
import router from './router'
import store from './store'
import BootstrapVue from 'bootstrap-vue'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

Vue.config.productionTip = false

Vue.use(BootstrapVue);

(async () => {
  const accounts = await web3.eth.getAccounts();

  /* eslint-disable no-new */
  new Vue({
    el: '#app',
    router,
    store,
    data: {account: accounts[0]},
    components: {App},
    template: '<App/>',
    async created() {
      web3.currentProvider.publicConfigStore.on('update', (provider) => {
        if (this.account.toLowerCase() != provider.selectedAddress.toLowerCase()) {
          this.$router.push('/')
          window.location.reload()
        }
      });
    },
  });
})()
