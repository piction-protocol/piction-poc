<template>
  <div>
    <br>
    <h5>로그인 / 회원가입</h5>
    <b-alert show variant="secondary">
      <b-input-group>
        <b-form-input v-model.trim="privateKey" type="text" placeholder="비밀키를 입력하세요."/>
        <b-input-group-append>
          <b-button variant="primary" @click="login">로그인</b-button>
        </b-input-group-append>
      </b-input-group>
      <hr>
      <div align="center">
        <span>계정이 없으신가요? </span><b-link @click="join"><b>회원가입</b></b-link>
      </div>
    </b-alert>
  </div>
</template>

<script>
  export default {
    data() {
      return {
        privateKey: null,
      }
    },
    methods: {
      login: function () {
        if (this.privateKey.indexOf('0x') == -1) {
          this.privateKey = '0x' + this.privateKey;
        }
        try {
          web3.eth.accounts.privateKeyToAccount(this.privateKey);
          this.$store.dispatch('LOGIN', this.privateKey);
          window.location.reload();
        } catch (e) {
          this.privateKey = null;
          alert('등록되지 않거나 잘못된 비밀키입니다')
        }
      },
      join: async function () {
        this.$loading('loading...');
        const account = web3.eth.accounts.create();
//        web3.eth.accounts.wallet.add(`0x441CAA3B82A5ED3D67D96FCD6971491D1887C3B1B416A61D55D844DE48BF3FBF`)
//        await web3.eth.sendTransaction({
//          from: '0xB595c1D6c14aE9Ea94F55a481C93EC10c4C00581',
//          to: account.address,
//          value: this.$utils.appendDecimals(1),
//          gasLimit: 21000,
//          gasPrice: 10000000000
//        });
        this.$store.dispatch('LOGIN', account.privateKey);
        window.location.reload();
      }
    },
    created() {
    }
  }
</script>

<style scoped>
</style>
