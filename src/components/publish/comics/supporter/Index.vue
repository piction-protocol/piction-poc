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
    methods: {},
    async created() {
      const address = await this.$contract.apiFund.getFundAddress(this.comic_id);
      if (address) {
        const fund = await this.$contract.apiFund.getFund(this, address);
        if (new Date(fund.endTime).getTime() < this.$root.now || fund.rise == fund.maxcap) {
          this.$router.replace({name: 'publish-show-supporter', params: {fund_id: address}})
        } else {
          this.$router.replace({name: 'publish-edit-supporter', params: {fund_id: address}})
        }
      } else {
        this.$router.replace({name: 'publish-new-supporter'})
      }
    }
  }
</script>

<style scoped>
</style>