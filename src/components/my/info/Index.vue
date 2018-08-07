<template>
  <div role="group">
    <label for="inputLive">Name:</label>
    <b-form-input id="inputLive"
                  v-model.trim="name"
                  type="text"
                  :disabled="registered"
                  :state="nameState"
                  aria-describedby="inputLiveHelp inputLiveFeedback"
                  placeholder="Enter your name"></b-form-input>
    <b-form-invalid-feedback id="inputLiveFeedback">
      <!-- This will only be shown if the preceeding input has an invalid state -->
      Enter at least 3 letters
    </b-form-invalid-feedback>
    <b-form-text id="inputLiveHelp">
      <!-- this is a form text block (formerly known as help block) -->
      Your full name.
    </b-form-text>
    <b-button :disabled="!nameState" v-if="!registered" variant="success" @click="submit()">Submit</b-button>
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
        name: null,
      }
    },
    methods: {
      async submit() {
        const userName = await this.$contract.account.getUserName(this.$root.account);
        const address = await this.$contract.account.getUserAddress(this.name);
        if (userName) {
          this.$toast.center('이미 등록된 주소입니다');
        } else if (address > 0) {
          this.$toast.center('이미 등록된 사용자명입니다');
        } else {
          this.$loading('loading...');
          try {
            await this.$contract.account.createAccount(this.name);
            window.location.reload()
          } catch (e) {
            alert(e)
          }
          this.$loading.close();
        }
      },
    },
    async created() {
      this.name = await this.$contract.account.getUserName(this.$root.account);
      this.registered = (this.name != null && this.name.length > 0);
    }
  }
</script>

<style scoped>

</style>
