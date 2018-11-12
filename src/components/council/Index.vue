<template>
  <div>
    <div class="row">
      <div class="col-6 col-md-4">
        <div class="page-title">{{$t('위원회')}}</div>
      </div>
      <div class="col-12 col-sm-6 col-md-8">
        <div class="radio">
          <b-form-radio-group v-model="selected" :options="options"/>
        </div>
      </div>
    </div>
    <br>
    <br>
    <b-row>
      <b-col cols="12" sm="6" md="4" lg="3"
             v-for="council in filteredCouncil"
             :key="council.comic.address">
        <Item :council="council"/>
      </b-col>
    </b-row>
  </div>
</template>

<script>
  import Item from './Item'
  import Council from '@models/Council'
  import Web3Utils from '@utils/Web3Utils'

  export default {
    components: {Item},
    computed: {
      filteredCouncil() {
        if (this.selected == 'first') {
          return this.council.sort((a, b) => a.lastReportTime - b.lastReportTime).reverse();
        } else {
          return this.council.sort((a, b) => b.uncompletedReportCount - a.uncompletedReportCount);
        }
      }
    },
    data() {
      return {
        council: [],
        selected: 'first',
        options: [
        { text: this.$t('council.index.option.first'), value: 'first' },
        { text: this.$t('council.index.option.second'), value: 'second' }
      ]
      }
    },
    methods: {
      async setComics() {
        let list = [];
        
        let comics = await this.$contract.apiContents.getComics(this);
        
        comics.forEach(async comic => {
          let council = new Council();
          council.comic = comic;
          council.uncompletedReportCount = await this.$contract.apiReport.getUncompletedReportCount(comic.address);
          
          let events = await this.$contract.report.getReportList(comic.address);
          events = events.map(event => Web3Utils.prettyJSON(event.returnValues));
          
          if (events.length > 0) {
            let max = events.reduce((previous, current) => previous.date > current.date ? previous:current);
            council.lastReportTime = max.date;
          }

          list.push(council);
        });
        this.council = list;
      }
    },
    async created() {
      this.setComics();
    }
  }
</script>

<style scoped>
  .radio {
    text-align: right;
  }
</style>