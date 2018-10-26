<template>
  <div>
    <Form
      :fund="fund"
      action="new"
      submitText="등록"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Fund from '@models/Fund';
  import Form from './Form.vue'

  export default {
    components: {Form},
    props: ['comic_id'],
    data() {
      return {
        fund: new Fund()
      }
    },
    methods: {
      async onSubmit(fund) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiFund.createFund(this.comic_id, fund);
          const address = await this.$contract.apiFund.getFundAddress(this.comic_id);
          this.$router.replace({name: 'publish-show-supporter', params: {fund_id: address}});
        } catch (e) {
          alert(e);
        }
        loader.hide();
      }
    },
    async created() {
    }
  }
</script>

<style scoped>
</style>