<template>
  <div>
    <Form
      :record="record"
      action="new"
      submitText="회차등록"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Form from './Form'
  import {record, genres} from './helper'

  export default {
    components: {Form},
    props: ['content_id'],
    data() {
      return {
        record: record(),
      }
    },
    methods: {
      async onSubmit(record) {
        let loader = this.$loading.show();
        try {
          var price = record.price;
          var cuts = record.cuts;
          var _record = JSON.parse(JSON.stringify(record));
          delete _record['cuts'];
          delete _record['price'];
          await this.$contract.apiContents.addEpisode(this.content_id, _record, cuts, price);
          this.$router.push({name: 'episodes', params: {content_id: this.content_id}})
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
