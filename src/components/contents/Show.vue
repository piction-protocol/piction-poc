<template>
  <div>
    <Form
      :record="record"
      action="show"
      submitText="작품수정"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Form from './Form'
  import {record} from './helper'

  export default {
    props: ['content_id'],
    components: {Form},
    data() {
      return {
        record: record(),
      }
    },
    methods: {
      onSubmit() {
        this.$router.push({name: 'edit-content', params: {content_id: this.content_id}});
      }
    },
    async created() {
      this.record = JSON.parse(result.record_);
      this.record.marketerRate = Number(result.marketerRate_)
    }
  }
</script>

<style scoped>
</style>
