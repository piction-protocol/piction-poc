import Vue from 'vue'
import Router from 'vue-router'
// contents
import ContentIndex from '@/components/contents/Index'
import ContentNew from '@/components/contents/New'
import ContentShow from '@/components/contents/Show'
import ContentEdit from '@/components/contents/Edit'
// episodes
import EpisodeIndex from '@/components/episodes/Index'
// viewer
import ViewerIndex from '@/components/viewer/Index'
// my
import MyIndex from '@/components/my/Index'

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
    // viewer
    {path: '/contents/:content_id/episodes/:episode_id', name: 'viewer', component: ViewerIndex, props: true},
    // trends
    {path: '/trends', name: 'trends', component: ContentIndex},
    // my
    {path: '/my', name: 'my', component: MyIndex},
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
