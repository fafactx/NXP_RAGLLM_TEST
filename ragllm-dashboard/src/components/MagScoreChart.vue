<template>
  <div class="chart-container">
    <h3>MAG Score</h3>
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

// Sample MAG data
const magData = [
  { mag: 'RAN', score: 92, percentage: 10.80 },
  { mag: 'RA1', score: 88, percentage: 8.64 },
  { mag: 'R16', score: 85, percentage: 8.33 },
  { mag: 'RMP', score: 83, percentage: 7.72 },
  { mag: 'RPM', score: 80, percentage: 6.17 },
  { mag: 'RC7', score: 78, percentage: 4.94 },
  { mag: 'RC8', score: 76, percentage: 4.63 },
  { mag: 'RAS', score: 75, percentage: 4.63 },
  { mag: 'RSE', score: 74, percentage: 4.63 },
  { mag: 'RAU', score: 72, percentage: 4.01 },
  { mag: 'RMC', score: 70, percentage: 3.09 },
  { mag: 'RE8', score: 68, percentage: 3.09 },
  { mag: 'RG8', score: 67, percentage: 3.09 },
  { mag: 'RST', score: 64, percentage: 2.16 },
  { mag: 'R01', score: 62, percentage: 1.85 },
  { mag: 'RMB', score: 60, percentage: 1.85 },
  { mag: 'RK7', score: 58, percentage: 1.54 },
  { mag: 'RGP', score: 57, percentage: 1.54 },
  { mag: 'RB7', score: 55, percentage: 1.54 },
  { mag: 'RCS', score: 54, percentage: 1.54 },
  { mag: 'RNG', score: 52, percentage: 0.93 },
  { mag: 'RMU', score: 50, percentage: 0.31 }
];

// Sort data by percentage (descending)
const sortedData = [...magData].sort((a, b) => b.percentage - a.percentage);

// Prepare data for chart
const magNames = sortedData.map(item => item.mag);
const magScores = sortedData.map(item => item.score);
// 使用分数而不是百分比
const normalizedScores = sortedData.map(item => item.score);
const remainingScores = sortedData.map(item => 100 - item.score);

// Chart options
const option = computed(() => ({
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'shadow'
    },
    formatter: function(params) {
      const dataIndex = params[0].dataIndex;
      const mag = magNames[dataIndex];
      const score = magScores[dataIndex];

      return `<strong>${mag}</strong><br/>
              Score: ${score}`;
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
    data: magNames.slice(0, 10), // 只显示前10个MAG，避免图表过于拥挤
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
          return magScores[index];
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
      data: normalizedScores.slice(0, 10)
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
      data: remainingScores.slice(0, 10)
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
