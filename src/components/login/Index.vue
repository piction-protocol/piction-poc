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
