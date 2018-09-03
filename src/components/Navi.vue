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
        </b-navbar-nav>
        <b-navbar-nav class="ml-auto">
          <b-nav-item style="margin-right: 10px;"><b class="pxl">{{pxl}} PXL</b></b-nav-item>
          <b-nav-form>
            <!--<b-button variant="outline-success" class="my-2 my-sm-0" :to="{name:'new-content'}">Create</b-button>-->
            <b-button variant="outline-success" class="my-2 my-sm-0" @click="newContents">Create</b-button>
          </b-nav-form>
        </b-navbar-nav>
      </b-collapse>
    </b-navbar>
  </div>
</template>

<script>
  import {BigNumber} from 'bignumber.js';

  export default {
    name: 'Navi',
    data() {
      return {
        pxl: 0,
      }
    },
    methods: {
      updatePXL: async function () {
        let pxl = await this.$contract.pxl.balanceOf(this.pictionAddress.account);
        this.pxl = this.$utils.toPXL(pxl);
      },
      newContents: async function () {
        let deposit = BigNumber(await this.$contract.contentsManager.getInitialDeposit(this.pictionAddress.account));
        let initialDeposit = BigNumber(this.pictionValue.initialDeposit);
        let pxl = BigNumber(await this.$contract.pxl.balanceOf(this.pictionAddress.account));
        let message = `Initial deposit ${this.$utils.toPXL(initialDeposit)} PXL is required to register content.`;
        if (deposit.eq(initialDeposit)) {
          this.$router.push({name: 'new-content'});
        } else if (pxl.lt(initialDeposit)) {
          alert(message)
        } else if (confirm(`${message}\nWould you like to register?`)) {
          await this.$contract.pxl.approveAndCall(this.pictionAddress.contentsManager, this.pictionValue.initialDeposit);
          this.updatePXL();
          this.$router.push({name: 'new-content'});
        }
      }
    },
    async created() {
      this.updatePXL();
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
