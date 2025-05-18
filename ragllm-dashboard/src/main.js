import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import Antd from 'ant-design-vue'
import 'ant-design-vue/dist/reset.css'
import * as Icons from '@ant-design/icons-vue'
import router from './router'
import i18n from './i18n'

const app = createApp(App)

// Register all icon components
for (const [key, component] of Object.entries(Icons)) {
  app.component(key, component)
}

app.use(Antd)
app.use(router)
app.use(i18n)
app.mount('#app')
