<template>
  <div class="dashboard-container">
    <!-- 核心指标卡片 -->
    <div class="stats-section">
      <StatCards />
    </div>

    <!-- 图表区域 -->
    <div class="charts-section">
      <a-row :gutter="16">
        <a-col :span="12">
          <MagScoreChart />
        </a-col>
        <a-col :span="12">
          <DimensionScores />
        </a-col>
      </a-row>
    </div>
  </div>
</template>

<script setup>
import StatCards from '../components/StatCards.vue';
import MagScoreChart from '../components/MagScoreChart.vue';
import DimensionScores from '../components/DimensionScores.vue';
</script>

<style scoped>
.dashboard-container {
  height: calc(100vh - 64px);
  display: flex;
  flex-direction: column;
  padding: 16px;
  overflow: hidden;
  position: fixed;
  top: 64px;
  left: 160px;
  right: 0;
  bottom: 0;
}

.stats-section {
  margin-bottom: 24px;
}

.charts-section {
  flex: 1;
  min-height: 0;
  display: flex;
  margin: 0 -8px; /* 减小gutter的间距 */
  width: 100%;
}

.charts-section .ant-row {
  flex: 1;
  width: 100%;
  display: flex;
}

.charts-section .ant-col {
  height: 100%;
  display: flex;
  padding: 0 8px; /* 减小列之间的间距 */
  flex: 1;
}
</style>
