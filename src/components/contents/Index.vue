<template>
  <div>
    <div class="d-flex justify-content-between align-items-end">
      <div class="page-title">Comics</div>
      <b-form-select style="width: 150px;" :value="genre" @change="setGenre">
        <option :value="undefined">전체</option>
        <option v-for="genre in genres" :value="genre.value">{{genre.text}}</option>
      </b-form-select>
    </div>
    <br>
    <b-row>
      <b-col cols="12" sm="6" md="4" lg="3"
             v-for="content in filteredContents"
             :key="content.id">
        <Item :content="content"/>
      </b-col>
    </b-row>
  </div>
</template>

<script>
  import Item from './Item'
  import {genres} from './helper'

  export default {
    components: {Item},
    props: ['genre'],
    computed: {
      filteredContents() {
        if (this.genre) {
          return this.contents.filter(content => content.genres == this.genre);
        } else {
          return this.contents;
        }
      }
    },
    data() {
      return {
        contents: [],
        genres: genres
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
      },
      setGenre(value) {
        this.$router.push({query: {genre: value}})
      },
    },
    async created() {
      this.setEvent();
      this.loadList();
    }
  }
</script>

<style scoped>
</style>
