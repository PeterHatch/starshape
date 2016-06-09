module.exports = {
  extends: 'airbnb',
  plugins: [
    'react',
  ],
  rules: {
    // Rules copied from Standard JS style
    'accessor-pairs': 2,
    'constructor-super': 2, // ? Not sure why AirBNB ES6 style turns this off.
    'dot-location': [2, 'property'],
    'new-parens': 2,
    'no-unexpected-multiline': 2,
    'semi': [2, 'never'],

    // Rules of my own
    'generator-star-spacing': [2, { before: false, after: true }], // AirBNB ES6 style turns this off, but their style guide recommends this style if generators are used.
    'no-underscore-dangle': 0,
    'max-len': 0,
    'no-unused-vars': [2, { vars: 'all', varsIgnorePattern: '^_', args: 'all', argsIgnorePattern: '^_' }], // Would prefer to only ignore vars starting with _ if used in destructuring

    // Temporary rules, to be removed in the future, but suppressing errors that are non-trivial to fix for now
    'no-param-reassign': 0, // TEMP
    'no-shadow': 0, // TEMP
    'no-use-before-define': 0, // TEMP
  },
}
