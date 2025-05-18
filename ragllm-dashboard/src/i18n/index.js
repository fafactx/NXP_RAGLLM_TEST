import { createI18n } from 'vue-i18n';
import en from './locales/en.js';
import zh from './locales/zh.js';

const messages = {
  en,
  zh
};

// Get the preferred language from localStorage or use 'en' as default
const getLocale = () => {
  const cachedLocale = localStorage.getItem('language');
  if (cachedLocale) {
    return cachedLocale;
  }
  return 'en';
};

const i18n = createI18n({
  legacy: false, // Use Composition API
  locale: getLocale(),
  fallbackLocale: 'en',
  messages
});

export default i18n;
