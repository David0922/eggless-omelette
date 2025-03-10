import tailwindcss from "@tailwindcss/vite";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    host: "localhost",
    port: 8080,
    proxy: {
      "/api": {
        target: "http://127.0.0.1:3000",
      },
    },
    allowedHosts: true,
  },
});
