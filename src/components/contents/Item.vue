<template>
  <router-link class="item d-inline-block w-100 mb-4" :to="{ name: 'episodes', params: { content_id: content.id }}">
    <b-img fluid :src="content.thumbnail" class="thumbnail"/>
    <div class="title-text">{{content.title}}</div>
    <div class="writer-text">{{content.writerName}}</div>
    <b-badge variant="secondary bg-dark">{{content.genres}}</b-badge>
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
  .title-text {
    font-size: 16px;
    font-weight: bold;
  }

  .writer-text {
    font-size: 12px;
    color: #9b9b9b;
  }

  .thumbnail {
    width: 100%;
    /*height: 100%;*/
    height: 250px;
    border: 1px solid #979797;
    background-position: center;
    background-size: cover;
    background-color: #e8e8e8;
    margin-bottom: 10px;
  }
</style>
