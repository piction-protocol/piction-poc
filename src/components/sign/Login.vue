<template>
  <div class="pt-5">
    <div class="p-4 bg-light shadow p-3 rounded" style="max-width: 500px; margin: 0 auto">
      <h4 class="text-center">{{$t('login')}}</h4>
      <hr>
      <b-form-group
        :label="$t('userName')"
        label-for="userName"
        :invalid-feedback="userNameInvalidFeedback"
        :valid-feedback="userNameValidFeedback"
        :state="userNameState">
        <b-form-input id="userName" :state="userNameState" v-model.trim="userName"></b-form-input>
      </b-form-group>

      <b-form-group
        :label="$t('password')"
        label-for="password"
        :invalid-feedback="passwordInvalidFeedback"
        :valid-feedback="passwordValidFeedback"
        :state="passwordState">
        <b-form-input id="password" type="password" :state="passwordState" v-model.trim="password" @keydown.enter.native="login"></b-form-input>
      </b-form-group>
      <hr>
      <div align="center">
        <b-button variant="primary" class="my-2 my-sm-0" @click="login" block>{{$t('login')}}</b-button>
        <br>
        <span>{{$t('signUpText')}} </span>
        <b-link @click="join"><b>{{$t('signUp')}}</b></b-link>

      </div>

    </div>
  </div>
</template>

<script>
  export default {
    computed: {
      userNameState() {
        return this.userName.length >= 3 ? true : false
      },
      passwordState() {
        return this.password.length >= 3 ? true : false
      },
      userNameInvalidFeedback() {
        if (this.userName.length > 3) {
          return ''
        } else if (this.userName.length > 0) {
          return this.$t('nameLengthValidation')
        } else {
          return this.$t('emptyNameValidation')
        }
      },
      passwordInvalidFeedback() {
        if (this.password.length > 3) {
          return ''
        } else if (this.password.length > 0) {
          return this.$t('pwLengthValidation')
        } else {
          return this.$t('emptyPwValidation')
        }
      },
      userNameValidFeedback() {
        return this.userNameState === true ? 'Good' : ''
      },
      passwordValidFeedback() {
        return this.passwordState === true ? 'Good' : ''
      }
    },
    data() {
      return {
        userName: '',
        password: '',
      }
    },
    methods: {
      join: async function () {
        this.$router.push({name: 'join', query: this.$route.query})
      },
      login: async function () {
        let loader = this.$loading.show();
        const loginInfo = await this.$contract.accountManager.login(this.userName, this.password);
        if (!loginInfo.result_) {
          loader.hide();
          alert('닉네임 혹은 비밀번호가 일치하지 않습니다')
          return;
        }
        try {
          await web3.eth.accounts.wallet.add(loginInfo.key_);
          this.$store.dispatch('LOGIN', {name: this.userName, token: loginInfo.key_});
        } catch (e) {
          alert(e);
        }
        window.location.reload();
      }
    },
    created() {
    }
  }
</script>

<style scoped>
</style>
