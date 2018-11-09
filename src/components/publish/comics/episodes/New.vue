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
  import EpisodeForm from '@forms/EpisodeForm'
  import Form from './Form'

  export default {
    components: {Form},
    props: ['comic_id'],
    data() {
      return {
        form: new EpisodeForm()
      }
    },
    methods: {
      async onSubmit(form) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiContents.createEpisode(this.comic_id, form);
          this.$router.push({name: 'publish-episodes', params: {comic_id: this.comic_id}})
        } catch (e) {
          alert(e)
        }
        loader.hide();
      },
    },
    created() {
    }
  }
</script>

<style scoped>
</style>