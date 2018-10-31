<template>
  <div>
    <div class="page-title">Waiting for supporters</div>
    <br>
    <b-tabs>
      <template slot="tabs">
        <b-nav-item slot="tabs" @click="setTab('opened')" :active="!$route.hash || $route.hash == '#opened'">Opened
        </b-nav-item>
      </template>
      <template slot="tabs">
        <b-nav-item slot="tabs" @click="setTab('closed')" :active="$route.hash == '#closed'">Closed</b-nav-item>
      </template>
    </b-tabs>
    <br>
    <b-row>
      <b-col cols="12" sm="6" md="4" lg="3"
             v-for="fund in filteredFunds"
             :key="fund.address">
        <Item :fund="fund"/>
      </b-col>
    </b-row>
  </div>
</template>

<script>
  import Item from './Item'

  export default {
    components: {Item},
    computed: {
      filteredFunds() {
        if (!this.$route.hash || this.$route.hash == '#opened') {
          return this.funds.filter(fund => this.$root.now.between(fund.startTime, fund.endTime) && fund.rise != fund.maxcap);
        } else {
          return this.funds.filter(fund => this.$root.now > fund.endTime || fund.rise == fund.maxcap);
        }
      }
    },
    data() {
      return {
        funds: [],
      }
    },
    methods: {
      async setFunds() {
        const funds = await this.$contract.apiFund.getFunds(this);
        this.funds = funds.reverse();
      },
      async setEvent() {
        this.web3Events.push(this.$contract.apiFund.getContract().events
          .CreateFund({fromBlock: 'latest'}, async () => this.setFunds()));
      },
      async setTab(tab) {
        this.$router.replace({hash: `#${tab}`});
      }
    },
    async created() {
      this.setEvent();
      this.setFunds();
    },
  }
</script>

<style scoped>
</style>
