<template>
  <div>
    <b-form @submit="onSubmit" v-if="show">
      <b-form-group label="Title:"
                    label-for="title"
                    description="">
        <b-form-input id="title"
                      type="text"
                      v-model="form.title"
                      required
                      placeholder="Enter title">
        </b-form-input>
      </b-form-group>
      <b-form-group label="Thumbnail:"
                    label-for="thumbnail"
                    description="">
        <img class="preview form-control"
             v-if="form.thumbnail"
             :src="form.thumbnail">
        <vue-base64-file-upload
          class="v1"
          accept="image/png,image/jpeg"
          image-class="v1-image"
          input-class="form-control"
          :max-size="customImageMaxSize"
          :disable-preview="true"
          @size-exceeded="onSizeExceeded"
          @file="onFile"
          @load="onLoad"/>
      </b-form-group>
      <b-form-group label="Synopsis:"
                    label-for="synopsis"
                    description="">
        <b-form-textarea id="synopsis"
                         type="text"
                         v-model="form.synopsis"
                         required
                         placeholder="Enter synopsis"
                         :rows="2"
                         :max-rows="3">
        </b-form-textarea>
      </b-form-group>
      <b-form-group label="Summary:"
                    label-for="summary"
                    description="">
        <b-form-textarea id="summary"
                         type="text"
                         v-model="form.summary"
                         required
                         placeholder="Enter summary"
                         :rows="2"
                         :max-rows="3">
        </b-form-textarea>
      </b-form-group>
      <b-form-group label="Genres:">
        <b-form-checkbox-group id="genres"
                               v-model="form.genres"
                               :options="options">
        </b-form-checkbox-group>
      </b-form-group>
      <b-button type="submit" variant="primary">Submit</b-button>
    </b-form>
  </div>
</template>

<script>
  import VueBase64FileUpload from 'vue-base64-file-upload';

  export default {
    name: 'PostComics',
    components: {
      VueBase64FileUpload
    },
    data() {
      return {
        form: {
          title: '',
          synopsis: '',
          summary: '',
          thumbnail: '',
          genres: [],
        },
        options: [
          {text: 'Action', value: 'Action'},
          {text: 'Mellow', value: 'mellow'},
          {text: 'Drama', value: 'drama'},
          {text: 'Fantasy', value: 'fantasy'},
          {text: 'BL', value: 'bl'},
          {text: 'Adult', value: 'Adult'},
        ],
        show: true,
        customImageMaxSize: 3 // megabytes
      }
    },
    methods: {
      onSubmit(evt) {
        evt.preventDefault();
        alert(JSON.stringify(this.form));
      },
      onFile(file) {
      },
      async onLoad(dataUri) {
        var dimensions = await this.getImageDimensions(dataUri);
        console.log(dimensions)
        this.form.thumbnail = dataUri;
      },
      onSizeExceeded(size) {
        alert(`Image ${size}Mb size exceeds limits of ${this.customImageMaxSize}Mb!`);
      },
      getImageDimensions(dataUri) {
        return new Promise((resolved, rejected) => {
          let i = new Image()
          i.onload = function () {
            resolved({w: i.width, h: i.height})
          };
          i.src = dataUri
        })
      }
    }
  }
</script>

<style scoped>
  .preview {
    width: 240px;
    margin-bottom: 4px;
  }
</style>
