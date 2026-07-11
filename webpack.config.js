const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');

module.exports = {
  // 1. Your single entry point file
  entry: './src/main/resources/frontend/main.js',
  
  // 2. Where to output the bundled, minified files
  output: {
    filename: 'js/bundle.min.js',
    path: path.resolve(__dirname, 'src/main/resources/static/dist'),
    clean: true, // Clears the folder before each build
  },
  
  module: {
    rules: [
      {
        // Tells Webpack how to read CSS files
        test: /\.css$/i,
        use: [MiniCssExtractPlugin.loader, 'css-loader'],
      },
    ],
  },
  
  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin(), // Minifies JavaScript
      new CssMinimizerPlugin(), // Minifies CSS
    ],
  },
  
  plugins: [
    // Extracts CSS into its own single file instead of embedding it in JS
    new MiniCssExtractPlugin({
      filename: 'css/bundle.min.css',
    }),
  ],
};
