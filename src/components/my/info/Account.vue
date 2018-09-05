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
        <b-button :disabled="!nameState" v-if="!registered" variant="success" @click="submit()">Airdrop 1,000 PXL
        </b-button>
      </b-input-group-append>
      <b-form-invalid-feedback id="inputLiveFeedback">
        Enter at least 3 letters
      </b-form-invalid-feedback>
    </b-input-group>
  </div>
</template>

<script>
  export default {
    computed: {
      nameState() {
        return this.name && this.name.length > 2 ? true : false
      }
    },
    data() {
      return {
        registered: true,
        name: null
      }
    },
    methods: {
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
            window.location.reload()
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
