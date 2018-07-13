<template>
  <div>
    <b-form @submit="onSubmit">
      <b-form-group label="Title:"
                    label-for="title"
                    description="">
        <b-form-input id="title"
                      required
                      type="text"
                      v-model="form.title"
                      placeholder="Enter title">
        </b-form-input>
      </b-form-group>
      <b-form-group label="Thumbnail:"
                    label-for="thumbnail"
                    description="">
        <img class="preview form-control"
             v-if="form.thumbnail"
             :src="form.thumbnail">
        <b-form-file id="thumbnail"
                     required
                     @change="onChangeImage"
                     :state="Boolean(form.thumbnail)"
                     placeholder="Click here upload image"></b-form-file>
      </b-form-group>
      <b-form-group label="Synopsis:"
                    label-for="synopsis"
                    description="">
        <b-form-textarea id="synopsis"
                         required
                         type="text"
                         v-model="form.synopsis"
                         placeholder="Enter synopsis"
                         :rows="2"
                         :max-rows="3">
        </b-form-textarea>
      </b-form-group>
      <b-form-group label="Genres:"
                    label-for="genres"
                    description="">
        <b-form-radio-group id="genres"
                            required
                            v-model="form.genres"
                            :options="options">
        </b-form-radio-group>
      </b-form-group>
      <b-button type="submit" variant="primary">Create</b-button>
    </b-form>
  </div>
</template>

<script>
  export default {
    components: {},
    data() {
      return {
        form: {
          title: null,
          synopsis: null,
          thumbnail: null,
          genres: 'Action',
        },
        options: [
          {text: 'Action', value: 'Action'},
          {text: 'Mellow', value: 'Mellow'},
          {text: 'Drama', value: 'Drama'},
          {text: 'Fantasy', value: 'Fantasy'},
          {text: 'BL', value: 'BL'},
          {text: 'Adult', value: 'Adult'},
        ],
      }
    },
    methods: {
      async onSubmit(evt) {
        evt.preventDefault();
        this.$loading('Uploading...');
        let contrat = await this.$contract.content.deploy([
          this.form.title,
          this.$root.account,
          this.form.synopsis,
          this.form.genres,
          this.form.thumbnail,
          5,
          15
        ]);
        this.$loading.close();
        this.$router.push({ name: 'show-content', params: { content_id: contrat._address }})
      },
      async onChangeImage(event) {
        this.$loading('Uploading...');
        var url = await this.$firebase.storage.upload(event.target.files[0]);
        var dimensions = await this.$utils.getImageDimensions(url);
        console.log(dimensions)
        this.form.thumbnail = url;
        this.$loading.close();
      },
    }
  }
</script>

<style scoped>
  .preview {
    width: 240px;
    margin-bottom: 4px;
  }
</style>
