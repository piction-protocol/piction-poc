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
          <router-link active-class="active" class="nav-link" :to="{name: 'publish-comics'}">Publish</router-link>
          <router-link active-class="active" class="nav-link" :to="{name: 'council'}">Council</router-link>
        </b-navbar-nav>
        <b-navbar-nav class="ml-auto">
          <b-nav-item v-if="$store.getters.name" style="margin-right: 10px;" v-b-tooltip.hover :title="pxl">
            <animated-number
              class="pxl"
              :class="{'pxl-change': pxlChange}"
              :value="pxl.toString()"
              :formatValue="formatValue"
              :duration="1000"/>
          </b-nav-item>
          <b-nav-item-dropdown v-if="$store.getters.name" :text="$store.getters.name" right>
            <b-dropdown-item :to="{name: 'account'}">{{$t('내정보')}}</b-dropdown-item>
            <b-dropdown-item :to="{name: 'my-fund-comics'}">{{$t('투자관리')}}</b-dropdown-item>
            <b-dropdown-item :to="{name: 'user-payback'}">{{$t('작품구매보상')}}</b-dropdown-item>
            <b-dropdown-item :to="{name: 'my-reports'}">{{$t('신고처리내역')}}</b-dropdown-item>
            <b-dropdown-item @click="logout">{{$t('로그아웃')}}</b-dropdown-item>
          </b-nav-item-dropdown>
          <b-nav-item-dropdown :text="$t($store.getters.locale)" right>
            <b-dropdown-item @click="setLocale('en')">{{$t('en')}}</b-dropdown-item>
            <b-dropdown-item @click="setLocale('ko')">{{$t('ko')}}</b-dropdown-item>
          </b-nav-item-dropdown>
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
        pxl: '0',
        pxlChange: false,
      }
    },
    methods: {
      setLocale(val) {
        this.$store.dispatch('SET_LOCALE', val);
        window.location.reload();
      },
      formatValue(value) {
        return `${value.toFixed(2)} PXL`;
      },
      updatePXL() {
        this.pxlChange = false;
        this.$contract.pxl.balanceOf(this.pictionConfig.account).then(pxl => {
          this.pxl = web3.utils.fromWei(new this.web3.utils.BN(pxl));
          this.pxlChange = true;
        });
      },
      logout() {
        this.$store.dispatch('LOGOUT');
        window.location.reload();
      },
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
    font-weight: bold;
  }
</style>
