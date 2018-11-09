import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    name: localStorage.getItem('name') || null,
    token: localStorage.getItem('token') || null,
    locale: localStorage.getItem('locale') || 'ko',
  },
  getters: {
    isLoggedIn: state => state.name != null && state.token != null,
    name: state => state.name,
    token: state => state.token,
    publicKey: state => state.token ? web3.eth.accounts.privateKeyToAccount(state.token).address : '0x0000000000000000000000000000000000000000',
    locale: state => state.locale,
  },
  mutations: {
    LOGIN(state, name, token) {
      state.name = name
      state.token = token
    },
    LOGOUT(state) {
      state.token = null
    },
    SET_LOCALE(state, locale) {
      state.locale = locale
    },
  },
  actions: {
    LOGIN({commit}, {name, token}) {
      commit('LOGIN', name, token)
      localStorage.setItem('name', name)
      localStorage.setItem('token', token)
    },
    LOGOUT({commit}) {
      commit('LOGOUT')
      localStorage.removeItem('name')
      localStorage.removeItem('token')
    },
    SET_LOCALE({commit}, locale) {
      commit('SET_LOCALE')
      localStorage.setItem('locale', locale)
    },
  },
})
