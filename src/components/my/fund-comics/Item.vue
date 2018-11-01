<template>
  <div>
    <router-link class="d-flex mb-2" :to="{ name: 'my-show-fund-comic', params: { comic_id: comic.address }}">
      <b-img fluid :src="comic.thumbnail" class="thumbnail"/>
      <div class="d-flex align-content-between flex-wrap p-3">
        <div class="title-text w-100">{{comic.title}}</div>
        <div class="episode-count-text w-100">{{episodeCountText}}</div>
        <div :class="comic.isBlock ? 'block-text' : 'purchased-amount-text'" class="w-100">{{purchasedAmountText}}</div>
      </div>
    </router-link>
    <hr>
  </div>
</template>

<script>
  export default {
    props: ['comic'],
    computed: {
      totalEpisodeCount() {
        return this.comic.publishedEpisodesCount + this.comic.privateEpisodesCount;
      },
      episodeCountText() {
        if (this.totalEpisodeCount > 0) {
          return `${this.comic.publishedEpisodesCount}개 에피소드 공개 중 / ${this.comic.privateEpisodesCount}개 에피소드 비공개`
        } else {
          return `등록된 에피소드가 없습니다.`;
        }
      },
      purchasedAmountText() {
        if (this.comic.isBlock) {
          return '비공개';
        } else {
          return `매출 ${this.web3.utils.fromWei(this.comic.totalPurchasedAmount)} PXL`
        }
      }
    },
    data() {
      return {}
    },
    methods: {}
  }
</script>

<style scoped>
  .title-text {
    font-size: 22px;
    font-weight: bold;
  }

  .episode-count-text {
    font-size: 18px;
    color: #4a4a4a;
  }

  .block-text {
    font-size: 15px;
    color: #d0021b;
  }

  .purchased-amount-text {
    font-size: 15px;
    color: #4a90e2;
  }

  .thumbnail {
    width: 128px;
    height: 128px;
    border: 1px solid #979797;
    background-position: center;
    background-size: cover;
    background-color: #e8e8e8;
  }
</style>
