<template>
  <div>
    <b-form @submit="onSubmit">
      <b-form-group label="Title:"
                    label-for="title"
                    description="">
        <b-form-input id="title"
                      :disabled="disabled"
                      required
                      type="text"
                      v-model="record.title"
                      placeholder="Enter title">
        </b-form-input>
      </b-form-group>
      <b-form-group label="Thumbnail:"
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
                     placeholder="Click here upload image"></b-form-file>
      </b-form-group>
      <b-form-group label="Synopsis:"
                    label-for="synopsis"
                    description="">
        <b-form-textarea id="synopsis"
                         :disabled="disabled"
                         required
                         type="text"
                         v-model="record.synopsis"
                         placeholder="Enter synopsis"
                         :rows="2"
                         :max-rows="3">
        </b-form-textarea>
      </b-form-group>
      <b-form-group label="Genres:"
                    label-for="genres"
                    description="">
        <b-form-radio-group id="genres"
                            :disabled="disabled"
                            required
                            v-model="record.genres"
                            :options="options">
        </b-form-radio-group>
      </b-form-group>
      <b-form-group label="Marketer distribution rate:"
                    label-for="marketerRate"
                    description="">
        <b-form-input id="marketerRate"
                      :disabled="disabled"
                      required
                      type="number"
                      v-model="record.marketerRate"
                      placeholder="Set marketer distribution rate">
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
