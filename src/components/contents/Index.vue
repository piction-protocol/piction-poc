<template>
  <div>
    <Item v-for="content in contents"
          :content="content"
          :key="content.id"/>
  </div>
</template>

<script>
  import Item from './Item'

  export default {
    components: {Item},
    data() {
      return {
        contents: [],
      }
    },
    methods: {},
    async created() {
      let result = await this.$contract.apiContents.getContentsFullList();
      let addrs = result.contentsAddress_;
      let records = JSON.parse(web3.utils.hexToUtf8(result.records_));
      let writers = await this.$contract.apiContents.getContentsWriterName(addrs);
      writers = this.$utils.bytesToArray(writers.writerName_, writers.spos_, writers.epos_);
      records.forEach((record, i) => {
        record.id = addrs[i];
        record.writerName = writers[i];
      });
      this.contents = records.reverse();
      console.log(this.contents)
    }
  }
</script>

<style scoped>
  div {
  }
</style>
