import Vue from 'vue'
import Router from 'vue-router'
import store from '../store/index.js'
// sign
import Login from '@/components/sign/Login'
import Join from '@/components/sign/Join'
// contents
import ContentIndex from '@/components/contents/Index'
import ContentNew from '@/components/contents/New'
import ContentShow from '@/components/contents/Show'
import ContentEdit from '@/components/contents/Edit'
// episodes
import EpisodeIndex from '@/components/episodes/Index'
import EpisodeNew from '@/components/episodes/New'
import EpisodeShow from '@/components/episodes/Show'
import EpisodeEdit from '@/components/episodes/Edit'
// fund
import FundIndex from '@/components/funds/Index'
import FundNew from '@/components/funds/New'
import FundShow from '@/components/funds/Show'
// my
import MyIndex from '@/components/my/Index'
import AccountIndex from '@/components/my/account/Index'
import PayckbackPoolIndex from '@/components/my/paybackpool/Index'
import MyReportIndex from '@/components/my/reports/Index'
import MyContentsIndex from '@/components/my/contents/Index'
import MyContentsShow from '@/components/my/contents/Show'
// council
import CouncilIndex from '@/components/council/Index'

Vue.use(Router)

const router = new Router({
  mode: 'history',
  routes: [
    {path: '/', redirect: '/my'},
    // login
    {path: '/login', name: 'login', component: Login},
    {path: '/join', name: 'join', component: Join},
    // contents
    {path: '/contents', name: 'contents', component: ContentIndex},
    {path: '/contents/new', name: 'new-content', component: ContentNew},
    {path: '/contents/:content_id/show', name: 'show-content', component: ContentShow, props: true},
    {path: '/contents/:content_id/edit', name: 'edit-content', component: ContentEdit, props: true},
    // episodes
    {path: '/contents/:content_id', redirect: '/contents/:content_id/episodes'},
    {path: '/contents/:content_id/episodes', name: 'episodes', component: EpisodeIndex, props: true},
    {path: '/contents/:content_id/episodes/new', name: 'new-episode', component: EpisodeNew, props: true},
    {path: '/contents/:content_id/episodes/:episode_id', name: 'show-episode', component: EpisodeShow, props: true},
    {
      path: '/contents/:content_id/episodes/:episode_id/edit',
      name: 'edit-episode',
      component: EpisodeEdit,
      props: true
    },
    // trends
    {
      path: '/funds', name: 'funds', component: FundIndex,
      props: (route) => ({filter: route.query.filter})
    },
    // funds
    {path: '/contents/:content_id/funds/new', name: 'new-fund', component: FundNew, props: true},
    {path: '/contents/:content_id/funds/:fund_id/show', name: 'show-fund', component: FundShow, props: true},
    // my
    {
      path: '/my', component: MyIndex,
      children: [
        {path: '', name: 'account', component: AccountIndex},
        {path: 'payback-pool', name: 'payback-pool', component: PayckbackPoolIndex},
        {
          path: 'my-reports', name: 'my-reports', component: MyReportIndex,
          props: (route) => ({page: route.query.page ? Number(route.query.page) : 1, filter: route.query.filter})
        },
        {
          path: 'contents', name: 'my-contents', component: MyContentsIndex,
          children: [
            {path: ':content_id', name: 'show-my-content', component: MyContentsShow, props: true},
          ]
        },
      ]
    },
    // council
    {
      path: '/council',
      name: 'council',
      component: CouncilIndex,
      props: (route) => ({page: route.query.page ? Number(route.query.page) : 1, filter: route.query.filter})
    },
    // not found
    {path: '*', component: {template: '<h1 align="center">Not Found</h1>'}}
  ],
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else {
      return {x: 0, y: 0}
    }
  }
});

router.beforeEach((to, from, next) => {
  if (to.name == 'login' || to.name == 'join') {
    if (store.getters.isLoggedIn) {
      next(to.query.redirect);
    } else {
      next();
    }
  } else {
    if (store.getters.isLoggedIn) {
      next();
    } else {
      next({
        path: '/login',
        query: {redirect: to.fullPath}
      });
    }
  }

})

export default router;
