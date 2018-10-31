<template>
  <div>
    <div class="page-title">{{title}}</div>
    <br/>
    <div>
        <div align="center">
            <radial-progress-bar :diameter="250"
                            :stroke-width= "strokeWidth"
                            :completed-steps="completedSteps"
                            :total-steps="totalSteps"
                            :start-color="startColor"
                            :stop-color="stopColor"
                            :inner-stroke-color="innerStrokeColor">
                <div class="p-1" style="font-size: 14px;">작품 구매 보상 풀</div>
                <div class="p-1" style="font-size: 24px; font-weight: bold;">{{toPXL(reward)}} PXL</div>
                <div v-if="this.reward == 0"></div>
                <div v-else>
                    <div v-if="isReleaseTime === '출금'">
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
                empty-text="조회 내역이 없습니다.">
                <template slot="accumulationTime" slot-scope="row">{{$utils.dateFmt(row.item.accumulationTime)}}</template>
                <template slot="purchasedComic" slot-scope="row">{{row.item.contentName}}/#{{row.item.episodeIndex}}</template>
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
        title: '작품 구매 보상',
        remainingTime: 0,
        releasedTime: 0,
        reward: 0,
        fields: [
            {key: 'accumulationTime', label: '적립 일시'},
            {key: 'purchasedComic', label: '구매 내역'},
            {key: 'value', label: '보상'}
        ],
        list: [],
        perPage: 10,
        limit: 7,
        currentPage: 1,
      }
    },
    computed: {
        isReleaseTime: function() {
            this.setCompleteStep();
            return this.releaseRemainTimeToStr();
        }
    },
    components: {
        RadialProgressBar
    }, 
    methods: {
        releaseRemainTimeToStr() {
            const sec = 1000;
            const min = sec * 60;
            const hour = min * 60;
            const day = hour * 24;
            const remain = this.remainingTime - this.$root.now;

            let tempTime = 0;
            if(parseInt(remain / day) > 0) {
                tempTime = parseInt(remain % day);
                return `${parseInt(remain / day)}일 ${parseInt(tempTime / hour)}시간 남음`
            } else if (parseInt(remain / hour) > 0) {
                tempTime = parseInt(remain % hour);
                return `${parseInt(remain / hour)}시간 ${parseInt(tempTime / min)}분 남음`
            } else if (parseInt(remain / min) > 0) {
                tempTime = parseInt(remain % min);
                return `${parseInt(remain / min)}분 ${parseInt(tempTime / sec)}초 남음`
            } else if (remain > sec) {
                tempTime = parseInt(remain % sec);
                return `${parseInt(remain / sec)}초 남음`
            } else {
                return `출금`;
            }
        },
        setCompleteStep() {
            const counter = (this.remainingTime - this.$root.now) / this.releaseInterval;
            if(counter < 0) {
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
            window.location.reload();
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
