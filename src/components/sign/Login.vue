<template>
  <div class="pt-5">
    <div class="p-4 bg-light shadow p-3 rounded" style="max-width: 500px; margin: 0 auto">
      <h4 class="text-center">로그인</h4>
      <hr>
      <b-form-group
        label="닉네임"
        label-for="userName"
        :invalid-feedback="userNameInvalidFeedback"
        :valid-feedback="userNameValidFeedback"
        :state="userNameState">
        <b-form-input id="userName" :state="userNameState" v-model.trim="userName"></b-form-input>
      </b-form-group>

      <b-form-group
        label="비밀번호"
        label-for="password"
        :invalid-feedback="passwordInvalidFeedback"
        :valid-feedback="passwordValidFeedback"
        :state="passwordState">
        <b-form-input id="password" type="password" :state="passwordState" v-model.trim="password"></b-form-input>
      </b-form-group>
      <hr>
      <div align="center">
        <b-button variant="primary" class="my-2 my-sm-0" @click="login" block>로그인</b-button>
        <br>
        <span>계정이 없으신가요? </span>
        <b-link @click="join"><b>회원가입</b></b-link>

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
          return '닉네임은 3글자 이상입니다'
        } else {
          return '닉네임을 입력하세요'
        }
      },
      passwordInvalidFeedback() {
        if (this.password.length > 3) {
          return ''
        } else if (this.password.length > 0) {
          return '비밀번호는 3글자 이상입니다'
        } else {
          return '비밀번호를 입력하세요'
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
        this.$router.push({name: 'join', query: this.$router.history.current.query})
      },
      login: async function () {
        this.$loading('loading...');
        const loginInfo = await this.$contract.accountManager.login(this.userName, this.password);
        if (!loginInfo.result_) {
          alert('닉네임 혹은 비밀번호가 일치하지 않습니다')
          this.$loading.close();
          return;
        }
        try {
          await web3.eth.accounts.wallet.add(loginInfo.key_);
          this.$store.dispatch('LOGIN', loginInfo.key_);
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
