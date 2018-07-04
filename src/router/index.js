import Vue from 'vue'
import Router from 'vue-router'
import source from '../../build/contracts/Account.json'
import Toons from '@/components/Toons'
import Auth from '@/components/Auth'

Vue.use(Router)

const requireAuth = async (to, from, next) => {
  const account = await web3.eth.getAccounts();
  const contract = new web3.eth.Contract(source.abi, source.networks['3'].address);
  const result = await contract.methods.getUserAddress(account[0]).call();
  if(result == 0) {
    console.log('error')
  }
  return next();
}

const router = new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      redirect: '/toons',
    },
    {
      path: '/toons',
      name: 'Toons',
      component: Toons,
    },
    {
      path: '/auth',
      name: 'Auth',
      component: Auth,
      beforeEnter: requireAuth
    }
  ]
})
export default router;
