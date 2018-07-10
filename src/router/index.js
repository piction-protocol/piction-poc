import Vue from 'vue'
import Router from 'vue-router'
import Join from '@/components/Join'
import Toons from '@/components/Toons'
import My from '@/components/My'

Vue.use(Router)

const requireAuth = async (to, from, next) => {
  const app = await router.app;
  const result = await app.$contract.account.getUserName(app.account);
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
