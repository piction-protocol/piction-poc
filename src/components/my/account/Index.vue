<template>
  <div>
    <div class="page-title">{{title}}</div>
    <br/>
      <div class="row">
        <div class="col-6 col-md-4">
          <div class="p-1" style="font-size: 20px; font-weight: bold;">정보 변경</div>
          <br/>
          <div>
            <b-form @submit="setPassword">
              <b-form-group id="userNameGroup"
                            label="닉네임"
                            label-for="userNameInput">
                <b-form-input id="userNameInput"
                              type="text"
                              v-model="form.name"
                              readonly>
                </b-form-input>
              </b-form-group>
              <b-form-group id="passwordGroup"
                            label="비밀번호"
                            label-for="passwordInput">
                <b-form-input id="passwordInput"
                              type="password"
                              v-model="form.password"
                              required>
                </b-form-input>
              </b-form-group>
              <b-form-group id="passwordValidationGroup"
                            label="비밀번호 재입력"
                            label-for="passwordValidation"
                            description="비밀번호 변경 시에만 입력해주세요.">
                <b-form-input id="passwordValidation"
                              type="password"
                              v-model="form.confirmPassword"
                              required>
                </b-form-input>
              </b-form-group>
              <b-button type="submit" variant="outline-secondary">저장</b-button>
            </b-form>
          </div>
        </div>
        <div class="col-12 col-sm-6 col-md-8">
          <div class="p-1" style="font-size: 20px; font-weight: bold;">PXL 내역</div>
          <br/>
          <div>
            <b-table 
                :items="list" 
                :fields="fields" 
                :current-page="currentPage"
                :per-page="perPage"
                show-empty 
                empty-text="조회 내역이 없습니다.">
                <template slot="message" slot-scope="row">{{row.item.message}}</template>
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
        title: '내 정보',
        form: {
          name: '',
          password: '',
          confirmPassword: ''
        },
        fields: [
            {key: 'message', label: '내역'},
            {key: 'value', label: '변동 금액'}
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
          alert("비밀번호가 동일하지 않습니다.");
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
        
        alert("비밀번호가 변경되었습니다.");
      },
      async setUserName() {
        let results = await this.$contract.accountManager.getUserName(this.pictionConfig.account);
        results = Web3Utils.prettyJSON(results);

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
        await this.setUserName();
        await this.setPxlHistory();
    }
  }
</script>

<style scoped>

</style>
