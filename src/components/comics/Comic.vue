<template>
  <router-link :to="{ name: 'episodes', params: { comic_id: comic.id }}" class="comic">
    <b-card :title="comic.title"
            :img-src="comic.thumbnail"
            img-alt="Image"
            img-top
            tag="article"
            style="max-width: 20rem;"
            class="mb-2">
      <p class="card-text">
        {{comic.description}}
      </p>
    </b-card>
  </router-link>
</template>

<script>
  export default {
    name: 'Comic',
    props: ['comic'],
    data() {
      return {}
    },
    methods: {}
  }
</script>

<style scoped>
  .comic {
    display: inline-block;
    margin: 7px;
  }
</style>
