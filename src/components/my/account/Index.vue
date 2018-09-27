<template>
  <div role="group">
    <h5>닉네임:  <span>{{name}}</span></h5>
    <b-button variant="danger" @click="logout()" class="w-100">로그아웃</b-button>
    <hr>
    <b-row>
      <b-col>
        <ContentDeposit/>
      </b-col>
      <b-col>
        <ReportDeposit/>
      </b-col>
    </b-row>
  </div>
</template>

<script>
  import ContentDeposit from './ContentDeposit'
  import ReportDeposit from './ReportDeposit'
  import {BigNumber} from 'bignumber.js';

  export default {
    components: {ContentDeposit, ReportDeposit},
    data() {
      return {
        name: null,
      }
    },
    methods: {
      logout() {
        this.$store.dispatch('LOGOUT');
        window.location.reload();
      },
    },
    async created() {
      const account = await this.$contract.accountManager.getUserName(this.pictionConfig.account);
      this.name = account.userName_;
    }
  }
</script>

<style scoped>

</style>
