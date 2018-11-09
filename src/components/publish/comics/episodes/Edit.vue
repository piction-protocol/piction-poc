<template>
  <div>
    <Form
      :form="form"
      action="edit"
      :submitText="$t('수정')"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import EpisodeForm from '@forms/EpisodeForm'
  import Form from './Form'

  export default {
    components: {Form},
    props: ['comic_id', 'episode_id'],
    data() {
      return {
        form: new EpisodeForm()
      }
    },
    methods: {
      async onSubmit(form) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiContents.updateEpisode(this.comic_id, form);
          this.$router.replace({name: 'publish-episodes', params: {comic_id: this.comic_id}})
        } catch (e) {
          alert(e)
        }
        loader.hide();
      },
    },
    async created() {
      const episode = await this.$contract.apiContents.getEpisode(this.comic_id, this.episode_id);
      this.form = new EpisodeForm(episode)
    }
  }
</script>

<style scoped>
</style>