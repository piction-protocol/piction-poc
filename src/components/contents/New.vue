<template>
  <div>
    <Form
      :record="record"
      action="new"
      submitText="작품등록"
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
        this.$loading('Uploading...');
        try {
          await this.$contract.contentsManager.addContents(record);
          this.$router.push({name: 'contents'})
        } catch (e) {
          alert(e)
        }
        this.$loading.close();
      },
    },
    created() {
      this.record.genres = genres[0].value
    }
  }
</script>

<style scoped>
</style>
