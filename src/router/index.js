import Vue from 'vue'
import Router from 'vue-router'
import source from '../../build/contracts/Account.json'
import Join from '@/components/Join'
import Toons from '@/components/Toons'
import My from '@/components/My'

Vue.use(Router)

async function requireAuth(to, from, next) {
  const app = await router.app;
  const contract = new web3.eth.Contract(source.abi, source.networks['3'].address);
  const result = await contract.methods.getUserName(app.account).call();
  if (!result) {
    return next({path: '/join'})
  } else {
    return next();
  }
}

const router = new Router({
  mode: 'history',
  routes: [
    {
      path: '/join',
      name: 'Join',
      component: Join,
    },
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
      path: '/my',
      name: 'My',
      component: My,
      beforeEnter: requireAuth,
    }
  ]
})

export default router;
