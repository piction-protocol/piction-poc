import Vue from 'vue'
import Router from 'vue-router'
import store from '../store/index.js'
// sign
import Login from '@/components/sign/Login'
import Join from '@/components/sign/Join'
// comics
import ComicIndex from '@/components/comics/Index'
// episodes
import EpisodeIndex from '@/components/episodes/Index'
import EpisodeShow from '@/components/episodes/Show'

// fund
import FundIndex from '@/components/funds/Index'
import FundNew from '@/components/funds/New'
import FundShow from '@/components/funds/Show'
// publish
import PublishComicIndex from '@/components/publish/comics/Index'
import PublishComicShow from '@/components/publish/comics/Show'
import PublishComicNew from '@/components/publish/comics/New'
import PublishComicEdit from '@/components/publish/comics/Edit'
import PublishEpisodeIndex from '@/components/publish/comics/episodes/Index'
import PublishEpisodeNew from '@/components/publish/comics/episodes/New'
import PublishEpisodeEdit from '@/components/publish/comics/episodes/Edit'
import PublishComicInfoIndex from '@/components/publish/comics/info/Index'
import PublishSupporterIndex from '@/components/publish/comics/supporter/Index'
import PublishSupporterNew from '@/components/publish/comics/supporter/New'
import PublishSupporterEdit from '@/components/publish/comics/supporter/Edit'
import PublishSupporterProgress from '@/components/publish/comics/supporter/result/Progress'
import PublishSupporterSuccess from '@/components/publish/comics/supporter/result/Success'
import PublishSupporterFail from '@/components/publish/comics/supporter/result/Fail'
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
    {
      path: '/comics', name: 'comics', component: ComicIndex,
      props: (route) => ({genre: route.query.genre})
    },
    // episodes
    {path: '/comics/:comic_id', redirect: '/contents/:content_id/episodes'},
    {path: '/comics/:comic_id/episodes', name: 'episodes', component: EpisodeIndex, props: true},
    {path: '/comics/:comic_id/episodes/:episode_id', name: 'show-episode', component: EpisodeShow, props: true},
    // funds
    {path: '/funds', name: 'funds', component: FundIndex},
    {path: '/comics/:comic_id/funds/new', name: 'new-fund', component: FundNew, props: true},
    {path: '/funds/:fund_id/show', name: 'show-fund', component: FundShow, props: true},
    // publish
    {path: '/publish/comics', name: 'publish-comics', component: PublishComicIndex},
    {path: '/publish/comics/new', name: 'publish-new-comic', component: PublishComicNew},
    {path: '/publish/comics/:comic_id/edit', name: 'publish-edit-comic', component: PublishComicEdit, props: true},
    {
      path: '/publish/comics/:comic_id', component: PublishComicShow, props: true,
      children: [
        {path: 'episodes', name: 'publish-episodes', component: PublishEpisodeIndex, props: true},
        {path: 'info', name: 'publish-info', component: PublishComicInfoIndex, props: true},
        {path: 'supporter', name: 'publish-supporter', component: PublishSupporterIndex, props: true},
        {path: 'supporter/new', name: 'publish-new-supporter', component: PublishSupporterNew, props: true},
        {path: 'supporter/:fund_id/edit', name: 'publish-edit-supporter', component: PublishSupporterEdit, props: true},
        {path: 'supporter/:fund_id', name: 'publish-progress-supporter', component: PublishSupporterProgress, props: true},
        {path: 'supporter/:fund_id/success', name: 'publish-success-supporter', component: PublishSupporterSuccess, props: true},
        {path: 'supporter/:fund_id/fail', name: 'publish-fail-supporter', component: PublishSupporterFail, props: true},
      ]
    },
    {path: '/publish/comics/:comic_id/episodes/new', name: 'publish-new-episode', component: PublishEpisodeNew, props: true},
    {path: '/publish/comics/:comic_id/episodes/:episode_id/edit', name: 'publish-edit-episode', component: PublishEpisodeEdit, props: true},
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
