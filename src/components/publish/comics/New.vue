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
  import Form from './Form'
  import ComicForm from '@forms/ComicForm'

  export default {
    components: {Form},
    data() {
      return {
        form: new ComicForm()
      }
    },
    methods: {
      async onSubmit(form) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiContents.createComic(form);
          this.$router.push({name: 'publish-comics'})
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
