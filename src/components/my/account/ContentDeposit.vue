<template>
  <div>
    <b-card title="작품 등록 예치금"
            tag="article"
            class="mb-2">
      <p class="card-text">
        작품을 등록하려면 예치금이 필요합니다.<br/>
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
      async init() {
        let deposit = BigNumber(await this.$contract.apiContents.getInitialDeposit(this.pictionConfig.account));
        let initialDeposit = BigNumber(this.pictionConfig.pictionValue.initialDeposit);
        if (deposit.eq(0)) {
          this.buttonText = `${this.$utils.toPXL(initialDeposit)} PXL 예치`;
          this.buttonDisabled = false;
        } else {
          this.buttonText = `작품 등록 가능 (${this.$utils.toPXL(initialDeposit)} PXL 예치중)`;
          this.buttonDisabled = true;
        }
      },
      async deposit() {
        let loader = this.$loading.show();
        let initialDeposit = BigNumber(this.pictionConfig.pictionValue.initialDeposit);
        let pxl = BigNumber(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
        if (pxl.lt(initialDeposit)) {
          alert(`예치금 ${initialDeposit} PXL 이 필요합니다.`)
        } else {
          await this.$contract.pxl.approveAndCall(this.pictionConfig.managerAddress.contentsManager, this.pictionConfig.pictionValue.initialDeposit);
          this.init();
        }
        loader.hide();
      }
    },
    async created() {
      this.init();
    }
  }
</script>

<style scoped>

</style>
