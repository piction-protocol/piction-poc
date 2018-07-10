<template>
  <div>
    <h1>회원가입</h1>
    <div>{{$root.account}}</div>
    <b-form @submit="onSubmit" @reset="onReset" v-if="show">
      <b-form-group id="exampleInputGroup1"
                    label="Your Name:"
                    label-for="exampleInput1">
        <b-form-input id="exampleInput1"
                      type="text"
                      v-model="form.name"
                      required
                      placeholder="Enter name">
        </b-form-input>
      </b-form-group>
      <b-button type="submit" variant="primary">Submit</b-button>
      <b-button type="reset" variant="danger">Reset</b-button>
    </b-form>
  </div>
</template>

<script>
  export default {
    name: 'Join',
    data() {
      return {
        form: {
          name: '',
        },
        show: true
      }
    },
    methods: {
      async onSubmit(evt) {
        evt.preventDefault();
        const userName = await this.$contract.account.getUserName(this.$root.account);
        const address = await this.$contract.account.getUserAddress(this.form.name);
        if (userName) {
          this.$toast.center('이미 등록된 주소입니다');
          this.onReset(evt)
        } else if (address > 0) {
          this.$toast.center('이미 등록된 사용자명입니다');
          this.onReset(evt)
        } else {
          this.$loading('loading...');
          try {
            let receipt = await this.$contract.account.createAccount(this.form.name);
            console.log(receipt)
            this.$router.push('my')
          } catch (e) {
            alert(e)
          }
          this.$loading.close();
        }
      },
      onReset(evt) {
        evt.preventDefault();
        this.form.name = '';
        this.show = false;
        this.$nextTick(() => {
          this.show = true
        });
      },
    },
  }
</script>

<style scoped>

</style>
