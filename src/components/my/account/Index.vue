<template>
  <div role="group">
    <h5>아이디</h5>
    <b-input-group>
      <b-form-input id="inputLive"
                    v-model.trim="name"
                    type="text"
                    :disabled="registered"
                    :state="nameState"
                    aria-describedby="inputLiveHelp inputLiveFeedback"
                    placeholder="아이디를 입력하세요"></b-form-input>
      <b-input-group-append>
        <b-button :disabled="!nameState" v-if="!registered" variant="success" @click="submit()">1,000 PXL 무료지급
        </b-button>
      </b-input-group-append>
      <b-form-invalid-feedback id="inputLiveFeedback">
        Enter at least 3 letters
      </b-form-invalid-feedback>
    </b-input-group>
    <br>
    <h5>비밀키</h5>
    <b-alert variant="danger" show>
      <div>비밀키는 로그인할 때 사용됩니다. 로그아웃하면 비밀키를 다시 찾을 수 없습니다.</div>
      <div>비밀키 보이기를 누르고 비밀키를 안전한 곳에 보관하세요.</div>
    </b-alert>
    <b-input-group>
      <b-input-group-append>
        <b-button variant="success" @click="showHidePrivateKey()">{{privateKey ? '감추기' : '보이기'}}</b-button>
      </b-input-group-append>
      <b-form-input v-model.trim="privateKey"
                    type="text"
                    :disabled="true"></b-form-input>
    </b-input-group>
    <br>
    <b-button variant="danger" @click="logout()" class="w-100">Logout</b-button>
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
    computed: {
      nameState() {
        return this.name && this.name.length > 2 ? true : false
      }
    },
    data() {
      return {
        registered: true,
        name: null,
        privateKey: null,
      }
    },
    methods: {
      showHidePrivateKey() {
        if (this.privateKey) {
          this.privateKey = null;
        } else {
          this.privateKey = web3.eth.accounts.wallet[0].privateKey;
        }
      },
      logout() {
        this.$store.dispatch('LOGOUT');
        window.location.reload();
      },
      async submit() {
        const userName = await this.$contract.accountManager.getUserName(this.pictionAddress.account);
        const address = await this.$contract.accountManager.getUserAddress(this.name);
        if (userName) {
          this.$toast.center('이미 등록된 주소입니다');
        } else if (address > 0) {
          this.$toast.center('이미 등록된 사용자명입니다');
        } else {
          this.$loading('loading...');
          try {
            await this.$contract.accountManager.createAccount(this.name);
            this.registered = true;
          } catch (e) {
            alert(e)
          }
          this.$loading.close();
        }
      },
    },
    async created() {
      this.name = await this.$contract.accountManager.getUserName(this.pictionAddress.account);
      this.registered = (this.name != null && this.name.length > 0);
    }
  }
</script>

<style scoped>

</style>
