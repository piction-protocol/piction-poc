<template>
  <div>
    <b-card title="신고 예치금"
            tag="article"
            class="mb-2">
      <p class="card-text">
        신고 활동을 하려면 예치금이 필요합니다.<br/>
        정상적인 신고의 경우 보상을 지급하며, 허위신고의 경우 예치금이 차감될 수 있습니다.
      </p>
      <b-button size="sm" variant="primary"
                :disabled="buttonDisabled"
                @click="deposit"
                style="width: 100%">{{buttonText}}
      </b-button>
    </b-card>
  </div>
</template>

<script>
  import {BigNumber} from 'bignumber.js';

  export default {
    data() {
      return {
        buttonText: 0,
        buttonDisabled: true
      }
    },
    methods: {
      deposit: async function () {
        this.$loading('loading...');
        let initialDeposit = BigNumber(this.pictionValue.reportRegistrationFee);
        let pxl = BigNumber(await this.$contract.pxl.balanceOf(this.pictionAddress.account));
        if (pxl.lt(initialDeposit)) {
          alert(`예치금 ${initialDeposit} PXL 이 필요합니다.`)
        } else {
          await this.$contract.pxl.approveAndCall(this.pictionAddress.report, initialDeposit);
        }
        window.location.reload();
      }
    },
    async created() {
      let regFee = this.regFee = await this.$contract.report.getRegFee();
      let deposit = BigNumber(regFee[0]);
      let initialDeposit = BigNumber(this.pictionValue.reportRegistrationFee);
      if (deposit.eq(0)) {
        this.buttonText = `${this.$utils.toPXL(initialDeposit)} PXL 예치`;
        this.buttonDisabled = false;
      } else {
        this.buttonText = `신고 활동 가능 (${this.$utils.toPXL(deposit)} PXL 예치중)`;
        this.buttonDisabled = true;
      }
    }
  }
</script>

<style scoped>

</style>
