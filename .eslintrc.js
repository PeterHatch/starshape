module.exports = {
  env: {
    'browser': true,
  },
  extends: [
    'airbnb',
    'plugin:import/errors',
    'plugin:import/warnings',
  ],
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
    'import/prefer-default-export': 'off', // Override of AirBNB style
    'class-methods-use-this': 'off', // Override of AirBNB style, due to using class methods without this that cannot be static because they are part of a class tree, and need dynamic dispatch
    'no-mixed-operators': ['error', { // Override of AirBNB style to switch back to default, with allowSamePrecedence true
      groups: [
        ['+', '-', '*', '/', '%', '**'],
        ['&', '|', '^', '~', '<<', '>>', '>>>'],
        ['==', '!=', '===', '!==', '>', '>=', '<', '<='],
        ['&&', '||'],
        ['in', 'instanceof']
      ],
      allowSamePrecedence: true
    }],
    // Override of AirBNB style to allow iterators/generators ('ForOfStatement')
    'no-restricted-syntax': [
      'error',
      {
        selector: 'ForInStatement',
        message: 'for..in loops iterate over the entire prototype chain, which is virtually never what you want. Use Object.{keys,values,entries}, and iterate over the resulting array.',
      },
      {
        selector: 'LabeledStatement',
        message: 'Labels are a form of GOTO; using them makes code confusing and hard to maintain and understand.',
      },
      {
        selector: 'WithStatement',
        message: '`with` is disallowed in strict mode because it makes code impossible to predict and optimize.',
      },
    ],
    'generator-star-spacing': [2, { before: false, after: true }], // AirBNB ES6 style turns this off, but their style guide recommends this style if generators are used.
    'no-underscore-dangle': 0,
    'max-len': 0,
    'no-unused-vars': [2, { vars: 'all', varsIgnorePattern: '^_', args: 'all', argsIgnorePattern: '^_' }], // Would prefer to only ignore vars starting with _ if used in destructuring
  },
}
