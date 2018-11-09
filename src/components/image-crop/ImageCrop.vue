<template>
  <div>
    <label for="uploads">
      <img class="preview"
           :style="{width:width + 'px', height:height + 'px'}"
           for="uploads"
           :src="image ? image : 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'">
    </label>
    <input ref="fileRef" type="file" id="uploads" style="position:absolute; clip:rect(0 0 0 0);"
           accept="image/png, image/jpeg, image/gif, image/jpg" @change="uploadImg">
    <b-modal v-model="show"
             size="lg"
             :title="$t('modal.imageCrop.title')"
             :ok-title="$t('등록')"
             :cancel-title="$t('취소')"
             @ok="down"
             @hidden="resetFileValue">
      <div class="body">
        <vueCropper
          ref="cropper"
          :img="option.img"
          :outputSize="option.size"
          :outputType="option.outputType"
          :info="true"
          :full="option.full"
          :canMove="option.canMove"
          :canMoveBox="option.canMoveBox"
          :fixedBox="option.fixedBox"
          :original="option.original"
          :autoCrop="option.autoCrop"
          :autoCropWidth="option.autoCropWidth"
          :autoCropHeight="option.autoCropHeight"
          :centerBox="option.centerBox"
          :high="option.high"
          :infoTrue="option.infoTrue"
          :fixed="true"
          @imgLoad="imgLoad"
          @cropMoving="cropMoving"
          :enlarge="option.enlarge"></vueCropper>
      </div>
    </b-modal>
  </div>
</template>

<script>
  export default {
    props: ['imageUrl', 'width', 'height'],
    data() {
      return {
        image: null,
        show: false,
        option: {
          img: "",
          size: 1,
          full: true,
          outputType: "jpeg",
          canMove: true,
          fixedBox: false,
          original: false,
          canMoveBox: true,
          autoCrop: true,
          autoCropWidth: this.width,
          autoCropHeight: this.height,
          centerBox: true,
          high: true,
          cropData: {},
          enlarge: 1
        },
      }
    },
    methods: {
      async down() {
        let loader = this.$loading.show();
        this.$refs.cropper.getCropBlob(async data => {
          this.resetFileValue();
          var url = await this.$firebase.storage.upload(data);
          this.image = url;
          this.$emit('onCrop', url);
          this.show = false;
          loader.hide();
        });
      },
      resetFileValue() {
        this.$refs.fileRef.value = ''
      },
      uploadImg(e) {
        this.show = true;
        var file = e.target.files[0];
        if (!/\.(gif|jpg|jpeg|png|bmp|GIF|JPG|PNG)$/.test(e.target.value)) {
          return false;
        }
        var reader = new FileReader();
        reader.onload = e => {
          let data;
          if (typeof e.target.result === "object") {
            data = window.URL.createObjectURL(new Blob([e.target.result]));
          } else {
            data = e.target.result;
          }
          this.option.img = data;
        };
        reader.readAsArrayBuffer(file);
      },
      imgLoad(msg) {
      },
      cropMoving(data) {
        this.option.cropData = data;
      }
    },
    async created() {
      setTimeout(() => {
        this.image = this.imageUrl;
      }, 100)
    }
  }
</script>

<style>
  .body {
    width: 100%;
    height: 300px;
  }

  .preview {
    background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAQMAAAAlPW0iAAAAA3NCSVQICAjb4U/gAAAABlBMVEXMzMz////TjRV2AAAACXBIWXMAAArrAAAK6wGCiw1aAAAAHHRFWHRTb2Z0d2FyZQBBZG9iZSBGaXJld29ya3MgQ1M26LyyjAAAABFJREFUCJlj+M/AgBVhF/0PAH6/D/HkDxOGAAAAAElFTkSuQmCC")
  }
</style>
