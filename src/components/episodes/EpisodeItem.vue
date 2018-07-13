<template>
  <router-link :to="{ name: 'viewer', params: { content_id: content_id, episode_id:episode.id }}" class="episode">
      <b-row class="text-left" align-v="center">
        <b-col cols="3"><img :src="episode.thumbnail"/></b-col>
        <b-col>{{episode.title}}</b-col>
      </b-row>
  </router-link>
</template>

<script>
  export default {
    props: ['content_id', 'episode'],
    data() {
      return {}
    },
    methods: {}
  }
</script>

<style scoped>
  img {
    width: 100%;
  }

  .episode {
    display: block;
    padding: 2px;
  }
</style>
