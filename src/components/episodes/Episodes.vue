<template>
  <div>
    <b-breadcrumb :items="items"/>
    <Episode v-for="episode in episodes"
             :episode="episode"
             :comic_id="comic_id"
             :key="episode.id"/>
  </div>
</template>

<script>
  import Episode from './Episode'

  export default {
    name: 'Episodes',
    props: ['comic_id'],
    components: {Episode},
    data() {
      return {
        episodes: [],
        items: [{
          text: 'Comics',
          to: {name: 'comics'}
        }, {
          text: `Comic ${this.comic_id}`,
          active: true
        }]
      }
    },
    methods: {},
    created() {
      Array(20).fill().forEach((obj, index) => {
        let id = index + 1;
        let episode = {
          id: id,
          title: `Episode ${id}`,
          thumbnail: `http://images.battlecomics.co.kr/webtoon/677/image/image-webtoonid_677-w_720-h_360-t_20171108144640.jpg`,
          description: `Description ${id}`,
          writer: `skkwon`
        }
        this.episodes.push(episode);
      });
    }
  }
</script>

<style scoped>

</style>
