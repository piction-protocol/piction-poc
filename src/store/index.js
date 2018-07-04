import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    accessToken: null,
  },
  getters: {},
  mutations: {
    LOGIN(state, {accessToken}) {
      state.accessToken = accessToken
    },
    LOGOUT(state) {
      state.accessToken = null
    }
  },
  actions: {
    LOGIN({commit}, {email, password}) {
      // return axios.post(`${resourceHost}/login`, {email, password})
      //   .then(({data}) => commit('LOGIN', data))
      commit('LOGIN', null)
    },
    LOGOUT({commit}) {
      commit('LOGOUT')
    },
  },
})
