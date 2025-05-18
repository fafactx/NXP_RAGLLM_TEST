<script setup>
import { onMounted } from 'vue';
import HeaderNav from './components/HeaderNav.vue';
import SideMenu from './components/SideMenu.vue';
import { useI18n } from 'vue-i18n';

const { locale } = useI18n();

// Set language from localStorage on app mount
onMounted(() => {
  const savedLanguage = localStorage.getItem('language');
  if (savedLanguage) {
    locale.value = savedLanguage;
  }
});
</script>

<template>
  <a-layout class="main-layout">
    <!-- 顶部导航栏 -->
    <HeaderNav />

    <a-layout>
      <!-- 左侧菜单栏 -->
      <SideMenu />

      <!-- 主内容区域 -->
      <a-layout-content class="content-layout">
        <!-- 路由视图 -->
        <router-view />
      </a-layout-content>
    </a-layout>
  </a-layout>
</template>

<style scoped>
.main-layout {
  height: 100vh;
  overflow: hidden;
}

.content-layout {
  overflow: hidden;
}
</style>
