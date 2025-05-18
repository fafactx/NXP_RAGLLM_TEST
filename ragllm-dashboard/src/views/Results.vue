<template>
  <div class="results-container">
    <h2 class="page-title">{{ $t('menu.results') }}</h2>
    <a-empty :description="$t('menu.results') + ' ' + $t('comingSoon')" />
  </div>
</template>

<script setup>
import { useI18n } from 'vue-i18n';

const { t } = useI18n();
</script>

<style scoped>
.results-container {
  padding: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}

.page-title {
  margin-bottom: 20px;
  font-size: 24px;
  font-weight: 500;
}
</style>
