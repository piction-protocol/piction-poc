import Vue from 'vue'
import Router from 'vue-router'
// contents
import ContentIndex from '@/components/contents/Index'
import ContentNew from '@/components/contents/New'
import ContentShow from '@/components/contents/Show'
import ContentEdit from '@/components/contents/Edit'
// episodes
import EpisodeIndex from '@/components/episodes/Index'
import EpisodeNew from '@/components/episodes/New'
// viewer
import ViewerIndex from '@/components/viewer/Index'
// fund
import FundIndex from '@/components/funds/Index'
import FundNew from '@/components/funds/New'
import FundShow from '@/components/funds/Show'
// my
import MyIndex from '@/components/my/Index'
import MyInfoIndex from '@/components/my/info/Index'
import MyContentsIndex from '@/components/my/contents/Index'

Vue.use(Router)

const router = new Router({
  mode: 'history',
  routes: [
    {path: '/', redirect: '/contents'},
    // contents
    {path: '/contents', name: 'contents', component: ContentIndex},
    {path: '/contents/new', name: 'new-content', component: ContentNew},
    {path: '/contents/:content_id/show', name: 'show-content', component: ContentShow, props: true},
    {path: '/contents/:content_id/edit', name: 'edit-content', component: ContentEdit, props: true},
    // episodes
    {path: '/contents/:content_id', redirect: '/contents/:content_id/episodes'},
    {path: '/contents/:content_id/episodes', name: 'episodes', component: EpisodeIndex, props: true},
    {path: '/contents/:content_id/episodes/new', name: 'new-episode', component: EpisodeNew, props: true},
    // viewer
    {path: '/contents/:content_id/episodes/:episode_id', name: 'viewer', component: ViewerIndex, props: true},
    // trends
    {path: '/funds', name: 'funds', component: FundIndex},
    // funds
    {path: '/contents/:content_id/funds/new', name: 'new-fund', component: FundNew, props: true},
    {path: '/contents/:content_id/funds/:fund_id/show', name: 'show-fund', component: FundShow, props: true},
    // my
    {
      path: '/my', component: MyIndex,
      children: [
        {path: '', name: 'my', component: MyInfoIndex},
        {path: 'contents', name: 'my-contents', component: MyContentsIndex},
      ]
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
})

export default router;
