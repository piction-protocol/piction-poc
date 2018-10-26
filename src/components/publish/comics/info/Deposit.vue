<template>
  <div>
    <div class="font-size-20 font-weight-bold mt-5 mb-2">예치금</div>
    <b-row>
      <b-col cols="2">
        <div>
          <span class="font-size-24">{{releaseHistory ? releaseHistory.amount : deposit}}</span>
          <span class="font-size-14 text-secondary">PXL</span>
        </div>
        <div class="font-size-12">작품 등록 예치금</div>
      </b-col>
      <b-col cols="2">
        <div>
          <span class="font-size-24">{{releaseDateText.number}}</span>
          <span class="font-size-14 text-secondary">{{releaseDateText.text}}</span>
        </div>
        <div class="font-size-12">예치금 반환까지 남은 시간</div>
      </b-col>
    </b-row>
    <b-row class="pt-2 pb-2">
      <b-col cols="4">
        <b-progress :max="1"
                    height="12px" variant="primary">
          <b-progress-bar
            :value="progressValue"></b-progress-bar>
        </b-progress>
      </b-col>
    </b-row>
    <b-row>
      <b-col cols="4">
        <b-button
          v-if="releaseDate < $root.now && !releaseHistory && deposit > 0"
          type="submit" size="sm" variant="outline-secondary" block @click="release">예치금 반환
        </b-button>
        <div v-if="releaseDate < $root.now && !releaseHistory && deposit == 0">
          반환될 예치금이 없습니다.
        </div>
        <div v-if="releaseHistory">예치금이 반환되었습니다. ({{$utils.dateFmt(releaseHistory.date)}})</div>
      </b-col>
    </b-row>

    <div class="font-size-20 font-weight-bold mt-5 mb-2">예치금 차감 내역</div>
    <b-table striped hover
             show-empty
             empty-text="조회된 목록이 없습니다"
             :fields="fields"
             :items="history"
             :small="true">
      <template slot="date" slot-scope="data">{{$utils.dateFmt(data.value)}}</template>
      <template slot="description" slot-scope="data">{{data.value}}</template>
      <template slot="amount" slot-scope="data">-{{data.value}} PXL</template>
    </b-table>
  </div>
</template>

<script>
  import Web3Utils from '@utils/Web3Utils'

  export default {
    props: ['comic_id'],
    computed: {
      progressValue() {
        if (this.releaseDate == 0) {
          return 0;
        } else {
          return 1 - (this.releaseDate - this.$root.now) / this.pictionConfig.pictionValue.depositReleaseDelay;
        }
      },
      releaseDateText() {
        let time = Web3Utils.remainTimeToStr(this, this.releaseDate)
        return time ? time : {number: '0', text: '초'};
      }
    },
    data() {
      return {
        fields: [
          {key: 'date', label: '날짜'},
          {key: 'description', label: '사유'},
          {key: 'amount', label: '예치금 차감'},
        ],
        history: [],
        deposit: 0,
        releaseDate: 0,
        releaseHistory: null
      }
    },
    methods: {
      async init() {
        this.deposit = await this.$contract.depositPool.getDeposit(this.comic_id);
        this.releaseDate = await this.$contract.depositPool.getReleaseDate(this.comic_id);
        this.history = await this.$contract.depositPool.getDepositHistory(this.comic_id);
        this.releaseHistory = this.history.find(h => h.type == 6)
      },
      async release() {
        let loader = this.$loading.show();
        try {
          await this.$contract.depositPool.release(this.comic_id);
          this.init();
        } catch (e) {
          alert(e)
        }
        loader.hide();
      },
    },
    async created() {
      await this.init();
    }
  }
</script>

<style scoped>
</style>