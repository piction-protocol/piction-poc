<template>
  <div>
    <div class="d-flex justify-content-between align-items-end">
      <div class="page-title">Waiting for supporters</div>
      <b-form-select style="width: 150px;" :value="filter" @change="setFilter">
        <option :value="undefined">전체</option>
        <option :value="`in-progress`">진행중</option>
        <option :value="`completed`">종료</option>
      </b-form-select>
    </div>
    <br>
    <b-row>
      <b-col cols="12" sm="6" md="4" lg="3"
             v-for="fund in filteredFunds"
             :key="fund.fund">
        <Item :fund="fund" :disableLabel="filter=='completed'"/>
      </b-col>
    </b-row>
  </div>
</template>

<script>
  import Item from './Item'
  import Web3Utils from '../../utils/Web3Utils.js'

  export default {
    components: {Item},
    props: ['filter'],
    computed: {
      filteredFunds() {
        if (this.filter == 'in-progress') {
          return this.funds.filter(fund =>
            Number(fund.startTime) < this.$root.now && this.$root.now < Number(fund.endTime)
          );
        } else if (this.filter == 'completed') {
          return this.funds.filter(fund => this.$root.now > Number(fund.endTime));
        } else {
          return this.funds;
        }
      }
    },
    data() {
      return {
        selected: null,
        options: [
          {value: null, text: '전체'},
          {value: 'in-progress', text: '진행중'},
          {value: 'completed', text: '종료'},
        ],
        funds: [],
        events: []
      }
    },
    methods: {
      async init() {
        const funds = await this.$contract.apiFund.getFunds();
        const records = (await this.$contract.apiContents.getRecords(funds.map(fund => fund.content)));
        const rise = await this.$contract.apiFund.getFundRise(funds.map(fund => fund.fund));
        let writers = await this.$contract.apiContents.getContentsWriterName(funds.map(fund => fund.content));
        writers = this.$utils.bytesToArray(writers.writerName_, writers.spos_, writers.epos_);
        funds.forEach((fund, i) => {
          fund.record = records[i];
          fund.record.writerName = writers[i];
          fund.rise = rise[i]
        });
        this.funds = funds.reverse();
      },
      async setEvent() {
        const event = this.$contract.apiFund.getContract().events.AddFund({fromBlock: 'latest'}, async (error, event) => {
          this.init();
        });
        this.events.push(event);
      },
      setFilter(value) {
        this.$router.push({query: {filter: value}})
      },
    },
    async created() {
      this.setEvent();
      this.init();
    },
    async destroyed() {
      this.events.forEach(async event => await event.unsubscribe());
    }
  }
</script>

<style scoped>
</style>
