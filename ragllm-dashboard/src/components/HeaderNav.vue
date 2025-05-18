<template>
  <a-layout-header class="header" :style="{ background: '#ffffff', color: '#333' }">
    <div class="logo-container">
      <img src="../assets/nxp-logo-image.png" alt="NXP Logo" class="nxp-logo" onerror="this.onerror=null; this.src='../assets/nxp-logo-new.svg';" />
      <span class="app-title" style="color: #333;">{{ $t('app.title') }}</span>
    </div>
    <div class="header-icons">
      <search-outlined class="header-icon" style="color: #333;" />
      <bell-outlined class="header-icon" style="color: #333;" />
      <setting-outlined class="header-icon" style="color: #333;" />
    </div>
  </a-layout-header>
</template>

<script setup>
import { SearchOutlined, BellOutlined, SettingOutlined } from '@ant-design/icons-vue';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
</script>

<style scoped>
/* 覆盖Ant Design的默认样式 */
:deep(.ant-layout-header) {
  background: #ffffff !important;
  color: #333 !important;
}

:deep(.header-icon:hover) {
  color: #000 !important;
}
</style>
