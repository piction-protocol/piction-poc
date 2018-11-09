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
  import Form from './Form'
  import ComicForm from '@forms/ComicForm'

  export default {
    components: {Form},
    props: ['comic_id'],
    data() {
      return {
        form: new ComicForm()
      }
    },
    methods: {
      async onSubmit(form) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiContents.updateComic(this.comic_id, form);
          this.$router.push({name: 'publish-info', params: {comic_id: this.comic_id}});
        } catch (e) {
          alert(e)
        }
        loader.hide();
      },
    },
    async created() {
      const comic = await this.$contract.apiContents.getComic(this.comic_id);
      this.form = new ComicForm(comic);
    }
  }
</script>

<style scoped>
</style>
