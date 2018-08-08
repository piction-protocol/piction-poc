<template>
  <div>
    <h4>Supporters
      <b-button v-b-modal.supportModal :disabled="!supportable" variant="primary" size="sm">support</b-button>
    </h4>
    <b-table striped hover :items="supporters" :small="true"></b-table>
    <b-modal id="supportModal"
             ref="modal"
             title="Support"
             @ok="support"
             @shown="clearAmount">
      <form @submit.stop.prevent="handleSubmit">
        <b-form-input type="number"
                      placeholder="Enter your PXL amount"
                      v-model="supportAmount"></b-form-input>
      </form>
    </b-modal>
  </div>
</template>

<script>
  import BigNumber from 'bignumber.js'

  export default {
    props: ['fund_id', 'supportable'],
    data() {
      return {
        supporters: [],
        supportAmount: 10,
      }
    },
    methods: {
      clearAmount() {
        this.supportAmount = 10;
      },
      async support(evt) {
        evt.preventDefault();
        if (!Number(this.supportAmount) || Number(this.supportAmount) == 0) {
          alert('Please enter your PXL amount')
          return;
        }
        this.$refs.modal.hide();
        this.$loading('loading...');
        try {
          await this.$contract.pxl.approveAndCall(this.fund_id, this.supportAmount, '');
        } catch (e) {
          alert(e)
        }
        this.$router.go(this.$router.path)
      },
    },
    async created() {
      let supporters = await this.$contract.fund.getSupporters(this.fund_id);
      supporters = this.$utils.structArrayToJson(supporters, ['address', 'investment', 'withdraw', 'distributionRate']);
      supporters.forEach(obj => {
        console.log(obj.distributionRate)
        obj.investment = `${this.$utils.toPXL(obj.investment)} PXL`;
        obj.withdraw = `${this.$utils.toPXL(obj.withdraw)} PXL`;
        obj.distributionRate = `${obj.distributionRate / Math.pow(10, 18) * 100}%`;
      })
      this.supporters = supporters;
    }
  }
</script>

<style scoped>
</style>
