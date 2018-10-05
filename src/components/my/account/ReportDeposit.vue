<template>
  <div>
    <b-card title="신고 예치금"
            tag="article"
            class="mb-2">
      <p class="card-text">
        신고 활동을 하려면 예치금이 필요합니다.<br/>
        정상적인 신고의 경우 보상을 지급하며, 허위신고는 예치금이 차감될 수 있습니다.
      </p>
      <b-button size="sm" variant="primary"
                :disabled="isLock"
                @click="action"
                style="width: 100%">{{buttonText}}
        <b-badge v-if="uncompletedReportCount > 0"
                 v-b-tooltip.hover :title="uncompletedReportCount + '건의 신고가 처리되지 않았습니다'"
                 variant="danger">{{uncompletedReportCount}}
        </b-badge>
      </b-button>
    </b-card>
  </div>
</template>

<script>
  import {BigNumber} from 'bignumber.js';

  export default {
    computed: {
      isLock() {
        return this.uncompletedReportCount > 0 || Number(this.regFee.lockTime_) > new Date().getTime();
      },
      buttonText() {
        if (this.regFee.amount_ == 0) {
          let initialDeposit = BigNumber(this.pictionConfig.pictionValue.reportRegistrationFee);
          return `${this.$utils.toPXL(initialDeposit)} PXL 예치`;
        } else if (Number(this.regFee.lockTime_) > new Date().getTime()) {
          return `${this.$utils.dateFmt(this.regFee.lockTime_)} 이후 ${this.$utils.toPXL(this.regFee.amount_)} PXL 출금 신청 가능`;
        } else {
          return `${this.$utils.toPXL(this.regFee.amount_)} PXL 신고 예치금 환급 신청`;
        }
      }
    },
    data() {
      return {
        uncompletedReportCount: 0,
        regFee: {},
      }
    },
    methods: {
      async init() {
        this.regFee = await this.$contract.apiReport.getRegistrationAmount();
        const events = await this.$contract.report.getContract().getPastEvents('SendReport', {
          filter: {_from: this.pictionConfig.account}, fromBlock: 0, toBlock: 'latest'
        });
        const ids = events.map(o => o.returnValues.id);
        var result = await this.$contract.apiReport.getReportResult(ids);
        this.uncompletedReportCount = result.complete_.filter(o => !o).length
      },
      action() {
        if (this.regFee.amount_ == 0) {
          this.deposit();
        } else {
          this.withdrawRegistration();
        }
      },
      deposit: async function () {
        this.$loading('loading...');
        let initialDeposit = BigNumber(this.pictionConfig.pictionValue.reportRegistrationFee);
        let pxl = BigNumber(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
        if (pxl.lt(initialDeposit)) {
          alert(`예치금 ${initialDeposit} PXL 이 필요합니다.`)
        } else {
          await this.$contract.pxl.approveAndCall(this.pictionConfig.pictionAddress.report, initialDeposit);
          this.init();
        }
        this.$loading.close();
      },
      async withdrawRegistration() {
        this.$loading('loading...');
        try {
          await this.$contract.apiReport.withdrawRegistration();
          this.init();
        } catch (e) {
          alert(e)
        }
        this.$loading.close();
      },
      setEvent() {
        this.$contract.council.setCallback((error, event) => this.init());
      },
    },
    async created() {
      this.setEvent();
      this.init();
    }
  }
</script>

<style scoped>

</style>
