<template>
  <div>
    <b-card title="작품 등록 예치금"
            tag="article"
            class="mb-2">
      <p class="card-text">
        하나의 작품을 등록하려면 예치금이 필요합니다.<br/>
        정상적인 작품이면 작품 종료후에 환급받을 수 있습니다.<br/><br/>
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
        let initialDeposit = BigNumber(this.pictionValue.initialDeposit);
        let pxl = BigNumber(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
        if (pxl.lt(initialDeposit)) {
          alert(`예치금 ${initialDeposit} PXL 이 필요합니다.`)
        } else {
          await this.$contract.pxl.approveAndCall(this.pictionAddress.contentsManager, this.pictionValue.initialDeposit);
        }
        this.$loading.close();
      }
    },
    async created() {
      let deposit = BigNumber(await this.$contract.contentsManager.getInitialDeposit(this.pictionConfig.account));
      let initialDeposit = BigNumber(this.pictionValue.initialDeposit);
      if (deposit.eq(0)) {
        this.buttonText = `${this.$utils.toPXL(initialDeposit)} PXL 예치`;
        this.buttonDisabled = false;
      } else {
        this.buttonText = `작품 등록 가능 (${this.$utils.toPXL(initialDeposit)} PXL 예치중)`;
        this.buttonDisabled = true;
      }
    }
  }
</script>

<style scoped>

</style>
