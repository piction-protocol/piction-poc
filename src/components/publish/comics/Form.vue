<template>
  <div>
    <div v-once class="page-title">{{action == 'new' ? `새 만화 작품 등록` : `작품 수정`}}</div>
    <br>
    <b-form @submit="onSubmit">
      <b-form-group label="제목"
                    label-for="title"
                    description="">
        <b-form-input id="title"
                      :disabled="disabled"
                      required
                      type="text"
                      v-model="comic.title"
                      placeholder="작품명을 입력하세요">
        </b-form-input>
      </b-form-group>
      <b-form-group label="작품 썸네일"
                    label-for="thumbnail"
                    description="">
        <img class="preview form-control"
             v-if="comic.thumbnail"
             :src="comic.thumbnail">
        <b-form-file id="thumbnail"
                     :disabled="disabled"
                     :required="action == 'new'"
                     @change="onChangeImage"
                     :state="Boolean(comic.thumbnail)"
                     placeholder="클릭해서 썸네일을 등록하세요"></b-form-file>
      </b-form-group>
      <b-form-group label="시놉시스"
                    label-for="synopsis"
                    description="">
        <b-form-textarea id="synopsis"
                         :disabled="disabled"
                         required
                         type="text"
                         v-model="comic.synopsis"
                         placeholder="시놉시스를 입력하세요"
                         :rows="2"
                         :max-rows="3">
        </b-form-textarea>
      </b-form-group>
      <b-form-group label="장르"
                    label-for="genres"
                    description="">
        <b-form-radio-group id="genres"
                            :disabled="disabled"
                            required
                            v-model="comic.genres"
                            :options="options">
        </b-form-radio-group>
      </b-form-group>
      <div align="center">
        <b-button type="submit" variant="primary">{{submitText}}</b-button>
        <b-button type="submit" variant="secondary" @click="$router.back()">취소</b-button>
      </div>
    </b-form>
  </div>
</template>

<script>
  import Comic from '@models/Comic'

  export default {
    props: ['comic', 'action', 'submitText'],
    data() {
      return {
        options: Comic.genres
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
        this.$emit('onSubmit', this.comic);
      },
      async onChangeImage(event) {
        let loader = this.$loading.show();
        var url = await this.$firebase.storage.upload(event.target.files[0]);
        var dimensions = await this.$utils.getImageDimensions(url);
        console.log(dimensions)
        this.comic.thumbnail = url;
        loader.hide();
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
