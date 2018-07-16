<template>
  <div>
    <Form
      :form="form"
      action="edit"
      submitText="Edit"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Form from './Form'
  import Helper from './Helper'

  export default {
    components: {Form},
    props: ['content_id'],
    data() {
      return {
        form: Helper.formData
      }
    },
    methods: {
      async onSubmit(form) {
        this.$loading('Uploading...');
        await this.$contract.content.update([
          form.title,
          this.$root.account,
          form.synopsis,
          form.genres,
          form.thumbnail,
          form.marketerRate,
          form.translatorRate
        ]);
        this.$loading.close();
        this.$router.push({name: 'show-content', params: {content_id: this.content_id}})
      },
    },
    async created() {
      this.form.title = await this.$contract.content.getTitle(this.content_id);
      this.form.thumbnail = await this.$contract.content.getThumbnail(this.content_id);
      this.form.synopsis = await this.$contract.content.getSynopsis(this.content_id);
      this.form.genres = await this.$contract.content.getGenres(this.content_id);
      this.form.marketerRate = await this.$contract.content.getMarketerRate(this.content_id);
      this.form.translatorRate = await this.$contract.content.getTranslatorRate(this.content_id);
    }
  }
</script>

<style scoped>
</style>
