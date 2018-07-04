import Vue from 'vue'
import Router from 'vue-router'
import Toons from '@/components/Toons'
import Auth from '@/components/Auth'

Vue.use(Router)

const requireAuth = async (to, from, next) => {
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
