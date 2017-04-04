module.exports = {
  root: true,
  parserOptions: {
    ecmaVersion: 6,
    sourceType: 'module'
  },
  extends: 'eslint:recommended',
  env: {
    browser: true, 
    "jquery" : true
  },
  rules: {
    "no-unused-vars": [2, { "args": "all", "varsIgnorePattern": "^_.+", "argsIgnorePattern": "^_.+" }],
  }
};
