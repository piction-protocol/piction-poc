<template>
  <div>
    <div v-once class="page-title">{{action == 'new' ? $t('에피소드등록') : $t('에피소드수정')}}</div>
    <br>
    <b-form @submit="onSubmit">
      <b-form-group :label="$t('form.episode.title.label')"
                    label-for="title"
                    description="">
        <b-form-input id="title"
                      :disabled="disabled"
                      required
                      type="text"
                      v-model="form.title"
                      :placeholder="$t('form.episode.title.placeholder')">
        </b-form-input>
      </b-form-group>

      <b-form-group :label="`${$t('form.episode.thumbnail.label')} (200x200)`"
                    label-for="thumbnail"
                    description="">
        <ImageCrop :imageUrl="form.thumbnail" @onCrop="onCrop" :width=200 :height="200"/>
      </b-form-group>

      <b-form-group :label="$t('form.episode.cuts.label')"
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
                     @change="addCut"
                     :state="form.cuts.length > 0"
                     :placeholder="$t('form.episode.cuts.placeholder')"></b-form-file>
      </b-form-group>

      <b-form-group :label="$t('form.episode.price.label')"
                    label-for="price"
                    description="">
        <b-form-input id="price"
                      :disabled="disabled"
                      required
                      type="number"
                      v-model="form.price"
                      :placeholder="$t('form.episode.price.placeholder')">
        </b-form-input>
      </b-form-group>

      <b-form-group :label="$t('form.episode.publishedAt.label')"
                    label-for="publishedAt"
                    description="">
        <datetime id="publishedAt"
                  required
                  type="datetime"
                  hidden-name="Enter start time"
                  v-model="form.publishedAt"
                  input-class="form-control"></datetime>
      </b-form-group>

      <b-form-group :label="$t('form.episode.status.label')"
                    label-for="status"
                    description="">
        <b-form-select id="status"
                       :disabled="disabled"
                       required
                       v-model="form.status">
          <option :value="true">{{$t('공개')}}</option>
          <option :value="false">{{$t('비공개')}}</option>
        </b-form-select>
      </b-form-group>
      <div align="center">
        <b-button type="submit" variant="primary">{{submitText}}</b-button>
        <b-button type="submit" variant="secondary" @click="$router.back()">{{$t('취소')}}</b-button>
      </div>
    </b-form>
  </div>
</template>

<script>
  import ImageCrop from '@/components/image-crop/ImageCrop'

  export default {
    components: {ImageCrop},
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
        if (!this.form.thumbnail) {
          alert(this.$t('emptyThumbnail'))
          return;
        }
        if (this.form.cuts.length == 0) {
          alert(this.$t('emptyCut'))
          return;
        }
        this.$emit('onSubmit', this.form);
      },
      onCrop(url) {
        this.form.thumbnail = url;
      },
      async addCut(event) {
        let loader = this.$loading.show();
        try{
          var url = await this.$firebase.storage.upload(event.target.files[0]);
          this.form.cuts.push(url);
        }catch(e){
        }
        
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
