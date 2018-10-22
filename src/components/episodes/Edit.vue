<template>
  <div>
    <Form
      :episode="episode"
      action="edit"
      submitText="수정"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Episode from '@models/Episode'
  import Form from './Form'

  export default {
    components: {Form},
    props: ['comic_id', 'episode_id'],
    data() {
      return {
        episode: new Episode()
      }
    },
    methods: {
      async onSubmit(episode) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiContents.updateEpisode(this.comic_id, episode);
          this.$router.push({name: 'episodes', params: {comic_id: this.comic_id}})
        } catch (e) {
          alert(e)
        }
        loader.hide();
      },
    },
    async created() {
      this.episode = await this.$contract.apiContents.getEpisode(this.comic_id, this.episode_id);
    }
  }
</script>

<style scoped>
</style>