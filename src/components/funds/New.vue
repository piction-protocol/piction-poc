<template>
  <div>
    <h3>{{content ? content.title : ''}}</h3>
    <b-form @submit="onSubmit">
      <b-form-group label="Start time:"
                    label-for="startTime">
        <datetime
          id="startTime"
          required
          type="datetime"
          hidden-name="Enter start time"
          v-model="record.startTime"
          input-class="form-control"></datetime>
      </b-form-group>

      <b-form-group label="End time:"
                    label-for="endTime">
        <datetime
          id="endTime"
          required
          type="datetime"
          hidden-name="Enter end time"
          v-model="record.endTime"
          input-class="form-control"></datetime>
      </b-form-group>

      <b-form-group :label="`Number of distributions: ${record.poolSize}`"
                    label-for="poolSize"
                    description="">
        <b-form-input id="poolSize"
                      required
                      type="range"
                      v-model="record.poolSize"
                      min="3" max="12" step="1">
        </b-form-input>
      </b-form-group>

      <b-form-group :label="`Distribution interval: ${record.interval} hours`"
                    label-for="interval"
                    description="">
        <b-form-input id="interval"
                      required
                      type="range"
                      v-model="record.interval"
                      min="1" max="720" step="1">
        </b-form-input>
      </b-form-group>

      <b-form-group :label="`Reward distribution rate: ${record.distributionRate * 100}%`"
                    label-for="distributionRate"
                    description="">
        <b-form-input id="distributionRate"
                      required
                      type="range"
                      v-model="record.distributionRate"
                      min="0.01" max="1" step="0.01">
        </b-form-input>
      </b-form-group>

      <b-form-group label="Description:"
                    label-for="description"
                    description="">
        <b-form-textarea id="description"
                         required
                         type="text"
                         v-model="record.description"
                         placeholder="Enter description"
                         :rows="2"
                         :max-rows="3">
        </b-form-textarea>
      </b-form-group>

      <div align="center">
        <b-button type="submit" variant="dark" @click="$router.go(-1)">Back</b-button>
        <b-button type="submit" variant="primary">Submit</b-button>
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
          await this.$contract.fundManager.addFund(
            this.content_id,
            this.$root.account,
            new Date(this.record.startTime).getTime(),
            new Date(this.record.endTime).getTime(),
            this.record.poolSize,
            this.record.interval * hour,
            this.record.distributionRate,
            this.record.description);
          this.$router.push({name: 'my-funds'})
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
