<template>
  <router-link :to="{ name: 'episodes', params: { content_id: content.id }}" class="comic">
    <b-card :title="content.title"
            :img-src="content.thumbnail"
            img-alt="Image"
            img-top
            tag="article"
            style="max-width: 20rem;"
            class="mb-2">
      <p class="card-text">
        {{content.synopsis}}
      </p>
    </b-card>
  </router-link>
</template>

<script>
  export default {
    props: ['content'],
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
