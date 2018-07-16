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
  import Helper from './Helper'

  export default {
    components: {Form},
    data() {
      return {
        form: Helper.formData,
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
      this.form.genres = Helper.genres[0].value
    }
  }
</script>

<style scoped>
</style>
