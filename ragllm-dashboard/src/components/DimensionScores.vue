<template>
  <div class="chart-container">
    <h3>Dimension Scores</h3>
    <v-chart class="chart" :option="option" autoresize />
  </div>
</template>

<script setup>
import { use } from 'echarts/core';
import { CanvasRenderer } from 'echarts/renderers';
import { BarChart } from 'echarts/charts';
import { GridComponent, TooltipComponent, TitleComponent, LegendComponent } from 'echarts/components';
import VChart from 'vue-echarts';
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';

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

// Dimension data
const dimensions = [
  { name: 'Hallucination Control', score: 90, percentage: 25 },
  { name: 'Quality', score: 85, percentage: 30 },
  { name: 'Professionalism', score: 80, percentage: 25 },
  { name: 'Usefulness', score: 75, percentage: 20 }
];

// Chart data
const option = computed(() => ({
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'shadow'
    },
    formatter: function(params) {
      const dataIndex = params[0].dataIndex;
      const dimension = dimensions[dataIndex];

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
    data: dimensions.map(d => d.name),
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
      data: [
        {
          value: dimensions[0].score,
          itemStyle: { color: '#7bb1db' } // NXP Blue
        },
        {
          value: dimensions[1].score,
          itemStyle: { color: '#f9b500' } // NXP Orange
        },
        {
          value: dimensions[2].score,
          itemStyle: { color: '#c9d200' } // NXP Green
        },
        {
          value: dimensions[3].score,
          itemStyle: { color: '#739833' } // NXP Dark Green
        }
      ],
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
}));
</script>

<style scoped>
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
</style>
