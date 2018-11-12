<template>
  <router-link class="item d-inline-block w-100 mb-4" :to="{ name: 'episodes', params: { comic_id: comic.address }}">
    <b-img fluid :src="comic.thumbnail" class="thumbnail"/>
    <div class="title-text">{{comic.title}}</div>
    <div class="writer-text">{{comic.writer.name}}</div>
    <b-badge variant="secondary bg-dark">{{$t('genres.' + comic.genres)}}</b-badge>
  </router-link>
</template>

<script>
  export default {
    props: ['comic'],
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
