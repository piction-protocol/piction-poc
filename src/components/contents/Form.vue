<template>
  <div>
    <b-form @submit="onSubmit">
      <b-form-group label="작품명:"
                    label-for="title"
                    description="">
        <b-form-input id="title"
                      :disabled="disabled"
                      required
                      type="text"
                      v-model="record.title"
                      placeholder="작품명을 입력하세요">
        </b-form-input>
      </b-form-group>
      <b-form-group label="썸네일:"
                    label-for="thumbnail"
                    description="">
        <img class="preview form-control"
             v-if="record.thumbnail"
             :src="record.thumbnail">
        <b-form-file id="thumbnail"
                     :disabled="disabled"
                     :required="action == 'new'"
                     @change="onChangeImage"
                     :state="Boolean(record.thumbnail)"
                     placeholder="클릭해서 썸네일을 등록하세요"></b-form-file>
      </b-form-group>
      <b-form-group label="시놉시스:"
                    label-for="synopsis"
                    description="">
        <b-form-textarea id="synopsis"
                         :disabled="disabled"
                         required
                         type="text"
                         v-model="record.synopsis"
                         placeholder="시놉시스를 입력하세요"
                         :rows="2"
                         :max-rows="3">
        </b-form-textarea>
      </b-form-group>
      <b-form-group label="장르:"
                    label-for="genres"
                    description="">
        <b-form-radio-group id="genres"
                            :disabled="disabled"
                            required
                            v-model="record.genres"
                            :options="options">
        </b-form-radio-group>
      </b-form-group>
      <b-form-group :label="`마케터 보상 분비 비율: ${$utils.toPercent(record.marketerRate)}%`"
                    label-for="marketerRate"
                    description="">
        <b-form-input id="marketerRate"
                      :disabled="disabled"
                      required
                      type="range"
                      v-model="record.marketerRate"
                      min="0.00" max="0.1" step="0.001">
        </b-form-input>
      </b-form-group>
      <div align="center">
        <b-button type="submit" variant="primary">{{submitText}}</b-button>
      </div>
    </b-form>
  </div>
</template>

<script>
  import {genres} from './helper'

  export default {
    props: ['record', 'action', 'submitText'],
    data() {
      return {
        options: genres
      }
    },
    computed: {
      disabled: function () {
        return this.action == 'show'
      }
    },
    methods: {
      onSubmit(evt) {
        evt.preventDefault();
        this.$emit('onSubmit', this.record);
      },
      async onChangeImage(event) {
        this.$loading('Uploading...');
        var url = await this.$firebase.storage.upload(event.target.files[0]);
        var dimensions = await this.$utils.getImageDimensions(url);
        console.log(dimensions)
        this.record.thumbnail = url;
        this.$loading.close();
      },
    },
    created() {
    }
  }
</script>

<style scoped>
  .preview {
    width: 360px;
    height: 180px;
    margin-bottom: 4px;
  }
</style>
