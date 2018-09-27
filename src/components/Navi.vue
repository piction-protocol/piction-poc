<template>
  <div class="navi">
    <b-navbar fixed="top" toggleable="md" type="light" variant="light">
      <b-navbar-toggle target="nav_collapse"></b-navbar-toggle>
      <b-navbar-brand href="/">
        <img style="width: 100%" src="../assets/icon.png"/>
      </b-navbar-brand>
      <b-collapse is-nav id="nav_collapse">
        <b-navbar-nav>
          <router-link active-class="active" class="nav-link" to="/contents">Comics</router-link>
          <router-link active-class="active" class="nav-link" to="/funds">Funds</router-link>
          <router-link active-class="active" class="nav-link" to="/my">My</router-link>
          <router-link active-class="active" class="nav-link" to="/council">Council</router-link>
        </b-navbar-nav>
        <b-navbar-nav class="ml-auto">
          <b-nav-item style="margin-right: 10px;" v-b-tooltip.hover :title="pxl">
            <animated-number
              class="pxl"
              :value="pxl"
              :formatValue="formatValue"
              :duration="1000"/>
          </b-nav-item>
          <b-nav-form>
            <b-button variant="outline-success" class="my-2 my-sm-0" @click="newContents">작품등록</b-button>
          </b-nav-form>
        </b-navbar-nav>
      </b-collapse>
    </b-navbar>
  </div>
</template>

<script>
  import {BigNumber} from 'bignumber.js';
  import AnimatedNumber from "animated-number-vue";

  export default {
    components: {
      AnimatedNumber
    },
    data() {
      return {
        pxl: 0,
      }
    },
    methods: {
      formatValue(value) {
        return `${value.toFixed(2)} PXL`;
      },
      updatePXL() {
        this.$contract.pxl.balanceOf(this.pictionConfig.account).then(pxl => {
          this.pxl = this.$utils.toPXL(pxl);
        });
      },
      async newContents() {
        this.$loading('loading...');
        let deposit = BigNumber(await this.$contract.contentsManager.getInitialDeposit(this.pictionConfig.account));
        let initialDeposit = BigNumber(this.pictionConfig.pictionValue.initialDeposit);
        let pxl = BigNumber(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
        let message = `작품을 등록하려면 예치금 ${this.$utils.toPXL(initialDeposit)} PXL 이 필요합니다.`;
        if (deposit.eq(initialDeposit)) {
          this.$router.push({name: 'new-content'});
        } else if (pxl.lt(initialDeposit)) {
          alert(message)
        } else if (confirm(`${message}\n등록하시겠습니까?`)) {
          await this.$contract.pxl.approveAndCall(this.pictionConfig.managerAddress.contentsManager, this.pictionConfig.pictionValue.initialDeposit);
          this.$router.push({name: 'new-content'});
        }
        this.$loading.close();
      }
    },
    async created() {
      this.updatePXL();
      this.$contract.pxl.getEvents().Transfer({
        filter: {from: this.pictionConfig.account},
        fromBlock: 'latest',
        toBlock: 'latest'
      }, (error, event) => this.updatePXL())
      this.$contract.pxl.getEvents().Transfer({
        filter: {to: this.pictionConfig.account},
        fromBlock: 'latest',
        toBlock: 'latest'
      }, (error, event) => this.updatePXL())
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  nav {
    border-bottom: 1px solid #ff6e27;
  }

  .pxl {
    color: #ff6e27;
    font-size: 1.2em;
  }
</style>
