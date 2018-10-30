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
import PublishSupporterNew from '@/components/publish/comics/supporter/New'
import PublishSupporterEdit from '@/components/publish/comics/supporter/Edit'
import PublishSupporterShow from '@/components/publish/comics/supporter/Show'
// my
import AccountIndex from '@/components/my/account/Index'
import UserPaybackIndex from '@/components/my/userpayback/Index'
import MyFundComicIndex from '@/components/my/fund-comics/Index'
import MyFundComicShow from '@/components/my/fund-comics/Show'
import MyReportIndex from '@/components/my/reports/Index'
// council
import CouncilIndex from '@/components/council/Index'
import CouncilDetailIndex from '@/components/council/detail/Index'

Vue.use(Router)

const router = new Router({
  mode: 'history',
  routes: [
    {path: '/', redirect: '/comics'},
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
        {path: 'supporter/new', name: 'publish-new-supporter', component: PublishSupporterNew, props: true},
        {path: 'supporter/:fund_id/edit', name: 'publish-edit-supporter', component: PublishSupporterEdit, props: true},
        {path: 'supporter/:fund_id/show', name: 'publish-show-supporter', component: PublishSupporterShow, props: true},
      ]
    },
    {
      path: '/publish/comics/:comic_id/episodes/new',
      name: 'publish-new-episode',
      component: PublishEpisodeNew,
      props: true
    },
    {
      path: '/publish/comics/:comic_id/episodes/:episode_id/edit',
      name: 'publish-edit-episode',
      component: PublishEpisodeEdit,
      props: true
    },
    // council
    {path: '/council', name: 'council', component: CouncilIndex},
    {path: '/comics/:comic_id', redirect: '/council/:comic_id/detail'},
    {path: '/council/:comic_id/detail', name: 'council-detail', component: CouncilDetailIndex, props: true},
    // my
    {path: '/account', name: 'account', component: AccountIndex},
    {path: '/user-payback', name: 'user-payback', component: UserPaybackIndex},
    {path: '/my/fund-comics', name: 'my-fund-comics', component: MyFundComicIndex},
    {path: '/my/fund-comics/:comic_id/show', name: 'my-show-fund-comic', component: MyFundComicShow, props: true},
    {path: '/my/reports', name: 'my-reports', component: MyReportIndex},
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

