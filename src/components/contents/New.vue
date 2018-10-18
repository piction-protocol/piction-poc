<template>
  <div>
    <Form
      :record="record"
      action="new"
      submitText="등록"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Form from './Form'
  import {record, genres} from './helper'

  export default {
    components: {Form},
    data() {
      return {
        record: record(),
      }
    },
    methods: {
      async onSubmit(record) {
        let loader = this.$loading.show();
        try {
          await this.$contract.apiContents.addContents(record);
          this.$router.push({name: 'contents'})
        } catch (e) {
          alert(e)
        }
        loader.hide();
      },
    },
    created() {
      this.record.genres = genres[0].value
    }
  }
</script>

<style scoped>
</style>
