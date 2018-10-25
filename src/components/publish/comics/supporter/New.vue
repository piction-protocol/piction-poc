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
          this.$router.replace({name: 'publish-supporter'});
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