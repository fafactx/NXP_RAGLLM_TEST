<template>
  <div class="chart-container">
    <div class="chart-header">
      <h3>评分分布</h3>
      <a-tag color="blue">Filtered</a-tag>
    </div>
    <v-chart class="chart" :option="option" autoresize />
  </div>
</template>

<script setup>
import { use } from 'echarts/core';
import { CanvasRenderer } from 'echarts/renderers';
import { BarChart } from 'echarts/charts';
import { GridComponent, TooltipComponent, TitleComponent } from 'echarts/components';
import VChart from 'vue-echarts';
import { ref } from 'vue';

// 注册必要的组件
use([
  CanvasRenderer,
  BarChart,
  GridComponent,
  TooltipComponent,
  TitleComponent
]);

// 图表数据
const option = ref({
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'shadow'
    },
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    borderColor: '#e6e6e6',
    borderWidth: 1,
    textStyle: {
      color: '#333'
    },
    formatter: '{b}分数段<br/>{a}: <strong>{c}</strong>'
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '3%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    data: ['1-2', '2-3', '3-4', '4-5'],
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
    max: 400,
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
      name: '数量',
      type: 'bar',
      data: [30, 80, 150, 287],
      barWidth: '60%',
      itemStyle: {
        color: {
          type: 'linear',
          x: 0,
          y: 0,
          x2: 0,
          y2: 1,
          colorStops: [
            { offset: 0, color: 'var(--primary-light)' },
            { offset: 1, color: 'var(--primary-color)' }
          ]
        },
        borderRadius: [4, 4, 0, 0]
      },
      emphasis: {
        itemStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: 'var(--primary-color)' },
              { offset: 1, color: 'var(--primary-dark)' }
            ]
          }
        }
      }
    }
  ]
});
</script>

<style scoped>
.chart {
  height: 300px;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
</style>
