'use strict'
const merge = require('webpack-merge')
const prodEnv = require('./prod.env')

module.exports = merge(prodEnv, {
  NODE_ENV: '"development"',
  // COUNCIL_ADDRESS: '"0x9fbda871d559710256a2502a2517b794b482db40"'
  COUNCIL_ADDRESS: '"0x9c1bb217537002a7b98edf43d98986d5a2f48079"'
})
