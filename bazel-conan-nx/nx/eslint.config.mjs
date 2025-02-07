import nx from '@nx/eslint-plugin';

export const override = {
  files: [
    '**/*.ts',
    '**/*.tsx',
    '**/*.cts',
    '**/*.mts',
    '**/*.js',
    '**/*.jsx',
    '**/*.cjs',
    '**/*.mjs',
  ],
  // override or add rules here
  rules: { 'jsx-a11y/alt-text': [0] },
};

export default [
  ...nx.configs['flat/base'],
  ...nx.configs['flat/typescript'],
  ...nx.configs['flat/javascript'],
  {
    ignores: ['**/dist'],
  },
  {
    files: ['**/*.ts', '**/*.tsx', '**/*.js', '**/*.jsx'],
    rules: {
      '@nx/enforce-module-boundaries': [
        'error',
        {
          enforceBuildableLibDependency: true,
          allow: ['^.*/eslint(\\.base)?\\.config\\.[cm]?js$'],
          depConstraints: [
            {
              sourceTag: '*',
              onlyDependOnLibsWithTags: ['*'],
            },
          ],
        },
      ],
    },
  },
  ...override,
];
