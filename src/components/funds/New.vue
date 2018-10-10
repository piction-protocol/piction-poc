<template>
  <div>
    <b-alert show variant="secondary">작품명: {{content ? content.title : ''}}</b-alert>
    <b-form @submit="onSubmit">
      <b-form-group label="모집 시작 일시:"
                    label-for="startTime">
        <datetime
          id="startTime"
          required
          type="datetime"
          hidden-name="Enter start time"
          v-model="record.startTime"
          input-class="form-control"></datetime>
      </b-form-group>

      <b-form-group label="모집 종료 일시:"
                    label-for="endTime">
        <datetime
          id="endTime"
          required
          type="datetime"
          hidden-name="Enter end time"
          v-model="record.endTime"
          input-class="form-control"/>
      </b-form-group>

      <b-form-group label="softcap:"
                    label-for="softcap">
        <input
          id="softcap"
          required
          type="number"
          hidden-name="Enter softcap"
          v-model="record.softcap"
          min="10"
          class="form-control"/>
      </b-form-group>

      <b-form-group label="maxcap:"
                    label-for="maxcap">
        <input
          id="maxcap"
          required
          type="number"
          :min="record.softcap"
          hidden-name="Enter maxcap"
          v-model="record.maxcap"
          class="form-control"/>
      </b-form-group>

      <b-form-group :label="`회수 횟수: ${record.poolSize}`"
                    label-for="poolSize"
                    description="">
        <b-form-input id="poolSize"
                      required
                      type="range"
                      v-model="record.poolSize"
                      min="3" max="12" step="1">
        </b-form-input>
      </b-form-group>

      <b-form-group :label="`회수 간격: ${record.interval} 시간`"
                    label-for="interval"
                    description="">
        <b-form-input id="interval"
                      required
                      type="range"
                      v-model="record.interval"
                      min="1" max="720" step="1">
        </b-form-input>
      </b-form-group>

      <b-form-group :label="`보상 분배 비율: ${$utils.toPercent(record.distributionRate)}%`"
                    label-for="distributionRate"
                    description="">
        <b-form-input id="distributionRate"
                      required
                      type="range"
                      v-model="record.distributionRate"
                      min="0.01" max="0.5" step="0.001">
        </b-form-input>
      </b-form-group>

      <b-form-group label="서포터들에게 한마디:"
                    label-for="description"
                    description="">
        <b-form-textarea id="description"
                         required
                         type="text"
                         v-model="record.description"
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
  import {record as _record} from './helper';

  export default {
    props: ['content_id'],
    data() {
      return {
        content: null,
        record: _record()
      }
    },
    methods: {
      onSubmit: async function (evt) {
        evt.preventDefault();
        let hour = 60 * 60 * 1000;
        this.$loading('Uploading...');
        try {
          await this.$contract.apiFund.addFund(
            this.content_id,
            new Date(this.record.startTime).getTime(),
            new Date(this.record.endTime).getTime(),
            this.record.maxcap,
            this.record.softcap,
            this.record.poolSize,
            this.record.interval * hour,
            this.record.distributionRate,
            this.record.description);
          this.$router.push({name: 'show-my-content', params: {content_id: this.content_id}});
        } catch (e) {
          alert(e);
        }
        this.$loading.close();
      }
    },
    created() {
      this.$contract.contentInterface.getRecord(this.content_id)
        .then(r => this.content = JSON.parse(r));
    }
  }
</script>

<style scoped>
</style>
