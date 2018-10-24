<template>
  <div>
    <b-form @submit="onSubmit">
      <b-form-group label="목표 모집 금액"
                    label-for="maxcap"
                    description="해당 모집 금액이 모금되면 서포터 모집은 자동으로 종료됩니다.">
        <div class="d-flex align-items-center">
          <input
            id="maxcap"
            required
            :disabled="disabled"
            type="number"
            :min="fund.softcap"
            v-model="fund.maxcap"
            style="width: 200px"
            class="form-control"/>
          <div class="ml-2">PXL</div>
        </div>
      </b-form-group>
      <b-form-group :label="`수익 분배율: ${$utils.toPercent(fund.distributionRate)}%`"
                    label-for="distributionRate"
                    :description="`목표 모집 금액 기준 수익 분배율을 지정하세요.<div style='color: red !important;'>1PXL 모금시 -> 매출의 ${fund.distributionRate}PXL 분배</div>`">
        <div class="d-flex align-items-center">
          <b-form-input id="distributionRate"
                        required
                        :disabled="disabled"
                        type="range"
                        v-model="fund.distributionRate"
                        style="width: 200px"
                        min="0.01" max="0.5" step="0.001">
          </b-form-input>
          <div class="ml-2">%</div>
        </div>
      </b-form-group>

      <b-form-group label="최소 모집 금액"
                    label-for="softcap"
                    :description="`<div>해당 금액을 달성하지 못하고 캠페인 기간이 종료되면 캠페인은 자동으로 취소됩니다.</div><div> 모금된 금액은 자동으로 환불됩니다.</div>`">
        <div class="d-flex align-items-center">
          <input
            id="softcap"
            required
            :disabled="disabled"
            type="number"
            :min="10"
            v-model="fund.softcap"
            style="width: 200px"
            class="form-control"/>
          <div class="ml-2">PXL</div>
        </div>
      </b-form-group>

      <b-form-group label="1인당 모금 가능액 설정" inline
                    label-for="min"
                    description="서포터 1인당 모금할 수 있는 최소 ~ 최대 금액">
        <div class="d-flex align-items-center">
          <input
            id="min"
            required
            :disabled="disabled"
            type="number"
            :min="1"
            v-model="fund.min"
            style="width: 200px"
            class="form-control"/>
          <div class="ml-2">PXL ~ </div>
          <input
            id="max"
            required
            :disabled="disabled"
            type="number"
            :min="fund.min"
            v-model="fund.max"
            style="width: 200px"
            class="form-control ml-2"/>
          <div class="ml-2">PXL</div>
        </div>
      </b-form-group>

      <b-form-group label="모집 기간"
                    label-for="startTime">
        <div class="d-flex align-items-center">
          <datetime
            id="startTime"
            required
            :disabled="disabled"
            type="datetime"
            hidden-name="Enter start time"
            v-model="fund.startTime"
            :min-datetime="new Date().toISOString()"
            style="width: 250px"
            input-class="form-control"></datetime>
          <div class="ml-2">~</div>
          <datetime
            id="endTime"
            required
            :disabled="disabled"
            type="datetime"
            hidden-name="Enter end time"
            v-model="fund.endTime"
            :min-datetime="fund.startTime"
            style="width: 250px"
            input-class="form-control ml-2"/>
        </div>
      </b-form-group>

      <b-form-group label="모금액 수령 방법"
                    label-for="poolSize"
                    description="">
        <div class="d-flex align-items-center">
          <b-form-select v-model="fund.poolSize" :disabled="disabled" style="width: 150px">
            <option v-for="i in [3,4,5,6,7,8,9,10]" :value="i">{{i}}회 분할</option>
          </b-form-select>
          <b-form-select v-model="fund.interval" :disabled="disabled" style="width: 150px" class="ml-2">
            <option v-for="i in [1,2,3,4,5,6,7]" :value="i * (1000 * 60 * 60)">{{i}}시간 간격</option>
          </b-form-select>
        </div>
      </b-form-group>

      <b-form-group label="최초 모금액 수령일"
                    label-for="firstDistributionTime"
                    description="모집 종료 시점 이후로 지정하셔야 합니다.">
        <datetime
          id="firstDistributionTime"
          required
          :disabled="disabled"
          type="datetime"
          hidden-name="Enter first distribution time"
          v-model="fund.firstDistributionTime"
          :min-datetime="fund.endTime"
          style="width: 250px"
          input-class="form-control"></datetime>
      </b-form-group>

      <b-form-group label="모집 메시지"
                    label-for="description"
                    description="">
        <b-form-textarea id="description"
                         required
                         :disabled="disabled"
                         type="text"
                         v-model="fund.detail"
                         placeholder=""
                         :rows="2"
                         :max-rows="3">
        </b-form-textarea>
      </b-form-group>
      <div v-if="!disabled" align="center">
        <hr>
        <b-button type="submit" variant="primary">저장</b-button>
      </div>
    </b-form>
  </div>
</template>

<script>
  import {Datetime} from 'vue-datetime';

  export default {
    props: ['fund', 'action', 'submitText'],
    data() {
      return {}
    },
    computed: {
      disabled: function () {
        return this.action == 'edit'
      }
    },
    methods: {
      onSubmit(evt) {
        evt.preventDefault();
        this.$emit('onSubmit', this.fund);
      }
    }
  }
</script>

<style scoped>
  .form-group {
    margin-bottom: 2rem !important;
  }
</style>
