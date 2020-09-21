module.exports = {
  context: __dirname,

  entry: "./src/index.jsx",

  output: {
    filename: "bundle.js",
    path: __dirname,
  },
  // Existing Code ....
  module : {
    rules: [
      {
        test : /\.jsx?/,
        exclude: /(node_modules|bower_components)/,
        use: [
          {
            loader: "babel-loader",
            options: {
              presets: ['@babel/preset-env']
            }
          }
        ]
      },
      {
        test: /\.css$/i,
        use: ['css-loader'],
      },
    ]
  }
};
