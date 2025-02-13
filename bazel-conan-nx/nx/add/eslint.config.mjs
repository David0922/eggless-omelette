import nx from '@nx/eslint-plugin';
import baseConfig, { override } from '../eslint.config.mjs';

export default [
  ...baseConfig,
  ...nx.configs['flat/react'],
  { ...override },
  {
    files: ['**/*.ts', '**/*.tsx', '**/*.js', '**/*.jsx'],
    // override or add rules here
    rules: {},
  },
];
