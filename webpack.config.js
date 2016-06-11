const path = require('path');
const SystemBellPlugin = require('system-bell-webpack-plugin');

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
      }
    ],
    loaders: [
      {
        test: /\.js$/,
        loader: 'babel',
        exclude: /node_modules/,
      },
    ],
  },
  plugins: [
    new SystemBellPlugin(),
  ],
  devtool: 'source-map',
};
