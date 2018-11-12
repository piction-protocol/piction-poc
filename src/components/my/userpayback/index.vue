<template>
  <div>
    <div class="page-title">{{$t('작품구매보상')}}</div>
    <br/>
    <div>
      <div align="center">
        <radial-progress-bar :diameter="250"
                             :stroke-width="strokeWidth"
                             :completed-steps="completedSteps"
                             :total-steps="totalSteps"
                             :start-color="startColor"
                             :stop-color="stopColor"
                             :inner-stroke-color="innerStrokeColor">
          <div class="p-1" style="font-size: 14px;">{{$t('작품구매보상풀')}}</div>
          <div class="p-1" style="font-size: 24px; font-weight: bold;">{{toPXL(reward)}} PXL</div>
          <div v-if="this.reward == 0"></div>
          <div v-else>
            <div v-if="isReleaseTime == $t('출금')">
              <button type="button" class="btn btn-outline-secondary" @click="release">
                {{isReleaseTime}}
              </button>
            </div>
            <div v-else class="p-1" style="font-size: 14px; color: #ff6f27">
              {{isReleaseTime}}
            </div>
          </div>
        </radial-progress-bar>
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
          <template slot="accumulationTime" slot-scope="row">{{$utils.dateFmt(row.item.accumulationTime)}}</template>
          <template slot="purchasedComic" slot-scope="row">{{row.item.contentName}}/#{{row.item.episodeIndex}}
          </template>
          <template slot="value" slot-scope="row">{{toPXL(row.item.value)}} PXL</template>
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
</template>

<script>
  import {BigNumber} from 'bignumber.js';
  import RadialProgressBar from 'vue-radial-progress'
  import Web3Utils from '@utils/Web3Utils'
  import Episode from '@models/Episode'

  export default {
    data() {
      return {
        releaseInterval: 0,
        completedSteps: 0,
        totalSteps: 100,
        startColor: '#ff6f27',
        stopColor: '#ff6f27',
        innerStrokeColor: '#EBEBEB',
        strokeWidth: 20,
        remainingTime: 0,
        releasedTime: 0,
        reward: 0,
        fields: [
          {key: 'accumulationTime', label: this.$t('적립일시')},
          {key: 'purchasedComic', label: this.$t('구매내역')},
          {key: 'value', label: this.$t('보상')}
        ],
        list: [],
        perPage: 10,
        limit: 7,
        currentPage: 1,
      }
    },
    computed: {
      isReleaseTime: function () {
        this.setCompleteStep();
        return this.releaseRemainTimeToStr();
      }
    },
    components: {
      RadialProgressBar
    },
    methods: {
      releaseRemainTimeToStr() {
        const time = Web3Utils.remainTimeToStr(this, this.remainingTime);
        return time ? `${time.number}${time.text} ${this.$t('남음')}` : this.$t('출금')
      },
      setCompleteStep() {
        const counter = (this.remainingTime - this.$root.now) / this.releaseInterval;
        if (counter < 0) {
          this.completedSteps = 100;
        } else {
          this.completedSteps = Math.round((1 - counter) * 100);
        }
      },
      async setTable() {
        let results = await this.$contract.userPaybackPool.getPaybackInfo();
        results = Web3Utils.prettyJSON(results);
        let rewardEvent = await this.$contract.userPaybackPool.getRewardsEvents(this);
        rewardEvent = rewardEvent.filter(f => f.accumulationTime >= results.releasedTime);

        this.list = rewardEvent;
        this.list = this.list.reverse();
      },
      async release() {
        let loader = this.$loading.show();

        await this.$contract.userPaybackPool.release();

        this.$toasted.show(this.$t('withdrawComplete'), {position: "top-center"});
        this.completedSteps = 0;
        await this.setRewards();
        await this.setTable();
        loader.hide();
      },
      async setRewards() {
        let results = await this.$contract.userPaybackPool.getPaybackInfo();
        let interval = await this.$contract.userPaybackPool.getReleaseInterval();
        results = Web3Utils.prettyJSON(results);
        this.reward = results.paybackPxlAmount;
        this.remainingTime = results.nextReleaseTime;
        this.releaseInterval = interval;
      },
      toPXL(amount) {
        return this.web3.utils.fromWei(new this.web3.utils.BN(amount));
      }
    },
    async created() {
      await this.setRewards();
      await this.setTable();
    }
  }
</script>

<style scoped>
</style>
