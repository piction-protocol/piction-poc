<template>
  <div>
    <div style="font-size: 36px; font-weight: bold">Comics</div>
    <br>
    <b-row>
      <b-col cols="12" sm="6" md="4" lg="3"
             v-for="content in contents"
             :key="content.id">
        <Item :content="content"/>
      </b-col>
    </b-row>
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
    methods: {
      async loadList() {
        let result = await this.$contract.apiContents.getContentsFullList();
        if (result.contentsAddress_.length == 0) return;
        let addrs = result.contentsAddress_;
        let records = JSON.parse(web3.utils.hexToUtf8(result.records_));
        let writers = await this.$contract.apiContents.getContentsWriterName(addrs);
        writers = this.$utils.bytesToArray(writers.writerName_, writers.spos_, writers.epos_);
        records.forEach((record, i) => {
          record.id = addrs[i];
          record.writerName = writers[i];
        });
        this.contents = records.reverse();
      },
      setEvent() {
        this.$contract.apiContents.setRegisterContents((error, event) => {
          var record = JSON.parse(event.returnValues._record);
          record.id = event.returnValues._contentsAddress;
          record.writerName = event.returnValues._writerName;
          this.contents.splice(0, 0, record);
        });
      }
    },
    async created() {
      this.setEvent();
      this.loadList();
    }
  }
</script>

<style scoped>
</style>
