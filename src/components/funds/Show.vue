<template>
  <div>
    <b-card :title="content ? `${content.record.title}` : ''"
            tag="article"
            class="mb-2">
      <b-alert show variant="secondary" style="white-space: pre-line">{{fund.detail}}</b-alert>
      <div class="card-text mb-2">
        <b-row>
          <b-col>모집기간 : {{$utils.dateFmt(fund.startTime)}} ~ {{$utils.dateFmt(fund.endTime)}}</b-col>
        </b-row>
        <hr>
        <b-row>
          <b-col>모집금액: {{$utils.toPXL(fund.fundRise)}} PXL</b-col>
          <b-col>분배횟수: {{fund.poolSize}}</b-col>
        </b-row>
        <b-row>
          <b-col>softcap: {{$utils.toPXL(fund.softcap)}} PXL</b-col>
          <b-col>분배간격: {{fund.releaseInterval / (60 * 60 * 1000)}} 시간</b-col>
        </b-row>
        <b-row>
          <b-col>maxcap: {{$utils.toPXL(fund.maxcap)}} PXL</b-col>
          <b-col>분배비율: {{fund.distributionRate / Math.pow(10, 18) * 100}}%</b-col>
        </b-row>
      </div>
      <hr>
      <b-button variant="primary" size="sm" block
                @click="button.action"
                :variant="button.variant"
                :disabled="button.disabled">{{button.text}}
      </b-button>
    </b-card>
    <hr>
    <b-card no-body>
      <b-tabs card v-model="tabIndex">
        <b-tab title="서포터" active>
          <Supporters :supporters="supporters"/>
        </b-tab>
        <b-tab title="서포터 풀">
          <SupporterPool :distributions="distributions"/>
        </b-tab>
      </b-tabs>
    </b-card>

    <b-modal ref="myModalRef"
             title="참여"
             @ok="support"
             @shown="supportAmount = 10">
      <form @submit.stop.prevent="handleSubmit">
        <b-form-input type="number"
                      placeholder="투자 금액을 입력하세요"
                      v-model="supportAmount"></b-form-input>
      </form>
    </b-modal>
  </div>
</template>

<script>
  import moment from 'moment';
  import {record} from './helper';
  import SupporterPool from './SupporterPool';
  import Supporters from './Supporters';
  import BigNumber from 'bignumber.js'
  import AnimatedNumber from "animated-number-vue";

  export default {
    components: {SupporterPool, Supporters, AnimatedNumber},
    props: ['content_id', 'fund_id'],
    computed: {
      button() {
        if (Number(this.fund.startTime) > new Date().getTime()) {
          return {text: '참여 가능 시간이 아닙니다', variant: 'primary', disabled: true, action: () => null}
        } else if (this.supportable) {
          var disabled = this.content.writer.toLowerCase() == this.pictionConfig.account;
          return {text: '참여', variant: 'primary', disabled: disabled, action: () => this.$refs.myModalRef.show()}
        } else if (this.supporters.length == 0) {
          return {text: '종료', variant: 'primary', disabled: true, action: () => null}
        } else {
          if (this.supporters.find(supporter => supporter.refund)) {
            return {text: '환불 (softcap 미달성)', variant: 'danger', disabled: true, action: () => null}
          } else if (this.supporters.find(supporter => supporter.distributionRate > 0)) {
            var amount = this.distributions
              .filter(d => d.distributableTime < new Date().getTime() && d.state == 0)
              .reduce((a, b) => a + Number(b.amount), 0);
            return {
              text: `서포터 풀 ${this.$utils.toPXL(amount)} PXL 작가에게 지급`,
              variant: 'primary',
              disabled: amount == 0,
              action: () => this.releaseDistribution()
            }
          } else if (this.fund.softcap > this.fund.fundRise) {
            return {text: '환불', variant: 'danger', disabled: false, action: () => this.endFund(0)}
          } else {
            return {text: '서포터 풀 생성', variant: 'primary', disabled: false, action: () => this.endFund(1)}
          }
        }
      },
      supportable() {
        return moment().isBetween(Number(this.fund.startTime), Number(this.fund.endTime)) &&
          Number(this.fund.maxcap) > Number(this.fund.fundRise);
      },
    },
    data() {
      return {
        content: null,
        fund: record(),
        supporters: [],
        distributions: [],
        supportAmount: 10,
        tabIndex: 0,
        events: []
      }
    },
    methods: {
      async init() {
        this.loadFundInfo();
        this.loadSupporters();
        this.loadDistributions();
      },
      async setEvent() {
        const supportEvent = this.$contract.fund.getContract(this.fund_id).events
          .Support({fromBlock: 'latest'}, () => this.init());
        this.events.push(supportEvent);
        const endFundEvent = this.$contract.apiFund.getContract().events
          .EndFund({filter: {_fund: this.fund_id}, fromBlock: 'latest'}, () => this.init());
        this.events.push(endFundEvent);
        const releaseDistributionEvent = this.$contract.apiFund.getContract().events
          .ReleaseDistribution({filter: {_fund: this.fund_id}, fromBlock: 'latest'}, () => this.init());
        this.events.push(releaseDistributionEvent);
      },
      async loadFundInfo() {
        this.content = await this.$contract.apiContents.getContentsDetail(this.content_id);
        this.fund = await this.$contract.apiFund.fundInfo(this.fund_id);
      },
      async loadSupporters() {
        const supporters = await this.$contract.apiFund.getSupporters(this.fund_id);
        const writers = await this.$contract.accountManager.getUserNames(supporters.map(s => s.user));
        supporters.forEach((supporter, index) => supporter.userName = writers[index]);
        this.supporters = supporters;
      },
      async loadDistributions() {
        this.distributions = await this.$contract.apiFund.getDistributions(this.fund_id);
      },
      async support(evt) {
        evt.preventDefault();
        if (!Number(this.supportAmount) || Number(this.supportAmount) == 0) {
          alert('Please enter your PXL amount')
          return;
        }
        this.$refs.myModalRef.hide();
        this.$loading('loading...');
        try {
          await this.$contract.pxl.approveAndCall(this.fund_id, this.$utils.appendDecimals(this.supportAmount));
          this.init();
        } catch (e) {
          alert(e)
        }
        this.$loading.close()
      },
      async endFund(tabIndex) {
        this.$loading('loading...');
        try {
          await this.$contract.apiFund.endFund(this.fund_id);
          this.init();
          this.tabIndex = tabIndex;
        } catch (e) {
          alert(e)
        }
        this.$loading.close()
      },
      async releaseDistribution() {
        this.$loading('loading...');
        try {
          await this.$contract.apiFund.releaseDistribution(this.fund_id);
          this.init();
        } catch (e) {
          alert(e)
        }
        this.$loading.close()
      }
    },
    async created() {
      this.setEvent();
      this.init();
    },
    async destroyed() {
      this.events.forEach(async event => await event.unsubscribe());
    },
  }
</script>

<style scoped>

</style>
