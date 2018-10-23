<template>
  <div>
    <Form
      :episode="episode"
      action="new"
      submitText="등록"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Episode from '@models/Episode'
  import Form from './Form'

  export default {
    components: {Form},
    props: ['comic_id'],
    data() {
      return {
        episode: new Episode()
      }
    },
    methods: {
      async onSubmit(episode) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiContents.createEpisode(this.comic_id, episode);
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