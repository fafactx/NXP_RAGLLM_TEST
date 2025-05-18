<template>
  <a-layout-sider width="160" style="background: #fff">
    <a-menu
      mode="inline"
      :selected-keys="[currentRoute]"
      class="nav-menu"
    >
      <a-menu-item key="dashboard" @click="navigateTo('dashboard')">
        <dashboard-outlined />
        <span>{{ $t('menu.dashboard') }}</span>
      </a-menu-item>
      <a-menu-item key="testcases" @click="navigateTo('testcases')">
        <file-text-outlined />
        <span>{{ $t('menu.testCases') }}</span>
      </a-menu-item>
      <a-menu-item key="results" @click="navigateTo('results')">
        <bar-chart-outlined />
        <span>{{ $t('menu.results') }}</span>
      </a-menu-item>
      <a-menu-item key="settings" @click="navigateTo('settings')">
        <setting-outlined />
        <span>{{ $t('menu.settings') }}</span>
      </a-menu-item>
    </a-menu>
  </a-layout-sider>
</template>

<script setup>
import { DashboardOutlined, FileTextOutlined, BarChartOutlined, SettingOutlined } from '@ant-design/icons-vue';
import { useI18n } from 'vue-i18n';
import { ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const currentRoute = ref('dashboard');

// Update currentRoute when the route changes
watch(() => route.name, (newRoute) => {
  if (newRoute) {
    currentRoute.value = newRoute.toString();
  }
}, { immediate: true });

// Navigate to the selected route
const navigateTo = (routeName) => {
  router.push({ name: routeName });
};
</script>

<style scoped>
/* 侧边栏菜单项自定义颜色 */
:deep(.ant-menu-item:nth-child(1) .anticon) {
  color: #1a3a8f; /* 深蓝色 - 仪表盘 */
}

:deep(.ant-menu-item:nth-child(2) .anticon) {
  color: #00a2ae; /* 青绿色 - 测试用例 */
}

:deep(.ant-menu-item:nth-child(3) .anticon) {
  color: #722ed1; /* 紫色 - 结果 */
}

:deep(.ant-menu-item:nth-child(4) .anticon) {
  color: #595959; /* 灰色 - 设置 */
}

/* 选中状态下的颜色 */
:deep(.ant-menu-item-selected:nth-child(1)) {
  color: #1a3a8f !important;
}

:deep(.ant-menu-item-selected:nth-child(2)) {
  color: #00a2ae !important;
}

:deep(.ant-menu-item-selected:nth-child(3)) {
  color: #722ed1 !important;
}

:deep(.ant-menu-item-selected:nth-child(4)) {
  color: #595959 !important;
}

/* 选中状态下的左侧边框颜色 */
:deep(.ant-menu-item-selected:nth-child(1))::before {
  background-color: #1a3a8f !important;
}

:deep(.ant-menu-item-selected:nth-child(2))::before {
  background-color: #00a2ae !important;
}

:deep(.ant-menu-item-selected:nth-child(3))::before {
  background-color: #722ed1 !important;
}

:deep(.ant-menu-item-selected:nth-child(4))::before {
  background-color: #595959 !important;
}
</style>
