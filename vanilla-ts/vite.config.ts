import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    host: 'localhost',
    port: 8080,
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:3000',
      },
    },
  },
  build: {
    target: 'esnext',
  },
});
