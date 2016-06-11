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
    loaders: [
      {
        test: /\.js$/,
        loader: 'babel',
        include: __dirname + path.sep + 'src',
      },
    ],
  },
  plugins: [
    new SystemBellPlugin(),
  ],
  devtool: 'source-map',
};
