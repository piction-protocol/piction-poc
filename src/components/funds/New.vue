<template>
  <div>
    <b-alert show variant="secondary">작품명: {{fund.comic.title}}</b-alert>
    <b-form @submit="onSubmit">
      <b-form-group label="모집 시작 일시:"
                    label-for="startTime">
        <datetime
          id="startTime"
          required
          type="datetime"
          hidden-name="Enter start time"
          v-model="fund.startTime"
          input-class="form-control"></datetime>
      </b-form-group>

      <b-form-group label="모집 종료 일시:"
                    label-for="endTime">
        <datetime
          id="endTime"
          required
          type="datetime"
          hidden-name="Enter end time"
          v-model="fund.endTime"
          input-class="form-control"/>
      </b-form-group>

      <b-form-group label="softcap:"
                    label-for="softcap">
        <input
          id="softcap"
          required
          type="number"
          hidden-name="Enter softcap"
          v-model="fund.softcap"
          min="10"
          class="form-control"/>
      </b-form-group>

      <b-form-group label="maxcap:"
                    label-for="maxcap">
        <input
          id="maxcap"
          required
          type="number"
          :min="fund.softcap"
          hidden-name="Enter maxcap"
          v-model="fund.maxcap"
          class="form-control"/>
      </b-form-group>

      <b-form-group label="min:"
                    label-for="min">
        <input
          id="min"
          required
          type="number"
          :min="1"
          hidden-name="Enter min"
          v-model="fund.min"
          class="form-control"/>
      </b-form-group>

      <b-form-group label="max:"
                    label-for="max">
        <input
          id="max"
          required
          type="number"
          :min="fund.min"
          hidden-name="Enter max"
          v-model="fund.max"
          class="form-control"/>
      </b-form-group>

      <b-form-group :label="`회수 횟수: ${fund.poolSize}`"
                    label-for="poolSize"
                    description="">
        <b-form-input id="poolSize"
                      required
                      type="range"
                      v-model="fund.poolSize"
                      min="3" max="12" step="1">
        </b-form-input>
      </b-form-group>

      <b-form-group :label="`회수 간격: ${fund.interval} 시간`"
                    label-for="interval"
                    description="">
        <b-form-input id="interval"
                      required
                      type="range"
                      v-model="fund.interval"
                      min="1" max="720" step="1">
        </b-form-input>
      </b-form-group>

      <b-form-group label="첫 분배:"
                    label-for="firstDistributionTime">
        <datetime
          id="firstDistributionTime"
          required
          type="datetime"
          hidden-name="Enter first distribution time"
          v-model="fund.firstDistributionTime"
          input-class="form-control"></datetime>
      </b-form-group>

      <b-form-group :label="`보상 분배 비율: ${$utils.toPercent(fund.distributionRate)}%`"
                    label-for="distributionRate"
                    description="">
        <b-form-input id="distributionRate"
                      required
                      type="range"
                      v-model="fund.distributionRate"
                      min="0.01" max="0.5" step="0.001">
        </b-form-input>
      </b-form-group>

      <b-form-group label="서포터들에게 한마디:"
                    label-for="description"
                    description="">
        <b-form-textarea id="description"
                         required
                         type="text"
                         v-model="fund.detail"
                         placeholder=""
                         :rows="2"
                         :max-rows="3">
        </b-form-textarea>
      </b-form-group>
      <hr>
      <div align="center">
        <b-button type="submit" variant="dark" @click="$router.go(-1)">이전</b-button>
        <b-button type="submit" variant="primary">투자등록</b-button>
      </div>
    </b-form>
  </div>
</template>

<script>
  import moment from 'moment';
  import {Datetime} from 'vue-datetime';
  import Fund from '@models/Fund';

  export default {
    props: ['comic_id'],
    data() {
      return {
        fund: new Fund()
      }
    },
    methods: {
      onSubmit: async function (evt) {
        evt.preventDefault();
        let hour = 60 * 60 * 1000;
        let loader = this.$loading.show();
        try {
          await this.$contract.apiFund.createFund(this.comic_id, this.fund);
//          await this.$contract.apiFund.createFund(
//            this.content_id,
//            new Date(this.fund.startTime).getTime(),
//            new Date(this.fund.endTime).getTime(),
//            this.fund.maxcap,
//            this.fund.softcap,
//            this.fund.poolSize,
//            this.fund.interval * hour,
//            this.fund.distributionRate,
//            this.fund.description);
          this.$router.push({name: 'show-my-content', params: {content_id: this.content_id}});
        } catch (e) {
          alert(e);
        }
        loader.hide();
      }
    },
    async created() {
    }
  }
</script>

<style scoped>
</style>
