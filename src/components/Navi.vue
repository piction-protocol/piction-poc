<template>
  <div class="navi">
    <b-navbar fixed="top" toggleable="md" type="light" variant="light">
      <b-navbar-toggle target="nav_collapse"></b-navbar-toggle>
      <b-navbar-brand href="/">
        <img style="width: 100%" src="../assets/icon.png"/>
      </b-navbar-brand>
      <b-collapse is-nav id="nav_collapse">
        <b-navbar-nav>
          <router-link active-class="active" class="nav-link" :to="{name: 'comics'}">Comics</router-link>
          <router-link active-class="active" class="nav-link" :to="{name: 'funds'}">Waiting for supporters</router-link>
          <router-link active-class="active" class="nav-link" :to="{name: 'account'}">My</router-link>
          <router-link active-class="active" class="nav-link" :to="{name: 'council'}">Council</router-link>
        </b-navbar-nav>
        <b-navbar-nav class="ml-auto">
          <b-nav-item style="margin-right: 10px;" v-b-tooltip.hover :title="pxl">
            <animated-number
              class="pxl"
              :class="{'pxl-change': pxlChange}"
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
        pxlChange: false,
      }
    },
    methods: {
      formatValue(value) {
        return `${value.toFixed(2)} PXL`;
      },
      updatePXL() {
        this.pxlChange = false;
        this.$contract.pxl.balanceOf(this.pictionConfig.account).then(pxl => {
          this.pxl = this.$utils.toPXL(pxl);
          this.pxlChange = true;
        });
      },
      async newContents() {
        let deposit = BigNumber(await this.$contract.apiContents.getInitialDeposit(this.pictionConfig.account));
        let initialDeposit = BigNumber(this.pictionConfig.pictionValue.initialDeposit);
        let pxl = BigNumber(await this.$contract.pxl.balanceOf(this.pictionConfig.account));
        let message = `작품을 등록하려면 예치금 ${this.$utils.toPXL(initialDeposit)} PXL 이 필요합니다.`;
        if (deposit.eq(initialDeposit)) {
          this.$router.push({name: 'new-comic'});
        } else if (pxl.lt(initialDeposit)) {
          alert(message)
        } else if (confirm(`${message}\n등록하시겠습니까?`)) {
          let loader = this.$loading.show();
          await this.$contract.pxl.approveAndCall(this.pictionConfig.managerAddress.contentsManager, this.pictionConfig.pictionValue.initialDeposit);
          loader.hide();
          this.$router.push({name: 'new-comic'});
        }
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

  .active {
    color: #0046EC !important;
  }

  .pxl {
    color: #ff6e27;
    font-size: 1.2em;
  }
</style>
