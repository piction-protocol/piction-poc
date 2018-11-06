<template>
  <div class="pt-5">
    <div class="p-4 bg-light shadow p-3 rounded" style="max-width: 500px; margin: 0 auto">
      <h4 class="text-center">회 원 가 입</h4>
      <hr>
      <b-form-group
        label="닉네임"
        label-for="userName"
        :invalid-feedback="userNameInvalidFeedback"
        :valid-feedback="userNameValidFeedback"
        :state="userNameState"
        v-model.trim="userName">
        <b-form-input id="userName" :state="userNameState" v-model.trim="userName"></b-form-input>
      </b-form-group>

      <b-form-group
        label="비밀번호"
        label-for="password"
        :invalid-feedback="passwordInvalidFeedback"
        :valid-feedback="passwordValidFeedback"
        :state="passwordState"
        v-model.trim="password">
        <b-form-input id="password" type="password" :state="passwordState" v-model.trim="password" @keydown.enter.native="join"></b-form-input>
      </b-form-group>
      <hr>
      <div align="center">
        <b-button variant="primary" class="my-2 my-sm-0" @click="join" block>회원가입</b-button>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    computed: {
      userNameState() {
        return this.userName.length > 2 ? true : false
      },
      passwordState() {
        return this.password.length > 2 ? true : false
      },
      userNameInvalidFeedback() {
        if (this.userName.length > 2) {
          return ''
        } else if (this.userName.length > 0) {
          return '닉네임은 3글자 이상입니다'
        } else {
          return '닉네임을 입력하세요'
        }
      },
      passwordInvalidFeedback() {
        if (this.password.length > 2) {
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
        
        if(this.userNameInvalidFeedback != '') {
          alert(this.userNameInvalidFeedback);
          return;
        }

        if(this.passwordInvalidFeedback != '') {
          alert(this.passwordInvalidFeedback);
          return;
        }

        let loader = this.$loading.show();
        const isRegistered = await this.$contract.accountManager.isRegistered(this.userName);
        if (isRegistered) {
          loader.hide();
          alert('사용중인 닉네임입니다')
          return;
        }

        try {
          const account = await web3.eth.accounts.create();
          await web3.eth.accounts.wallet.add(account.privateKey);
          await this.$contract.accountManager.createNewAccount(this.userName, this.password, account.privateKey, account.address);
          this.$store.dispatch('LOGIN', {name: this.userName, token: account.privateKey});
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
