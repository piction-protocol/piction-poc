<template>
  <div>
    <Form
      :form="form"
      action="new"
      submitText="Create"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Form from './Form'
  import {formData, genres} from './helper'

  export default {
    components: {Form},
    data() {
      return {
        form: formData(),
      }
    },
    methods: {
      async onSubmit(form) {
        this.$loading('Uploading...');
        let contrat = await this.$contract.content.deploy([
          form.title,
          this.$root.account,
          form.synopsis,
          form.genres,
          form.thumbnail,
          form.marketerRate,
          form.translatorRate
        ]);
        this.$loading.close();
        this.$router.push({name: 'show-content', params: {content_id: contrat._address}})
      },
    },
    created() {
      this.form.genres = genres[0].value
    }
  }
</script>

<style scoped>
</style>
