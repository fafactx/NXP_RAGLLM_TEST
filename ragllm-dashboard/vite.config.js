import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    host: '10.193.21.115',  // 使用指定IP
    port: 3333              // 使用指定端口
  }
})
