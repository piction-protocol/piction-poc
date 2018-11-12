<template>
  <div>
    <div v-once class="page-title">{{action == 'new' ? $t('새만화작품등록') : $t('작품수정')}}</div>
    <br>
    <b-form @submit="onSubmit">
      <b-form-group :label="$t('form.comic.title.label')"
                    label-for="title"
                    description="">
        <b-form-input id="title"
                      :disabled="disabled"
                      required
                      type="text"
                      v-model="form.title"
                      :placeholder="$t('form.comic.title.placeholder')">
        </b-form-input>
      </b-form-group>
      <b-form-group :label="`${$t('form.comic.thumbnail.label')} (250x250)`"
                    label-for="thumbnail"
                    description="">
        <ImageCrop :imageUrl="form.thumbnail" @onCrop="onCrop" :width=250 :height="250"/>
      </b-form-group>
      <b-form-group :label="$t('form.comic.synopsis.label')"
                    label-for="synopsis"
                    description="">
        <b-form-textarea id="synopsis"
                         :disabled="disabled"
                         required
                         type="text"
                         v-model="form.synopsis"
                         :placeholder="$t('form.comic.synopsis.placeholder')"
                         :rows="2"
                         :max-rows="3">
        </b-form-textarea>
      </b-form-group>
      <b-form-group :label="$t('form.comic.genres.label')"
                    label-for="genres"
                    description="">
        <b-form-radio-group id="genres"
                            :disabled="disabled"
                            required
                            v-model="form.genres">
          <b-form-radio v-for="genre in options"
                        :key="genre.value"
                        :value="genre.value">{{$t('genres.' + genre.text)}}</b-form-radio>
        </b-form-radio-group>
      </b-form-group>
      <div align="center">
        <b-button type="submit" variant="primary">{{submitText}}</b-button>
        <b-button type="submit" variant="secondary" @click="$router.back()">{{$t('취소')}}</b-button>
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
          alert(this.$t('emptyThumbnail'))
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
