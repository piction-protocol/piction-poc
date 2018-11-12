<template>
  <div>
    <b-form @submit="onSubmit">
      <b-form-group :label="$t('form.fund.maxcap.label')"
                    label-for="maxcap"
                    :description="$t('form.fund.maxcap.description')">
        <div class="d-flex align-items-center">
          <input
            id="maxcap"
            required
            :disabled="disabled"
            type="number"
            :min="form.softcap"
            v-model="form.maxcap"
            style="width: 200px"
            class="form-control"/>
          <div class="ml-2">PXL</div>
        </div>
      </b-form-group>
      <b-form-group :label="`${$t('form.fund.distributionRate.label')}: ${$utils.toPercent(form.distributionRate)}%`"
                    label-for="distributionRate"
                    :description="$t('form.fund.distributionRate.description', {distributionRate : form.distributionRate})">
        <div class="d-flex align-items-center">
          <b-form-input id="distributionRate"
                        required
                        :disabled="disabled"
                        type="range"
                        v-model="form.distributionRate"
                        style="width: 200px"
                        min="0.01" max="0.5" step="0.001">
          </b-form-input>
          <div class="ml-2">%</div>
        </div>
      </b-form-group>

      <b-form-group :label="$t('form.fund.softcap.label')"
                    label-for="softcap"
                    :description="$t('form.fund.softcap.description')">
        <div class="d-flex align-items-center">
          <input
            id="softcap"
            required
            :disabled="disabled"
            type="number"
            :min="10"
            v-model="form.softcap"
            style="width: 200px"
            class="form-control"/>
          <div class="ml-2">PXL</div>
        </div>
      </b-form-group>

      <b-form-group :label="$t('form.fund.minmax.label')"
                    inline
                    label-for="min"
                    :description="$t('form.fund.minmax.description')">
        <div class="d-flex align-items-center">
          <input
            id="min"
            required
            :disabled="disabled"
            type="number"
            :min="1"
            v-model="form.min"
            style="width: 200px"
            class="form-control"/>
          <div class="ml-2">PXL ~ </div>
          <input
            id="max"
            required
            :disabled="disabled"
            type="number"
            :min="form.min"
            v-model="form.max"
            style="width: 200px"
            class="form-control ml-2"/>
          <div class="ml-2">PXL</div>
        </div>
      </b-form-group>

      <b-form-group :label="$t('form.fund.dateRange.label')"
                    label-for="startTime">
        <div class="d-flex align-items-center">
          <datetime
            id="startTime"
            required
            :disabled="disabled"
            type="datetime"
            hidden-name="Enter start time"
            v-model="form.startTime"
            style="width: 250px"
            input-class="form-control"></datetime>
          <div class="ml-2">~</div>
          <datetime
            id="endTime"
            required
            :disabled="disabled"
            type="datetime"
            hidden-name="Enter end time"
            v-model="form.endTime"
            :min-datetime="form.startTime"
            style="width: 250px"
            input-class="form-control ml-2"/>
        </div>
      </b-form-group>

      <b-form-group :label="$t('form.fund.howToReceive.label')"
                    label-for="poolSize"
                    description="">
        <div class="d-flex align-items-center">
          <b-form-select v-model="form.poolSize" :disabled="disabled" style="width: 150px">
            <option v-for="i in [3,4,5,6,7,8,9,10]" :value="i">{{i}}{{$t('회분할')}}</option>
          </b-form-select>
          <b-form-select v-model="form.interval" :disabled="disabled" style="width: 150px" class="ml-2">
            <option v-for="i in [1,2,3,4,5,6,7]" :value="i * (1000 * 60 * 60)">{{i}}{{$t('시간간격')}}</option>
          </b-form-select>
        </div>
      </b-form-group>

      <b-form-group :label="$t('form.fund.firstDistributionTime.label')"
                    label-for="firstDistributionTime"
                    :description="$t('form.fund.firstDistributionTime.description')">
        <datetime
          id="firstDistributionTime"
          required
          :disabled="disabled"
          type="datetime"
          hidden-name="Enter first distribution time"
          v-model="form.firstDistributionTime"
          :min-datetime="minFirstDistributionTime"
          style="width: 250px"
          input-class="form-control"></datetime>
      </b-form-group>

      <b-form-group :label="$t('form.fund.description.label')"
                    label-for="description"
                    description="">
        <b-form-textarea id="description"
                         required
                         :disabled="disabled"
                         type="text"
                         v-model="form.detail"
                         placeholder=""
                         :rows="2"
                         :max-rows="3">
        </b-form-textarea>
      </b-form-group>
      <div v-if="!disabled" align="center">
        <hr>
        <b-button type="submit" variant="primary">{{$t('등록')}}</b-button>
      </div>
    </b-form>
  </div>
</template>

<script>
  import {Datetime} from 'vue-datetime';

  export default {
    props: ['form', 'action', 'submitText'],
    data() {
      return {}
    },
    computed: {
      disabled: function () {
        return this.action == 'edit'
      },
      minFirstDistributionTime: function () {
        if (this.form.endTime != "") {
          let endTime = new Date(this.form.endTime).getTime();
          let a = new Date(endTime + 60000)

          if (new Date(this.form.firstDistributionTime).getTime() < a) {
            this.form.firstDistributionTime = a.toISOString();
          }

          return (a.toISOString());
        } else {
          return (new Date()).toISOString();
        }
      }
    },
    methods: {
      onSubmit(evt) {
        evt.preventDefault();
        this.$emit('onSubmit', this.form);
      }
    }
  }
</script>

<style scoped>
  .form-group {
    margin-bottom: 2rem !important;
  }
</style>
