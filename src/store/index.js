import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    token: localStorage.getItem('token') || null,
  },
  getters: {
    isLoggedIn: state => state.token != null,
    token: state => state.token,
    publicKey: state => state.token ? web3.eth.accounts.privateKeyToAccount(state.token).address : '0x0000000000000000000000000000000000000000'
  },
  mutations: {
    LOGIN(state, token) {
      state.token = token
    },
    LOGOUT(state) {
      state.token = null
    }
  },
  actions: {
    LOGIN({commit}, token) {
      commit('LOGIN', token)
      localStorage.setItem('token', token)
    },
    LOGOUT({commit}) {
      commit('LOGOUT')
      localStorage.removeItem('token')
    },
  },
})
