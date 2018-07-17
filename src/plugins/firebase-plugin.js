import firebase from 'firebase/app';
import 'firebase/storage';

const uuidv1 = require('uuid/v1');

class Storage {
  constructor(firebase, config) {
    this._firebase = firebase;
    this._firebase.initializeApp(config);
  }

  async upload(file) {
    let storageRef = this._firebase.app().storage("gs://piction").ref();
    let metadata = {contentType: 'image/jpeg'};
    let snapshot = await storageRef.child(uuidv1()).put(file, metadata).then();
    let url = await snapshot.ref.getDownloadURL().then();

    return url;
  }
}

const FirebasePlugin = {
  install(Vue, options) {
    Vue.prototype.$firebase = {}
    Vue.prototype.$firebase.storage = new Storage(firebase, options);
  }
}

export default FirebasePlugin;
