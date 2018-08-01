<template>
  <div>
    <Form
      :record="record"
      action="new"
      submitText="Create"
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
          let contract = await this.$contract.contentsManager.addContents(record);
          let address = contract.events['RegisterContents'].returnValues._contentAddress;
          this.$router.push({name: 'show-content', params: {content_id: address}})
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
