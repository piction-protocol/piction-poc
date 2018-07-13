import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

const router = new Router({
  mode: 'history',
  routes: [
    {path: '/', redirect: '/contents'},
    // contents
    {
      path: '/contents', name: 'contents',
      component: require('@/components/contents/Index').default
    }, {
      path: '/contents/new', name: 'new-content',
      component: require('@/components/contents/New').default
    }, {
      path: '/contents/:content_id/show', name: 'show-content', props: true,
      component: require('@/components/contents/Show').default
    }, {
      path: '/contents/:content_id/edit', name: 'edit-content', props: true,
      component: require('@/components/contents/Edit').default
    },
    // episodes
    {
      path: '/contents/:content_id', redirect: '/contents/:content_id/episodes'
    }, {
      path: '/contents/:content_id/episodes', name: 'episodes', props: true,
      component: require('@/components/episodes/Index').default
    },
    // viewer
    {
      path: '/contents/:content_id/episodes/:episode_id', name: 'viewer', props: true,
      component: require('@/components/viewer/Index').default
    },
    // trends
    {
      path: '/trends', name: 'trends',
      component: require('@/components/contents/Index').default
    },
    // my
    {
      path: '/my', name: 'my',
      component: require('@/components/contents/Index').default
    },
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
