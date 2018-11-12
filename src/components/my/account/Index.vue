<template>
  <div>
    <div class="page-title">{{$t('내정보')}}</div>
    <br/>
      <div class="row">
        <div class="col-6 col-md-4">
          <div class="p-1" style="font-size: 20px; font-weight: bold;">{{$t('정보변경')}}</div>
          <br/>
          <div>
            <b-form @submit="setPassword">
              <b-form-group id="userNameGroup"
                            :label="$t('form.account.name.label')"
                            label-for="userNameInput"
                            :description="$t('form.account.name.description', {account: form.account})">
                <b-form-input id="userNameInput"
                              type="text"
                              v-model="form.name"
                              readonly>
                </b-form-input>
              </b-form-group>
              <b-form-group id="passwordGroup"
                            :label="$t('form.account.password.label')"
                            label-for="passwordInput">
                <b-form-input id="passwordInput"
                              type="password"
                              v-model="form.password"
                              required>
                </b-form-input>
              </b-form-group>
              <b-form-group id="passwordValidationGroup"
                            :label="$t('form.account.confirmPassword.label')"
                            label-for="passwordValidation"
                            :description="$t('form.account.confirmPassword.description')">
                <b-form-input id="passwordValidation"
                              type="password"
                              v-model="form.confirmPassword"
                              required>
                </b-form-input>
              </b-form-group>
              <b-button type="submit" variant="outline-secondary">{{$t('정보수정')}}</b-button>
            </b-form>
          </div>
        </div>
        <div class="col-12 col-sm-6 col-md-8">
          <div class="p-1" style="font-size: 20px; font-weight: bold;">{{$t('PXL내역')}}
            <b-link :href="`https://private.piction.network/address/${pictionConfig.account}`" target="_blank">
              <span class="font-size-14 text-secondary">({{$t('PIXELExplorer에서보기')}})</span>
            </b-link>
          </div>
          <br/>
          <div>
            <b-table 
                :items="list" 
                :fields="fields" 
                :current-page="currentPage"
                :per-page="perPage"
                show-empty 
                :empty-text="$t('emptyList')">
                <template slot="message" slot-scope="row">{{$t(row.item.message.replace(/\s/gi, ""))}}</template>
                  <template slot="value" slot-scope="row">
                    <div v-b-popover.hover="toPXL(row.item.value)" >
                      <div v-if="row.item.isPlus" style="font-size: 14px; color: #4a90e2;">
                        <div v-if="toPXL(row.item.value) / parseInt(toPXL(row.item.value)) > 1">+ {{parseFloat(toPXL(row.item.value)).toFixed(2)}} PXL</div>
                        <div v-else>+ {{toPXL(row.item.value)}} PXL</div>
                      </div>
                      <div v-else style="font-size: 14px; color: #d0021b;">
                        - {{toPXL(row.item.value)}} PXL
                      </div>
                    </div>
                  </template>                
            </b-table>
            <b-pagination class="d-flex justify-content-center" size="md"
                  :total-rows="list.length"
                  v-model="currentPage"
                  :per-page="perPage"
                  :limit="limit">
            </b-pagination>
          </div>
        </div>
      </div>
  </div>
</template>

<script>
  import {BigNumber} from 'bignumber.js';
  import Web3Utils from '@utils/Web3Utils'

  export default {
    data() {
      return {
        form: {
          account: '',
          name: '',
          password: '',
          confirmPassword: ''
        },
        fields: [
            {key: 'message', label: this.$t('내역')},
            {key: 'value', label: this.$t('변동금액')}
        ],
        list: [],
        perPage: 10,
        limit: 7,
        currentPage: 1,
      }
    },
    methods: {
      async setPassword (evt) {
        evt.preventDefault();

        if(this.form.password != this.form.confirmPassword) {
          alert(this.$t('notEqualPassword'));
          return;
        }

        let loader = this.$loading.show();
        try {
          await this.$contract.accountManager.setNewPassword(this.form.password, this.form.confirmPassword);
        } catch(e) {
          alert(e);
        }

        this.form.password = '';
        this.form.confirmPassword = '';
        loader.hide();

        alert(this.$t('successChangedPassword'));
      },
      async setAccount() {
        let results = await this.$contract.accountManager.getUserName(this.pictionConfig.account);
        results = Web3Utils.prettyJSON(results);

        this.form.account = this.pictionConfig.account;
        this.form.name = results.userName;
      },
      async setPxlHistory() {
        let results = await this.$contract.pxl.getPxlTransferEvents();
        this.list = results;
        this.list = this.list.reverse();
      },
      toPXL(amount) {
            return this.web3.utils.fromWei(new this.web3.utils.BN(amount));
      }
    },
    async created() {
        await this.setAccount();
        await this.setPxlHistory();
    }
  }
</script>

<style scoped>

</style>
