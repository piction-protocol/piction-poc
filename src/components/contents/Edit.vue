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
  import {formData} from './helper'

  export default {
    components: {Form},
    props: ['content_id'],
    data() {
      return {
        form: formData()
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
    created() {
      const instance = this.$contract.content;
      instance.getTitle(this.content_id).then(r => this.form.title = r);
      instance.getThumbnail(this.content_id).then(r => this.form.thumbnail = r);
      instance.getSynopsis(this.content_id).then(r => this.form.synopsis = r);
      instance.getGenres(this.content_id).then(r => this.form.genres = r);
      instance.getMarketerRate(this.content_id).then(r => this.form.marketerRate = r);
      instance.getTranslatorRate(this.content_id).then(r => this.form.translatorRate = r);
    }
  }
</script>

<style scoped>
</style>
