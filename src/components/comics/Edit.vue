<template>
  <div>
    <Form
      :comic="comic"
      action="edit"
      submitText="수정"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Form from './Form'
  import Comic from '@models/Comic'

  export default {
    components: {Form},
    props: ['comic_id'],
    data() {
      return {
        comic: new Comic().toJSON(),
      }
    },
    methods: {
      async onSubmit(comic) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiContents.updateComic(this.comic_id, comic);
          this.$router.push({name: 'episodes', params: {comic_id: this.comic_id}});
        } catch (e) {
          alert(e)
        }
        loader.hide();
      },
    },
    async created() {
      this.comic = await this.$contract.apiContents.getComic(this.comic_id);
    }
  }
</script>

<style scoped>
</style>
