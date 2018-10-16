<template>
  <router-link class="item d-inline-block w-100 mb-4 position-relative"
               :to="{name: 'show-fund', params: {content_id: fund.content, fund_id: fund.fund}}">
    <div v-if="!disableLabel" class="position-absolute mr-1" style="right: 0;">
      <b-badge variant="secondary bg-dark">{{dDay}}</b-badge>
    </div>
    <b-img fluid :src="fund.record.thumbnail" class="thumbnail"/>
    <div class="fund-info">
      <b-badge variant="secondary bg-dark mt-2">{{fund.record.genres}}</b-badge>
      <div class="title-text mt-2">{{fund.record.title}}</div>
      <div class="writer-text mt2">{{fund.record.writerName}}</div>
      <div class="detail-text mt-2">{{fund.detail}}</div>
      <div v-b-tooltip.hover :title="riseTooltip" class="pb-2 pt-2">
        <div class="position-relative">
          <b-progress :max="maxcap" height="5px" variant="dark">
            <b-progress-bar :value="rise"></b-progress-bar>
          </b-progress>
          <b-progress v-if="rise < softcap" :max="maxcap" height="5px" variant="dark" class="position-absolute w-100"
                      style="top:0; opacity: 0.15">
            <b-progress-bar variant="danger" :value="softcap"></b-progress-bar>
          </b-progress>
        </div>
        <div class="d-flex justify-content-between align-items-center">
          <div class="d-flex align-items-end"><span class="rise-pxl-text">{{rise.toFixed(2)}}</span>
            <span class="symbol-text ml-1">PXL raised</span></div>
          <div class="percent-text">{{percent}}%</div>
        </div>
      </div>
    </div>
  </router-link>
</template>

<script>
  import Web3Utils from '../../utils/Web3Utils.js'

  export default {
    props: ['fund', 'disableLabel'],
    computed: {
      rise() {
        return Number(this.$utils.toPXL(this.fund.rise));
      },
      softcap() {
        return Number(this.$utils.toPXL(this.fund.softcap));
      },
      maxcap() {
        return Number(this.$utils.toPXL(this.fund.maxcap));
      },
      percent() {
        return (this.rise / this.maxcap * 100).toFixed(0);
      },
      riseTooltip() {
        return `Softcap ${this.softcap} PXL\nMaxcap ${this.maxcap} PXL`;
      },
      dDay() {
        if (Number(this.fund.startTime) > this.$root.now) {
          return '모집예정'
        } else {
          return Web3Utils.remainTimeToStr(this.$root.now, this.fund.endTime);
        }
      }
    },
    data() {
      return {
        events: []
      }
    },
    methods: {
      async setEvent() {
        const supportEvent = this.$contract.fund.getContract(this.fund.fund).events
          .Support({fromBlock: 'latest'}, () => this.$parent.init());
        this.events.push(supportEvent);
      },
    },
    created() {
      this.setEvent();
    },
    async destroyed() {
      this.events.forEach(async event => await event.unsubscribe());
    },
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

  .detail-text {
    font-size: 12px;
    color: #6c757d;
    height: 50px;
    white-space: pre-line;
  }

  .rise-pxl-text {
    font-size: 12px;
    font-weight: 900;
  }

  .symbol-text {
    font-size: 8px;
    color: #4a4a4a;
  }

  .percent-text {
    font-size: 10px;
    color: #4a4a4a;
  }

  .thumbnail {
    width: 100%;
    /*height: 100%;*/
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
