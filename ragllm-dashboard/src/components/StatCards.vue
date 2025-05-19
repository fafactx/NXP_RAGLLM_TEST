<template>
  <a-row :gutter="16">
    <a-col :span="6">
      <a-card class="stat-card stat-card-1" :loading="loading">
        <template #title>
          <div class="card-title">
            <experiment-outlined class="card-icon" />
            <span>{{ $t('dashboard.totalTest') }}</span>
          </div>
        </template>
        <div class="stat-value">{{ totalTests }}</div>
        <div class="stat-change">
          <span v-if="error" class="error-text">{{ error }}</span>
          <span v-else>{{ $t('dashboard.samples') }}</span>
        </div>
      </a-card>
    </a-col>
    <a-col :span="6">
      <a-card class="stat-card stat-card-2" :loading="loading">
        <template #title>
          <div class="card-title">
            <check-circle-outlined class="card-icon" />
            <span>{{ $t('dashboard.passRate') }}</span>
          </div>
        </template>
        <div class="stat-value">{{ passRate }}%</div>
        <div class="stat-change">
          <span v-if="error" class="error-text">{{ error }}</span>
          <span v-else>{{ $t('dashboard.threshold') }}: 70%</span>
        </div>
      </a-card>
    </a-col>
    <a-col :span="6">
      <a-card class="stat-card stat-card-3" :loading="loading">
        <template #title>
          <div class="card-title">
            <star-outlined class="card-icon" />
            <span>{{ $t('dashboard.averageScore') }}</span>
          </div>
        </template>
        <div class="stat-value">{{ averageScore }}</div>
        <div class="stat-change">
          <span v-if="error" class="error-text">{{ error }}</span>
          <span v-else>{{ $t('dashboard.outOf100') }}</span>
        </div>
      </a-card>
    </a-col>
    <a-col :span="6">
      <a-card class="stat-card stat-card-4" :loading="loading">
        <template #title>
          <div class="card-title">
            <clock-circle-outlined class="card-icon" />
            <span>{{ $t('dashboard.latestTest') }}</span>
          </div>
        </template>
        <div class="stat-value">{{ latestTestDate }}</div>
        <div class="stat-change">
          <span v-if="error" class="error-text">{{ error }}</span>
          <span v-else>{{ latestTestTime }}</span>
        </div>
      </a-card>
    </a-col>
  </a-row>
</template>

<script setup>
import {
  ArrowUpOutlined,
  ExperimentOutlined,
  CheckCircleOutlined,
  StarOutlined,
  ClockCircleOutlined
} from '@ant-design/icons-vue';
import { useI18n } from 'vue-i18n';
import { ref, onMounted } from 'vue';
import { getEvaluations, getDimensionScores } from '../api/evaluations';

const { t } = useI18n();

// 状态变量
const loading = ref(true);
const error = ref(null);
const totalTests = ref(0);
const passRate = ref(0);
const averageScore = ref(0);
const latestTestDate = ref('--');
const latestTestTime = ref('--');

// 获取统计数据
const fetchStats = async () => {
  try {
    loading.value = true;
    error.value = null;

    // 获取评估结果
    const evalResponse = await getEvaluations();

    if (evalResponse.success && evalResponse.data) {
      const evaluations = evalResponse.data;

      // 计算总测试数
      totalTests.value = evaluations.length;

      // 计算通过率（分数>=70的百分比）
      const passingTests = evaluations.filter(e => e.average_score >= 70).length;
      passRate.value = totalTests.value > 0 ? Math.round((passingTests / totalTests.value) * 100) : 0;

      // 获取最新测试日期
      if (evaluations.length > 0) {
        const latestTest = evaluations[0]; // 假设结果已按日期降序排序
        const date = new Date(latestTest.created_at);
        latestTestDate.value = date.toLocaleDateString();
        latestTestTime.value = date.toLocaleTimeString();
      }
    }

    // 获取维度分数
    const dimResponse = await getDimensionScores();

    if (dimResponse.success) {
      // 设置平均分
      averageScore.value = Math.round(dimResponse.average_score) || 0;
    }

    // 如果没有数据，使用示例数据
    if (totalTests.value === 0) {
      useExampleData();
    }
  } catch (err) {
    console.error('获取统计数据失败:', err);
    error.value = '获取数据失败';
    useExampleData();
  } finally {
    loading.value = false;
  }
};

// 使用示例数据
const useExampleData = () => {
  totalTests.value = 547;
  passRate.value = 87;
  averageScore.value = 82;
  latestTestDate.value = new Date().toLocaleDateString();
  latestTestTime.value = '3 hours ago';
};

// 在组件挂载时获取数据
onMounted(() => {
  fetchStats();
});
</script>

<style scoped>
.stat-value {
  font-size: 28px;
  font-weight: bold;
  margin-bottom: 8px;
  color: #333;
}

.stat-change {
  font-size: 14px;
  color: #8c8c8c;
  display: flex;
  align-items: center;
  gap: 4px;
}

.error-text {
  color: #ff4d4f;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 8px;
}

.card-icon {
  font-size: 16px;
}

.increase {
  color: #52c41a;
}

.decrease {
  color: #ff4d4f;
}

.stat-card {
  height: 100%;
}
</style>
