<template>
  <div v-if="fund.address">
    <div class="pt-4" align="center">
      <img :src="fund.comic.thumbnail" class="thumbnail mb-4"/>
      <h2 class="font-weight-bold mb-2">{{fund.comic.title}}</h2>
      <div class="text-secondary font-italic mb-2">{{fund.comic.writer.name}}</div>
      <div class="synopsis-text">{{fund.detail}}</div>
    </div>
    <State :fund="fund"/>
    <div class="text-center mb-5">
      <b-button variant="outline-secondary"
                :disabled="!supportable || isMy"
                @click="$refs.myModalRef.show()">{{$t('서포터신청')}}
      </b-button>
      <b-button variant="outline-secondary ml-2" :to="{name: 'episodes', params:{comic_id:fund.comic.address}}">{{$t('작품보기')}}
      </b-button>
    </div>
    <div class="title">{{$t('시놉시스')}}</div>
    <div class="mb-5">{{fund.comic.synopsis}}</div>
    <b-row>
      <b-col cols="12" sm="12" md="6" lg="6">
        <div class="title">{{$t('모집정보')}}</div>
        <Plan :fund="fund"/>
      </b-col>
      <b-col cols="12" sm="12" md="6" lg="6">
        <div class="title">{{$t('서포터')}}</div>
        <Supporters :supporters="fund.supporters"/>
      </b-col>
    </b-row>
    <b-modal ref="myModalRef"
             :title="$t('modal.support.title')"
             :ok-title="$t('신청')"
             :cancel-title="$t('취소')"
             @ok="support"
             @shown="supportAmount = fund.min">
      <form @submit.stop.prevent="handleSubmit">
        <div class="text-center">
          <span class="font-size-32 font-weight-bold">{{supportAmount}}</span>
          <span class="font-size-24" style="color: #9b9b9b">PXL</span>
        </div>
        <b-form-input type="range" v-model="supportAmount" :min="fund.min" :max="fund.max"/>
      </form>
    </b-modal>
  </div>
</template>

<script>
  import Fund from '@models/Fund'
  import State from './State';
  import Plan from './Plan';
  import Supporters from './Supporters';
  import BigNumber from 'bignumber.js'

  export default {
    components: {State, Plan, Supporters},
    props: ['fund_id'],
    computed: {
      isMy() {
        return this.fund.comic.writer.address == this.pictionConfig.account;
      },
      supportable() {
        return this.fund.startTime < this.$root.now &&
          this.$root.now < this.fund.endTime &&
          this.fund.maxcap > this.fund.rise;
      },
    },
    data() {
      return {
        fund: {},
        supportAmount: 10,
      }
    },
    methods: {
      async setFund() {
        this.fund = await this.$contract.apiFund.getFund(this, this.fund_id);
        if (this.fund.needEndProcessing) {
          await this.endFund();
        }
      },
      async setSupporters() {
        this.fund.supporters = await this.$contract.apiFund.getSupporters(this, this.fund_id);
      },
      async endFund() {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiFund.endFund(this.fund_id);
        } catch (e) {
          alert(e);
        }
        loader.hide();
      },
      async setEvents() {
        this.web3Events.push(this.$contract.fund.getContract(this.fund_id).events
          .Support({fromBlock: 'latest'}, () => {
            this.setFund();
            this.setSupporters();
          }));
      },
      async support(evt) {
        evt.preventDefault();
        this.$refs.myModalRef.hide();
        let loader = this.$loading.show();
        try {
          await this.$contract.pxl.approveAndCall(this.fund_id, this.$utils.appendDecimals(this.supportAmount));
          await this.setFund();
          await this.setSupporters();
        } catch (e) {
          alert(e)
        }
        loader.hide()
      },
    },
    async created() {
      await this.setEvents();
      await this.setFund();
      await this.setSupporters();
    }
  }
</script>

<style scoped>
  .thumbnail {
    width: 200px;
    height: 200px;
    background-position: center;
    background-size: cover;
    border: 1px solid #979797;
  }

  .title {
    font-size: 20px;
    font-weight: bold;
    margin-bottom: 16px;
  }
</style>
