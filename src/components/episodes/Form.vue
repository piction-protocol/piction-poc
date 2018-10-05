<template>
  <div>
    <b-form @submit="onSubmit">
      <b-form-group label="회차명:"
                    label-for="title"
                    description="">
        <b-form-input id="title"
                      :disabled="disabled"
                      required
                      type="text"
                      v-model="record.title"
                      placeholder="회차명을 입력하세요">
        </b-form-input>
      </b-form-group>

      <b-form-group label="썸네일:"
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
                     placeholder="클릭해서 썸네일을 등록하세요"></b-form-file>
      </b-form-group>

      <b-form-group label="웹툰 이미지:"
                    label-for="cuts"
                    description="">
        <div v-if="record.cuts.length > 0" class="preview-cuts form-control">
          <div class="preview-cut" v-for="(cut, index) in record.cuts">
            <img class="cut" :src="cut">
            <b-button class="remove-cut" variant="danger" @click="removeCut(index)">Remove</b-button>
          </div>
        </div>
        <b-form-file id="cuts"
                     :disabled="disabled"
                     :required="action == 'new'"
                     @change="addCut"
                     :state="record.cuts.length > 0"
                     placeholder="클릭해서 웹툰 이미지를 등록하세요"></b-form-file>
      </b-form-group>

      <b-form-group label="판매가격:"
                    label-for="price"
                    description="">
        <b-form-input id="price"
                      :disabled="disabled"
                      required
                      type="number"
                      v-model="record.price"
                      placeholder="판매 가격을 입력하세요">
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
        if (this.record.cuts.length == 0) {
          alert('웹툰 이미지를 등록하세요')
          return;
        }
        this.$emit('onSubmit', this.record);
      },
      async onChangeThumbnail(event) {
        this.$loading('Uploading...');
        var url = await this.$firebase.storage.upload(event.target.files[0]);
        this.record.thumbnail = url;
        this.$loading.close();
      },
      removeCut(index) {
        this.record.cuts.splice(0, 1);
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
