<template>
  <div>
    <Form
      :record="record"
      action="show"
      submitText="Edit"
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
      await this.$contract.contentInterface.getRecord(this.content_id)
        .then(r => this.record = JSON.parse(r));
    }
  }
</script>

<style scoped>
</style>
