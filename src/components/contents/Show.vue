<template>
  <div>
    <Form
      :form="form"
      action="show"
      submitText="Edit"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Form from './Form'
  import {formData} from './helper'

  export default {
    props: ['content_id'],
    components: {Form},
    data() {
      return {
        form: formData(),
      }
    },
    methods: {
      onSubmit() {
        this.$router.push({name: 'edit-content', params: {content_id: this.content_id}});
      }
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
