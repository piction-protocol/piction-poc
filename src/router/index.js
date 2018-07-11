import Vue from 'vue'
import Router from 'vue-router'
import Comics from '@/components/comics/Comics'
import PostComics from '@/components/post-comics/PostComics'
import Episodes from '@/components/episodes/Episodes'
import Viewer from '@/components/viewer/Viewer'
import My from '@/components/my/My'

Vue.use(Router)

const router = new Router({
  mode: 'history',
  routes: [
    {path: '/', redirect: '/comics'},
    {path: '/comics', name: 'comics', component: Comics},
    {path: '/comics/posts', name: 'post-comics', component: PostComics},
    {path: '/comics/:comic_id', name: 'episodes', component: Episodes, props: true},
    {path: '/comics/:comic_id/episodes/:episode_id', name: 'viewer', component: Viewer, props: true},
    {path: '/trends', name: 'trends', component: Comics},
    {path: '/my', name: 'my', component: My},
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
