<template>
  <div>
    <Form
      :record="record"
      action="edit"
      submitText="작품수정"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Form from './Form'
  import {record} from './helper'

  export default {
    components: {Form},
    props: ['content_id'],
    data() {
      return {
        record: record(),
      }
    },
    methods: {
      async onSubmit(record, marketerRate) {
        this.$loading('Uploading...');
        try {
          await this.$contract.apiContents.updateContent(this.content_id, record);
          this.$router.push({name: 'episodes', params: {content_id: this.content_id}})
        } catch (e) {
          alert(e)
        }
        this.$loading.close();
      },
    },
    created() {
      this.$contract.contentInterface.getRecord(this.content_id)
        .then(r => this.record = JSON.parse(r));
    }
  }
</script>

<style scoped>
</style>
