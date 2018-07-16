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
