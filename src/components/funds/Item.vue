<template>
  <router-link class="item d-inline-block w-100 mb-4 position-relative"
               :to="{name: 'show-fund', params: {comic_id: fund.comic.address, fund_id: fund.address}}">
    <b-img fluid :src="fund.comic.thumbnail" class="thumbnail"/>
    <div class="fund-info">
      <div class="mt-2">
        <b-badge variant="secondary bg-dark">{{$t('genres.' + fund.comic.genres)}}</b-badge>
        <b-badge v-if="$route.hash != '#closed'" variant="secondary bg-dark "><i class="fas fa-clock"></i> {{dDay}}
        </b-badge>
      </div>
      <div class="title-text mt-2">{{fund.comic.title}}</div>
      <div class="writer-text mt2">{{fund.comic.writer.name}}</div>
      <div class="detail-text mt-2">{{fund.detail}}</div>
      <div v-b-tooltip.hover :title="riseTooltip" class="pb-2 pt-2">
        <b-progress :max="fund.maxcap" height="5px" variant="primary" class="position-relative">
          <div class="position-absolute"
               :style="`width: 1px; height: 5px; background-color: #FF6E27; left: ${fund.getSoftcapPercent()}%`"></div>
          <b-progress-bar :value="fund.rise"></b-progress-bar>
        </b-progress>
        <div class="d-flex justify-content-between align-items-center">
          <div class="d-flex align-items-end"><span class="rise-pxl-text">{{fund.rise.toFixed(2)}}</span>
            <span class="symbol-text ml-1">PXL raised</span></div>
          <div class="percent-text">{{fund.getRisePercent()}}%</div>
        </div>
      </div>
    </div>
  </router-link>
</template>

<script>
  import Web3Utils from '@utils/Web3Utils'

  export default {
    props: ['fund'],
    computed: {
      riseTooltip() {
        return `Softcap ${this.fund.softcap} PXL\nMaxcap ${this.fund.maxcap} PXL`;
      },
      dDay() {
        if (this.fund.startTime > this.$root.now) {
          return this.$t('모집예정');
        } else {
          let time = Web3Utils.remainTimeToStr(this, this.fund.endTime);
          return time ? `${time.number}${time.text}${this.$t('남음')}` : this.$t('종료')
        }
      }
    },
    data() {
      return {}
    },
    methods: {
      async setEvent() {
        this.web3Events.push(this.$contract.fund.getContract(this.fund.address).events
          .Support({fromBlock: 'latest'}, () => this.$parent.setFunds()));
      },
    },
    created() {
      this.setEvent();
    },
  }
</script>

<style scoped>
  .title-text {
    font-size: 16px;
    font-weight: bold;
    width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .writer-text {
    font-size: 12px;
    color: #9b9b9b;
  }

  .detail-text {
    font-size: 12px;
    color: #6c757d;
    height: 50px;
    white-space: pre-line;
    overflow: hidden;
  }

  .rise-pxl-text {
    font-size: 16px;
    font-weight: 900;
  }

  .symbol-text {
    font-size: 14px;
    color: #4a4a4a;
  }

  .percent-text {
    font-size: 12px;
    color: #4a4a4a;
  }

  .thumbnail {
    width: 100%;
    height: 250px;
    background-position: center;
    background-size: cover;
    background-color: #e8e8e8;
  }

  .fund-info {
    padding: 0 10px;
    border-top: 1px solid rgb(220, 220, 220);
  }

  .item {
    border: 1px solid rgb(220, 220, 220);
  }
</style>
