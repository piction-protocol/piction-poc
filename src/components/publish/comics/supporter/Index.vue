<template>
  <div>
  </div>
</template>

<script>
  export default {
    props: ['comic_id'],
    data() {
      return {}
    },
    methods: {
      async endFund(address) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiFund.endFund(address);
        } catch (e) {
          alert(e);
        }
        loader.hide();
      },
      async isFundSuccess(address) {
        let events = await this.$contract.fund.getContract(address)
          .getPastEvents('EndFund', {fromBlock: 0, toBlock: 'latest'});
        if (events.length == 0) {
          await this.endFund(address);
          events = await this.$contract.fund.getContract(address)
            .getPastEvents('EndFund', {fromBlock: 0, toBlock: 'latest'});
        }
        console.log(events)
        return events[0].returnValues.success != null && events[0].returnValues.success;
      }
    },
    async created() {
      const address = await this.$contract.apiFund.getFundAddress(this.comic_id);
      const fund = address ? await this.$contract.apiFund.getFund(this, address) : null;
      if (!fund) {
        this.$router.replace({name: 'publish-new-supporter'})
      } else if (new Date(fund.startTime).getTime() > this.$root.now) {
        this.$router.replace({name: 'publish-edit-supporter', params: {fund_id: address}})
      } else if (new Date(fund.endTime).getTime() < this.$root.now || fund.rise == fund.maxcap) {
        if (await this.isFundSuccess(address)) {
          this.$router.replace({name: 'publish-success-supporter', params: {fund_id: address}})
        } else {
          this.$router.replace({name: 'publish-fail-supporter', params: {fund_id: address}})
        }
      } else {
        this.$router.replace({name: 'publish-progress-supporter', params: {fund_id: address}})
      }
    }
  }
</script>

<style scoped>
</style>