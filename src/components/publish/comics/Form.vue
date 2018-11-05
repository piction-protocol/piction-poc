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
                      v-model="form.title"
                      placeholder="작품명을 입력하세요">
        </b-form-input>
      </b-form-group>
      <b-form-group label="작품 썸네일 (250x250)"
                    label-for="thumbnail"
                    description="">
        <ImageCrop :imageUrl="form.thumbnail" @onCrop="onCrop" :width=250 :height="250"/>
      </b-form-group>
      <b-form-group label="시놉시스"
                    label-for="synopsis"
                    description="">
        <b-form-textarea id="synopsis"
                         :disabled="disabled"
                         required
                         type="text"
                         v-model="form.synopsis"
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
                            v-model="form.genres"
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
  import ImageCrop from '@/components/image-crop/ImageCrop'

  export default {
    components: {ImageCrop},
    props: ['form', 'action', 'submitText'],
    data() {
      return {
        options: Comic.genres,
        event: null,
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
        if (!this.form.thumbnail) {
          alert('작품 썸네일이 등록되지 않았습니다')
          return;
        }
        this.$emit('onSubmit', this.form);
      },
      onCrop(url) {
        this.form.thumbnail = url;
      },
    },
    created() {
    }
  }
</script>

<style scoped>

</style>
