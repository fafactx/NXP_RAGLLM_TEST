<template>
  <div class="settings-container">
    <h2 class="page-title">{{ $t('menu.settings') }}</h2>
    
    <a-card class="settings-card">
      <a-form :model="formState" :label-col="{ span: 6 }" :wrapper-col="{ span: 14 }">
        <!-- Language Settings -->
        <a-form-item :label="$t('settings.language')">
          <a-radio-group v-model:value="formState.language" @change="handleLanguageChange">
            <a-radio value="en">{{ $t('settings.english') }}</a-radio>
            <a-radio value="zh">{{ $t('settings.chinese') }}</a-radio>
          </a-radio-group>
        </a-form-item>
        
        <!-- Passing Score Settings -->
        <a-form-item :label="$t('settings.passingScore')">
          <a-slider
            v-model:value="formState.passingScore"
            :min="60"
            :max="90"
            :step="1"
            :marks="{
              60: '60',
              70: '70',
              80: '80',
              90: '90'
            }"
          />
        </a-form-item>
        
        <!-- Action Buttons -->
        <a-form-item :wrapper-col="{ offset: 6, span: 14 }">
          <a-button type="primary" @click="saveSettings">{{ $t('settings.save') }}</a-button>
          <a-button style="margin-left: 10px" @click="resetSettings">{{ $t('settings.cancel') }}</a-button>
        </a-form-item>
      </a-form>
    </a-card>
  </div>
</template>

<script setup>
import { reactive, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { message } from 'ant-design-vue';

const { t, locale } = useI18n();

// Form state
const formState = reactive({
  language: 'en',
  passingScore: 70
});

// Load settings from localStorage
onMounted(() => {
  const savedLanguage = localStorage.getItem('language');
  const savedPassingScore = localStorage.getItem('passingScore');
  
  if (savedLanguage) {
    formState.language = savedLanguage;
  }
  
  if (savedPassingScore) {
    formState.passingScore = parseInt(savedPassingScore, 10);
  }
});

// Handle language change
const handleLanguageChange = (e) => {
  locale.value = e.target.value;
};

// Save settings
const saveSettings = () => {
  localStorage.setItem('language', formState.language);
  localStorage.setItem('passingScore', formState.passingScore.toString());
  
  message.success(t('settings.settingsSaved'));
};

// Reset settings to current values
const resetSettings = () => {
  const savedLanguage = localStorage.getItem('language') || 'en';
  const savedPassingScore = parseInt(localStorage.getItem('passingScore') || '70', 10);
  
  formState.language = savedLanguage;
  formState.passingScore = savedPassingScore;
  locale.value = savedLanguage;
};
</script>

<style scoped>
.settings-container {
  padding: 20px;
}

.page-title {
  margin-bottom: 20px;
  font-size: 24px;
  font-weight: 500;
}

.settings-card {
  max-width: 800px;
}
</style>
