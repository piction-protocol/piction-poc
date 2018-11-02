<template>
  <div>
    <b-button variant="danger" @click="showModal" size="sm">신고</b-button>
    <b-modal ref="reportModal" hide-footer title="신고 사유를 선택하세요">
      <b-form-group>
        <b-form-radio-group v-model="selected"
                            stacked
                            :options="options">
        </b-form-radio-group>
      </b-form-group>
      <b-form-textarea v-if="!selected" v-model="etcReason"
                       placeholder="신고 사유를 입력하세요"
                       :rows="3"
                       :max-rows="6">
      </b-form-textarea>
      <b-btn class="mt-3" variant="outline-danger" block @click="report">신고</b-btn>
      <b-btn class="mt-3" variant="secondary" block @click="hideModal">취소</b-btn>
    </b-modal>
  </div>
</template>

<script>
  export default {
    props: ['comic_id'],
    data() {
      return {
        selected: null,
        etcReason: null,
        options: [
          {text: '부적절한 광고', value: '부적절한 광고'},
          {text: '과도한 선정성, 폭력성', value: '과도한 선정성, 폭력성'},
          {text: '명예훼손/저작권 침해', value: '명예훼손/저작권 침해'},
          {text: '무분별한 반복 게시', value: '무분별한 반복 게시'},
          {text: '기타', value: ''}
        ]
      }
    },
    methods: {
      restoreData() {
        this.selected = this.options[0].value
        this.etcReason = null;
      },
      async showModal() {
        try {
          this.restoreData();
          let registrationInfo = await this.$contract.apiReport.getRegistrationAmount();
          let deposit = new this.web3.utils.BN(registrationInfo.amount_);
          let lockTime = registrationInfo.lockTime_;
          let initialDeposit = new this.web3.utils.BN(this.pictionConfig.pictionValue.reportRegistrationFee.toString());
          let pxl = new this.web3.utils.BN(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
          let message = `신고를 하려면 예치금 ${this.web3.utils.fromWei(initialDeposit)} PXL 이 필요합니다.`;
          let resetMessage = `신고 권한 부여 시간이 만료되었습니다. 반환 및 재예치 후 진행하시겠습니까?`;
          if (deposit > 0) {
            if(lockTime <= this.$root.now) {
              if(confirm(resetMessage)) { 
                let loader = this.$loading.show();
                await this.$contract.apiReport.withdrawRegistration();
                await this.$contract.pxl.approveAndCall(this.pictionConfig.pictionAddress.report, initialDeposit);  
                this.$refs.reportModal.show();
                loader.hide();
              }
            } else {
              this.$refs.reportModal.show();
            } 
          } else if (pxl < initialDeposit) {
            this.$toasted.show(message, {position: "top-center"});
          } else if (confirm(`${message}\n등록하시겠습니까?`)) {
            let loader = this.$loading.show();
            await this.$contract.pxl.approveAndCall(this.pictionConfig.pictionAddress.report, initialDeposit);
            this.$refs.reportModal.show()
            loader.hide();
          }
        } catch (e) {
          alert(e);
        }
      },
      hideModal() {
        this.$refs.reportModal.hide()
      },
      async report() {
        try {
          const reason = this.selected ? this.selected : this.etcReason;
          if (reason) {
            let loader = this.$loading.show();
            await this.$contract.apiReport.sendReport(this.comic_id, reason);
            loader.hide();
            this.$toasted.show("신고되었습니다.", {position: "top-center"});
            this.hideModal();
          } else {
            this.$toasted.show("신고 사유가 입력되지 않았습니다.", {position: "top-center"});
          }
        } catch (e) {
          alert(e);
        }
      },
    },
    created() {
    }
  }
</script>

<style scoped>
</style>
