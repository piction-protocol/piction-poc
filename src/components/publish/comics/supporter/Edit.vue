<template>
  <div>
    <Form
      :fund="fund"
      action="edit"
      :submitText="$t('수정')"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Fund from '@models/Fund';
  import Form from './Form.vue'

  export default {
    components: {Form},
    props: ['comic_id', 'fund_id'],
    data() {
      return {
        fund: new Fund()
      }
    },
    methods: {
      onSubmit(fund) {

      }
    },
    async created() {
      this.fund = await this.$contract.apiFund.getFund(this, this.fund_id);
    }
  }
</script>

<style scoped>
</style>