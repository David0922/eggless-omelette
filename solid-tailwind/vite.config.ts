import { defineConfig } from 'vite';
import solidPlugin from 'vite-plugin-solid';

export default defineConfig({
  plugins: [solidPlugin()],
  server: {
    port: 8080,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
      },
    },
  },
  build: {
    target: 'esnext',
  },
});
