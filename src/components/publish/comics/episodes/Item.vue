<template>
  <div @click="editEpisode" class="item">
    <div class="d-flex">
      <img :src="episode.thumbnail" class="thumbnail"/>
      <div class="d-flex align-items flex-column p-2 overflow-hidden">
        <div class="published-at">{{$utils.dateFmt(episode.publishedAt)}}</div>
        <div class="title-text">{{episode.title}}</div>
        <div class="purchase-info-text">
          {{episode.price}}PXL
        </div>
      </div>
      <div class="ml-auto p-2 align-self-end">
        <div :class="episode.status ? 'on-text' : 'off-text'" class="h-25">{{episode.status ? $t('공개') : $t('비공개')}}</div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    props: ['comic_id', 'episode'],
    data() {
      return {}
    },
    methods: {
      editEpisode() {
        this.$router.push({
          name: 'publish-edit-episode',
          params: {comic_id: this.comic_id, episode_id: this.episode.id}
        });
      },
    }
  }
</script>

<style scoped>
  .published-at {
    font-size: 14px;
    color: #9b9b9b;
  }

  .title-text {
    font-size: 16px;
    font-weight: bold;
    line-height: 200%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .purchase-info-text {
    font-size: 14px;
    color: #4a4a4a;
    line-height: 200%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .on-text {
    font-size: 14px;
    color: #4a90e2;
  }

  .off-text {
    font-size: 14px;
    color: #d0021b;
  }

  .thumbnail {
    width: 100px;
    height: 100px;
    background-position: center;
    background-size: cover;
    background-color: #e8e8e8;
  }

  .item {
    padding: 0px;
    border: 1px dotted #979797;
  }
</style>