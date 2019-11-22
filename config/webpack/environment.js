const { environment } = require('@rails/webpacker')

// const MiniCssExtractPlugin = require('mini-css-extract-plugin')

const webpack = require('webpack');
environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery'
}));

module.exports = environment
