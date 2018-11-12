<template>
  <div>
    <b-button variant="danger" @click="showModal" size="sm">{{$t('신고')}}</b-button>
    <b-modal ref="reportModal" hide-footer :title="$t('modal.report.title')">
      <b-form-group>
        <b-form-radio-group v-model="selected"
                            stacked
                            :options="options">
        </b-form-radio-group>
      </b-form-group>
      <b-form-textarea v-if="!selected" v-model="etcReason"
                       :placeholder="$t('modal.report.inputPlaceholder')"
                       :rows="3"
                       :max-rows="6">
      </b-form-textarea>
      <b-btn class="mt-3" variant="outline-danger" block @click="report">{{$t('신고')}}</b-btn>
      <b-btn class="mt-3" variant="secondary" block @click="hideModal">{{$t('취소')}}</b-btn>
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
          {text: this.$t('reports.reason1'), value: 'reports.reason1'},
          {text: this.$t('reports.reason2'), value: 'reports.reason2'},
          {text: this.$t('reports.reason3'), value: 'reports.reason3'},
          {text: this.$t('reports.reason4'), value: 'reports.reason4'},
          {text: this.$t('reports.etc'), value: ''}
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
          let message = this.$t('initialReportDepositHint', {pxl: this.web3.utils.fromWei(initialDeposit)});
          let resetMessage = this.$t('confirmResetReportDeposit');
          if (deposit > 0) {
            if (lockTime <= this.$root.now) {
              if (confirm(resetMessage)) {
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
          } else if (confirm(`${message}\n${this.$t('confirmRegister')}`)) {
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
            this.$toasted.show(this.$t('successReport'), {position: "top-center"});
            this.hideModal();
          } else {
            this.$toasted.show(this.$t('noReasonReportFail'), {position: "top-center"});
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
