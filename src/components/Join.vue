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
  import source from '../../build/contracts/Account.json'

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
        const account = await web3.eth.getAccounts();
        const contract = new web3.eth.Contract(source.abi, source.networks['3'].address);
        const userName = await contract.methods.getUserName(account[0]).call();
        const address = await contract.methods.getUserAddress(this.form.name).call();
        if (userName) {
          alert('이미 등록된 주소입니다.');
          this.onReset(evt)
        } else if (address > 0) {
          alert('이미 등록된 사용자명입니다.');
          this.onReset(evt)
        } else {
          const receipt = await contract.methods.createAccount(this.form.name).send({from: account[0]});
          console.log(receipt)
          this.$router.push('auth')
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
