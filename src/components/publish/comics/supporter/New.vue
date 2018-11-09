<template>
  <div>
    <Form
      :form="form"
      action="new"
      :submitText="$t('등록')"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import FundForm from '@forms/FundForm';
  import Form from './Form.vue'

  export default {
    components: {Form},
    props: ['comic_id'],
    data() {
      return {
        form: new FundForm()
      }
    },
    methods: {
      async onSubmit(form) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiFund.createFund(this.comic_id, form);
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