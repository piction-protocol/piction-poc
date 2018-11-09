<template>
  <div>
    <div class="font-size-20 font-weight-bold mt-5 mb-2">{{$t('예치금')}}</div>
    <b-row>
      <b-col cols="2">
        <div>
          <span class="font-size-24">{{releaseHistory ? releaseHistory.amount : deposit}}</span>
          <span class="font-size-14 text-secondary">PXL</span>
        </div>
        <div class="font-size-12">{{$t('작품등록예치금')}}</div>
      </b-col>
      <b-col cols="2">
        <div>
          <span class="font-size-24">{{releaseDateText.number}}</span>
          <span class="font-size-14 text-secondary">{{releaseDateText.text}}</span>
        </div>
        <div class="font-size-12">{{$t('예치금반환까지남은시간')}}</div>
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
          type="submit" size="sm" variant="outline-secondary" block @click="release">{{$t('예치금반환')}}
        </b-button>
        <div v-if="releaseDate < $root.now && !releaseHistory && deposit == 0">
          {{$t('noDepositReturned')}}
        </div>
        <div v-if="releaseHistory">{{$t('depositReturned')}} ({{$utils.dateFmt(releaseHistory.date)}})</div>
      </b-col>
    </b-row>

    <div class="font-size-20 font-weight-bold mt-5 mb-2">{{$t('예치금차감내역')}}</div>
    <b-table striped hover
             show-empty
             :empty-text="$t('emptyList')"
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
        return time ? time : {number: '0', text: this.$t('초')};
      }
    },
    data() {
      return {
        fields: [
          {key: 'date', label: this.$t('날짜')},
          {key: 'description', label: this.$t('사유')},
          {key: 'amount', label: this.$t('예치금차감')},
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