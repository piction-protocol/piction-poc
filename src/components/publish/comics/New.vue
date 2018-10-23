<template>
  <div>
    <Form
      :comic="comic"
      action="new"
      submitText="등록"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Form from './Form'
  import Comic from '@models/Comic'

  export default {
    components: {Form},
    data() {
      return {
        comic: new Comic()
      }
    },
    methods: {
      async onSubmit(comic) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiContents.createComic(comic);
          this.$router.push({name: 'publish-comics'})
        } catch (e) {
          alert(e)
        }
        loader.hide();
      },
    },
    created() {
      this.comic.genres = Comic.genres[0].value
    }
  }
</script>

<style scoped>
</style>
