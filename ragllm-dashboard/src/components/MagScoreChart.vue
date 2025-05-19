<template>
  <div class="chart-container">
    <h3>MAG Score</h3>
    <div v-if="loading" class="loading-container">
      <a-spin />
    </div>
    <div v-else-if="error" class="error-container">
      <a-alert type="error" :message="error" />
    </div>
    <v-chart v-else class="chart" :option="option" autoresize />
  </div>
</template>

<script setup>
import { use } from 'echarts/core';
import { CanvasRenderer } from 'echarts/renderers';
import { BarChart } from 'echarts/charts';
import { GridComponent, TooltipComponent, TitleComponent, LegendComponent } from 'echarts/components';
import VChart from 'vue-echarts';
import { ref, computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { getMagScores } from '../api/evaluations';

const { t } = useI18n();

// Register necessary components
use([
  CanvasRenderer,
  BarChart,
  GridComponent,
  TooltipComponent,
  TitleComponent,
  LegendComponent
]);

// 状态变量
const loading = ref(true);
const error = ref(null);
const magData = ref([]);

// 获取MAG分数数据
const fetchMagScores = async () => {
  try {
    loading.value = true;
    error.value = null;
    const response = await getMagScores();

    if (response.success && response.data) {
      // 转换API返回的数据格式
      magData.value = response.data.map(item => ({
        mag: item.mag || 'Unknown',
        score: Math.round(item.avg_score) || 0,
        hallucination_control: Math.round(item.avg_hallucination_control) || 0,
        quality: Math.round(item.avg_quality) || 0,
        professionalism: Math.round(item.avg_professionalism) || 0,
        usefulness: Math.round(item.avg_usefulness) || 0,
        count: item.count || 0
      }));
    } else {
      // 如果没有数据，使用示例数据
      magData.value = getSampleData();
    }
  } catch (err) {
    console.error('获取MAG分数失败:', err);
    error.value = '获取数据失败，请稍后再试';
    // 使用示例数据作为后备
    magData.value = getSampleData();
  } finally {
    loading.value = false;
  }
};

// 示例数据函数
const getSampleData = () => {
  return [
    { mag: 'RAN', score: 92, count: 10 },
    { mag: 'RA1', score: 88, count: 8 },
    { mag: 'R16', score: 85, count: 8 },
    { mag: 'RMP', score: 83, count: 7 },
    { mag: 'RPM', score: 80, count: 6 }
  ];
};

// 在组件挂载时获取数据
onMounted(() => {
  fetchMagScores();
});

// 计算排序后的数据
const sortedData = computed(() => {
  return [...magData.value].sort((a, b) => b.score - a.score);
});

// 准备图表数据
const magNames = computed(() => sortedData.value.map(item => item.mag));
const magScores = computed(() => sortedData.value.map(item => item.score));
const normalizedScores = computed(() => sortedData.value.map(item => item.score));
const remainingScores = computed(() => sortedData.value.map(item => 100 - item.score));

// Chart options
const option = computed(() => ({
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'shadow'
    },
    formatter: function(params) {
      const dataIndex = params[0].dataIndex;
      const mag = magNames.value[dataIndex];
      const score = magScores.value[dataIndex];
      const item = sortedData.value[dataIndex];

      let tooltipContent = `<strong>${mag}</strong><br/>Score: ${score}`;

      // 如果有详细维度分数，显示它们
      if (item) {
        if (item.hallucination_control) tooltipContent += `<br/>Hallucination Control: ${item.hallucination_control}`;
        if (item.quality) tooltipContent += `<br/>Quality: ${item.quality}`;
        if (item.professionalism) tooltipContent += `<br/>Professionalism: ${item.professionalism}`;
        if (item.usefulness) tooltipContent += `<br/>Usefulness: ${item.usefulness}`;
        if (item.count) tooltipContent += `<br/>Sample Count: ${item.count}`;
      }

      return tooltipContent;
    }
  },
  legend: {
    data: ['Score', 'Remaining'],
    show: false
  },
  grid: {
    left: 60,
    right: 30,
    bottom: 60,
    top: 30,
    containLabel: true
  },
  xAxis: {
    type: 'category',
    data: magNames.value.slice(0, 10), // 只显示前10个MAG，避免图表过于拥挤
    axisLine: {
      lineStyle: {
        color: '#e0e0e0'
      }
    },
    axisTick: {
      show: false
    },
    axisLabel: {
      interval: 0,
      rotate: 45,
      margin: 10,
      fontSize: 11,
      color: '#333'
    }
  },
  yAxis: {
    type: 'value',
    max: 100,
    axisLabel: {
      formatter: '{value}'
    },
    axisLine: {
      show: false
    },
    axisTick: {
      show: false
    }
  },
  series: [
    {
      name: 'Score',
      type: 'bar',
      stack: 'total',
      label: {
        show: true,
        position: 'inside',
        formatter: function(params) {
          const index = params.dataIndex;
          return magScores.value[index];
        },
        fontSize: 12,
        color: '#fff',
        fontWeight: 'bold'
      },
      itemStyle: {
        color: function(params) {
          // Generate colors based on the index to ensure each MAG has a unique color
          const colors = [
            '#7bb1db', // NXP Blue
            '#f9b500', // NXP Orange
            '#c9d200', // NXP Green
            '#739833', // NXP Dark Green
            '#5a8eb8', // Darker Blue
            '#ffaa00', // Darker Orange
            '#b8c000', // Darker Green
            '#5d7a2a', // Darker Green
            '#a7c9e7', // Lighter Blue
            '#ffc966', // Lighter Orange
            '#dde666', // Lighter Green
            '#9abb66', // Lighter Green
            '#4a7aa3', // Even Darker Blue
            '#e69500', // Even Darker Orange
            '#a6ad00', // Even Darker Green
            '#4c6623'  // Even Darker Green
          ];

          // Use modulo to cycle through colors if we have more MAGs than colors
          return colors[params.dataIndex % colors.length];
        },
        borderRadius: [4, 4, 0, 0]
      },
      data: normalizedScores.value.slice(0, 10)
    },
    {
      name: 'Remaining',
      type: 'bar',
      stack: 'total',
      label: {
        show: false
      },
      itemStyle: {
        color: '#f5f5f5',
        borderRadius: [0, 0, 4, 4]
      },
      data: remainingScores.value.slice(0, 10)
    }
  ]
}));
</script>

<style scoped>
.chart-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  background-color: #fff;
  border-radius: 4px;
  padding: 16px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
}

.chart {
  flex: 1;
  min-height: 0;
  width: 100% !important; /* 强制宽度为100% */
  height: 100% !important; /* 强制高度为100% */
}

.chart-container h3 {
  font-size: 18px;
  font-weight: 500;
  margin-bottom: 16px;
  color: #333;
}

.loading-container, .error-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  flex: 1;
}

.error-container {
  padding: 20px;
}
</style>
