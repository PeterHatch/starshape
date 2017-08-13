'use strict'

const path = require('path')
const webpack = require('webpack')

const SystemBellPlugin = require('system-bell-webpack-plugin')
const BabiliPlugin = require('babili-webpack-plugin')
const production = process.env.NODE_ENV === 'production'

let plugins = [
  new SystemBellPlugin(),
]

if (production) {
  plugins = plugins.concat([
    new BabiliPlugin(),
  ])
}

module.exports = [
  {
    entry: './src/index.js',
    output: {
      path: path.resolve(__dirname, 'build'),
      filename: 'starshape.js',
      publicPath: 'build/',
    },
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          enforce: 'pre',
          loader: 'eslint-loader',
        },
      ],
    },
    plugins: plugins,
    devtool: production ? false : 'source-map',
  },
  {
    entry: './src/loader.js',
    output: {
      path: path.resolve(__dirname, 'build'),
      filename: 'loader.js',
      publicPath: 'build/',
    },
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          enforce: 'pre',
          loader: 'eslint-loader',
        },
      ],
    },
    plugins: plugins,
    devtool: production ? false : 'source-map',
  },
]
