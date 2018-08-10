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
        <img class="preview-thumbnail form-control"
             v-if="record.thumbnail"
             :src="record.thumbnail">
        <b-form-file id="thumbnail"
                     :disabled="disabled"
                     :required="action == 'new'"
                     @change="onChangeThumbnail"
                     :state="Boolean(record.thumbnail)"
                     placeholder="Click here upload image"></b-form-file>
      </b-form-group>

      <b-form-group label="Cuts:"
                    label-for="cuts"
                    description="">
        <div v-if="record.cuts.length > 0" class="preview-cuts form-control">
          <div class="preview-cut" v-for="cut in record.cuts">
            <img class="cut" :src="cut">
            <b-button class="remove-cut" variant="danger">Remove</b-button>
          </div>
        </div>
        <b-form-file id="cuts"
                     :disabled="disabled"
                     :required="action == 'new'"
                     @change="addCut"
                     :state="record.cuts.length > 0"
                     placeholder="Click here upload cuts"></b-form-file>
      </b-form-group>

      <b-form-group label="Price:"
                    label-for="price"
                    description="">
        <b-form-input id="price"
                      :disabled="disabled"
                      required
                      type="number"
                      v-model="record.price"
                      placeholder="Set price">
        </b-form-input>
      </b-form-group>
      <div align="center">
        <b-button type="submit" variant="primary">{{submitText}}</b-button>
      </div>
    </b-form>
  </div>
</template>

<script>
  export default {
    props: ['record', 'action', 'submitText'],
    data() {
      return {}
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
      async onChangeThumbnail(event) {
        this.$loading('Uploading...');
        var url = await this.$firebase.storage.upload(event.target.files[0]);
        this.record.thumbnail = url;
        this.$loading.close();
      },
      async addCut(event) {
        this.$loading('Uploading...');
        var url = await this.$firebase.storage.upload(event.target.files[0]);
        this.record.cuts.push(url);
        this.$loading.close();
      },
    },
    created() {
    }
  }
</script>

<style scoped>
  .preview-thumbnail {
    width: 360px;
    height: 180px;
    margin-bottom: 4px;
  }

  .preview-cut {
    position: relative;
    width: 720px;
  }

  .cut {
    width: 720px;
  }

  .remove-cut {
    position: absolute;
    right: 0;
    top: 0;
  }
</style>
