<template>
  <div style="max-width: 720px; padding-bottom: 20px">
    <img v-for="cut in episode.cuts" :src="cut" style="max-width: 720px;"/>
    <router-link class="back" :to="{ name: 'episodes', params: { comic_id: comic_id }}">{{$t('목록으로')}}</router-link>
  </div>
</template>

<script>
  import Episode from '@models/Episode'

  export default {
    props: ['comic_id', 'episode_id'],
    data() {
      return {
        episode: new Episode()
      }
    },
    methods: {},
    async created() {
      this.episode = await this.$contract.apiContents.getEpisode(this.comic_id, this.episode_id);
    }
  }
</script>

<style scoped>
  div {
    text-align: center;
  }

  img {
    display: block;
    width: 100%;
  }

  .back {
    background: black;
    color: white !important;
    margin: 0;
    padding: 0;
    position: fixed;
    left: 0;
    right: 0;
    height: 3rem;
    line-height: 3rem;
    bottom: 0;
  }
</style>
