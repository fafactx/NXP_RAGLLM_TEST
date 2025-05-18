<template>
  <div class="chart-container">
    <h3>{{ $t('dashboard.performanceTrend') }}</h3>
    <v-chart class="chart" :option="option" autoresize />
    <a-table :columns="columns" :data-source="data" :pagination="false" size="small" />
  </div>
</template>

<script setup>
import { use } from 'echarts/core';
import { CanvasRenderer } from 'echarts/renderers';
import { LineChart } from 'echarts/charts';
import { GridComponent, TooltipComponent, TitleComponent, LegendComponent } from 'echarts/components';
import VChart from 'vue-echarts';
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';

const { t } = useI18n();

// Register necessary components
use([
  CanvasRenderer,
  LineChart,
  GridComponent,
  TooltipComponent,
  TitleComponent,
  LegendComponent
]);

// Convert 5-point scale to 100-point scale
const convertToPercentage = (score) => Math.round(score * 20);

// Chart data
const option = ref({
  tooltip: {
    trigger: 'axis',
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    borderColor: '#e6e6e6',
    borderWidth: 1,
    textStyle: {
      color: '#333'
    },
    formatter: '{b}<br/>{a}: <strong>{c}</strong>'
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '3%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    boundaryGap: false,
    data: ['Day1', 'Day2', 'Day3', 'Day4', 'Day5', 'Day6', 'Day7'],
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
    min: 70,
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
      name: 'Performance Score',
      type: 'line',
      data: [84, 86, 90, 88, 92, 94, 96], // Converted to 100-point scale
      smooth: true,
      symbol: 'circle',
      symbolSize: 8,
      lineStyle: {
        color: 'var(--primary-color)',
        width: 4,
        shadowColor: 'rgba(123, 177, 219, 0.3)',
        shadowBlur: 10
      },
      itemStyle: {
        color: 'var(--primary-color)',
        borderColor: '#fff',
        borderWidth: 2
      },
      areaStyle: {
        color: {
          type: 'linear',
          x: 0,
          y: 0,
          x2: 0,
          y2: 1,
          colorStops: [
            { offset: 0, color: 'rgba(123, 177, 219, 0.3)' },
            { offset: 1, color: 'rgba(123, 177, 219, 0.05)' }
          ]
        }
      }
    }
  ]
});

// Table columns
const columns = computed(() => [
  {
    title: t('dashboard.date'),
    dataIndex: 'date',
    key: 'date',
  },
  {
    title: t('dashboard.score'),
    dataIndex: 'score',
    key: 'score',
  },
  {
    title: t('dashboard.change'),
    dataIndex: 'change',
    key: 'change',
  }
]);

// Table data
const data = [
  {
    key: '1',
    date: 'Day1',
    score: '84',
    change: '-'
  },
  {
    key: '2',
    date: 'Day2',
    score: '86',
    change: '+2'
  },
  {
    key: '3',
    date: 'Day3',
    score: '90',
    change: '+4'
  },
  {
    key: '4',
    date: 'Day4',
    score: '88',
    change: '-2'
  },
  {
    key: '5',
    date: 'Day5',
    score: '92',
    change: '+4'
  },
  {
    key: '6',
    date: 'Day6',
    score: '94',
    change: '+2'
  },
  {
    key: '7',
    date: 'Day7',
    score: '96',
    change: '+2'
  }
];
</script>

<style scoped>
.chart {
  height: 300px;
}
</style>
