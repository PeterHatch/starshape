'use strict'

const webpack = require('webpack')

const SystemBellPlugin = require('system-bell-webpack-plugin')
const production = process.env.NODE_ENV === 'production'

let plugins = [
  new SystemBellPlugin(),
]

if (production) {
  plugins = plugins.concat([
    new webpack.optimize.UglifyJsPlugin(),
  ])
}

module.exports = {
  entry: './src/index.js',
  output: {
    path: 'compiled',
    filename: 'starshape.js',
    publicPath: 'compiled/',
  },
  module: {
    preLoaders: [
      {
        test: /\.js$/,
        loader: 'eslint',
        exclude: /node_modules/,
      },
    ],
    loaders: [
      {
        test: /\.js$/,
        loader: 'babel',
        exclude: /node_modules/,
      },
    ],
  },
  plugins: plugins,
  debug: !production,
  devtool: production ? false : 'source-map',
}
