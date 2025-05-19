<template>
  <div class="chart-container">
    <h3>Dimension Scores</h3>
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
import { getDimensionScores } from '../api/evaluations';

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
const dimensions = ref([
  { name: 'Hallucination Control', score: 90 },
  { name: 'Quality', score: 85 },
  { name: 'Professionalism', score: 80 },
  { name: 'Usefulness', score: 75 }
]);
const averageScore = ref(0);
const sampleCount = ref(0);

// 获取维度分数数据
const fetchDimensionScores = async () => {
  try {
    loading.value = true;
    error.value = null;
    const response = await getDimensionScores();

    if (response.success && response.data && response.data.length > 0) {
      // 转换API返回的数据格式
      dimensions.value = response.data.map(item => ({
        name: item.name,
        score: Math.round(item.score) || 0
      }));

      // 设置平均分和样本数
      averageScore.value = Math.round(response.average_score) || 0;
      sampleCount.value = response.count || 0;
    } else {
      // 如果没有数据，使用示例数据
      dimensions.value = getSampleData();
    }
  } catch (err) {
    console.error('获取维度分数失败:', err);
    error.value = '获取数据失败，请稍后再试';
    // 使用示例数据作为后备
    dimensions.value = getSampleData();
  } finally {
    loading.value = false;
  }
};

// 示例数据函数
const getSampleData = () => {
  return [
    { name: 'Hallucination Control', score: 90 },
    { name: 'Quality', score: 85 },
    { name: 'Professionalism', score: 80 },
    { name: 'Usefulness', score: 75 }
  ];
};

// 在组件挂载时获取数据
onMounted(() => {
  fetchDimensionScores();
});

// Chart data
const option = computed(() => {
  // 确保dimensions.value有数据
  if (!dimensions.value || dimensions.value.length === 0) {
    return {
      title: {
        text: 'No Data Available',
        left: 'center',
        top: 'center'
      }
    };
  }

  // 颜色映射
  const colorMap = {
    'Hallucination Control': '#7bb1db', // NXP Blue
    'Quality': '#f9b500', // NXP Orange
    'Professionalism': '#c9d200', // NXP Green
    'Usefulness': '#739833' // NXP Dark Green
  };

  // 准备数据
  const seriesData = dimensions.value.map(dim => ({
    value: dim.score,
    itemStyle: { color: colorMap[dim.name] || '#7bb1db' }
  }));

  return {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      },
      formatter: function(params) {
        const dataIndex = params[0].dataIndex;
        const dimension = dimensions.value[dataIndex];

        return `<strong>${dimension.name}</strong><br/>
                Score: ${dimension.score}`;
      }
    },
    grid: {
      left: 40,
      right: 40,
      bottom: 40,
      top: 40,
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: dimensions.value.map(d => d.name),
      axisLabel: {
        interval: 0,
        rotate: 30,
        formatter: function(value) {
          if (value.length > 12) {
            return value.substring(0, 12) + '...';
          }
          return value;
        },
        fontSize: 12,
        color: '#333',
        margin: 14
      },
      axisLine: {
        lineStyle: {
          color: '#e0e0e0'
        }
      },
      axisTick: {
        show: false
      }
    },
    yAxis: {
      type: 'value',
      min: 0,
      max: 100,
      splitLine: {
        lineStyle: {
          color: '#f0f0f0'
        }
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
        data: seriesData,
        barWidth: '40%',
        itemStyle: {
          borderRadius: [4, 4, 0, 0]
        },
        label: {
          show: true,
          position: 'inside',
          formatter: '{c}',
          fontSize: 14,
          fontWeight: 'bold',
          color: '#fff'
        },
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.1)'
          }
        }
      }
    ]
  };
});
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
