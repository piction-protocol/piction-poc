<template>
  <div>
    <Form
      :record="record"
      action="edit"
      submitText="회차수정"
      @onSubmit="onSubmit"></Form>
  </div>
</template>

<script>
  import Form from './Form'
  import {record, genres} from './helper'

  export default {
    components: {Form},
    props: ['content_id', 'episode_id'],
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
          await this.$contract.apiContents.updateEpisode(this.content_id, this.episode_id, _record, cuts, price);
          this.$router.push({name: 'episodes', params: {content_id: this.content_id}})
        } catch (e) {
          alert(e)
        }
        loader.hide();
      },
    },
    async created() {
      const result = await this.$contract.apiContents.getEpisodeDetail(this.content_id, this.episode_id, this.pictionConfig.account);
      const record = JSON.parse(result.record_);
      this.record.title = record.title;
      this.record.thumbnail = record.thumbnail;
      this.record.price = this.$utils.toPXL(result.price_);
      const cuts = await this.$contract.apiContents.getEpisodeCuts(this.content_id, this.episode_id);
      this.record.cuts = JSON.parse(cuts);
    }
  }
</script>

<style scoped>
</style>
