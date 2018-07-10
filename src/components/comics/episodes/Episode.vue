<template>
  <router-link :to="{ name: 'viewer', params: { comic_id: comic_id, episode_id:episode.id }}" class="episode">
      <b-row class="text-left" align-v="center">
        <b-col cols="3"><img :src="episode.thumbnail"/></b-col>
        <b-col>{{episode.title}}</b-col>
      </b-row>
  </router-link>
  <!--
  <router-link :to="{ name: 'viewer', params: { comic_id: comic_id, episode_id:episode.id }}" class="episode">
    <b-card :title="episode.title"
            :img-src="episode.thumbnail"
            img-alt="Image"
            img-left
            tag="article"
            style="max-width: 20rem;"
            class="mb-2">
      <p class="card-text">
        {{episode.description}}
      </p>
    </b-card>
  </router-link>
  -->
</template>

<script>
  export default {
    name: 'Episode',
    props: ['comic_id', 'episode'],
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
