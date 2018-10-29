<template>
  <div>
    <div v-once class="page-title">{{action == 'new' ? `에피소드 등록` : `에피소드 수정`}}</div>
    <br>
    <b-form @submit="onSubmit">
      <b-form-group label="회차명"
                    label-for="title"
                    description="">
        <b-form-input id="title"
                      :disabled="disabled"
                      required
                      type="text"
                      v-model="form.title"
                      placeholder="회차명을 입력하세요">
        </b-form-input>
      </b-form-group>

      <b-form-group label="썸네일"
                    label-for="thumbnail"
                    description="">
        <img class="preview-thumbnail form-control"
             v-if="form.thumbnail"
             :src="form.thumbnail">
        <b-form-file id="thumbnail"
                     :disabled="disabled"
                     :required="action == 'new'"
                     @change="onChangeThumbnail"
                     :state="Boolean(form.thumbnail)"
                     placeholder="클릭해서 썸네일을 등록하세요"></b-form-file>
      </b-form-group>

      <b-form-group label="웹툰 이미지"
                    label-for="cuts"
                    description="">
        <div v-if="form.cuts.length > 0" class="preview-cuts form-control">
          <div class="preview-cut" v-for="(cut, index) in form.cuts">
            <img class="cut" :src="cut">
            <b-button class="remove-cut" variant="danger" @click="removeCut(index)">Remove</b-button>
          </div>
        </div>
        <b-form-file id="cuts"
                     :disabled="disabled"
                     :required="action == 'new'"
                     @change="addCut"
                     :state="form.cuts.length > 0"
                     placeholder="클릭해서 웹툰 이미지를 등록하세요"></b-form-file>
      </b-form-group>

      <b-form-group label="판매가격"
                    label-for="price"
                    description="">
        <b-form-input id="price"
                      :disabled="disabled"
                      required
                      type="number"
                      v-model="form.price"
                      placeholder="판매 가격을 입력하세요">
        </b-form-input>
      </b-form-group>

      <b-form-group label="공개일시"
                    label-for="price"
                    description="">
        <datetime id="startTime"
                  required
                  type="datetime"
                  hidden-name="Enter start time"
                  v-model="form.publishedAt"
                  input-class="form-control"></datetime>
      </b-form-group>

      <b-form-group label="공개"
                    label-for="price"
                    description="">
        <b-form-select :disabled="disabled"
                       required
                       v-model="form.status">
          <option :value="true">공개</option>
          <option :value="false">비공개</option>
        </b-form-select>
      </b-form-group>
      <div align="center">
        <b-button type="submit" variant="primary">{{submitText}}</b-button>
        <b-button type="submit" variant="secondary" @click="$router.back()">취소</b-button>
      </div>
    </b-form>
  </div>
</template>

<script>
  export default {
    props: ['form', 'action', 'submitText'],
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
        if (this.form.cuts.length == 0) {
          alert('웹툰 이미지를 등록하세요')
          return;
        }
        this.$emit('onSubmit', this.form);
      },
      async onChangeThumbnail(event) {
        let loader = this.$loading.show();
        var url = await this.$firebase.storage.upload(event.target.files[0]);
        this.form.thumbnail = url;
        loader.hide();
      },
      async addCut(event) {
        let loader = this.$loading.show();
        var url = await this.$firebase.storage.upload(event.target.files[0]);
        this.form.cuts.push(url);
        loader.hide();
      },
      removeCut(index) {
        this.form.cuts.splice(index, 1);
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
