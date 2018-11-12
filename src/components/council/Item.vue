<template>
  <router-link class="item d-inline-block w-100 mb-4" :to="{ name: 'council-detail', params: { comic_id: council.comic.address }}">
    <b-img fluid :src="council.comic.thumbnail" class="thumbnail"/>
    <div class="title-text">{{council.comic.title}}</div>
    <div class="writer-text">{{council.comic.writer.name}}</div>
    <div class="report-count-text">{{council.uncompletedReportCount > 0 ? $t('대기중인신고') + " : "+council.uncompletedReportCount : ""}}</div>
  </router-link>
</template>

<script>
  export default {
    props: ['council'],
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

  .report-count-text {
    font-size: 12px;
    color: #ff6e27;
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
