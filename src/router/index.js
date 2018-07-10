import Vue from 'vue'
import Router from 'vue-router'
import Join from '@/components/Join'
import Comics from '@/components/comics/Comics'
import PostComics from '@/components/post-comics/PostComics'
import Episodes from '@/components/comics/episodes/Episodes'
import Viewer from '@/components/comics/episodes/viewer/Viewer'
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
    {path: '/join', name: 'join', component: Join,},
    {path: '/', redirect: '/comics'},
    {path: '/comics', name: 'comics', component: Comics},
    {path: '/comics/posts', name: 'comics-posts', component: PostComics},
    {path: '/comics/:comic_id', name: 'episodes', component: Episodes, props: true},
    {path: '/comics/:comic_id/episodes/:episode_id', name: 'viewer', component: Viewer, props: true},
    {path: '/my', name: 'my', component: My, beforeEnter: requireAuth}
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
