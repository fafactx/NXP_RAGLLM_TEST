<template>
  <a-row :gutter="16">
    <a-col :span="6">
      <a-card class="stat-card stat-card-1">
        <template #title>
          <div class="card-title">
            <experiment-outlined class="card-icon" />
            <span>{{ $t('dashboard.totalTest') }}</span>
          </div>
        </template>
        <div class="stat-value">547</div>
        <div class="stat-change increase">
          <arrow-up-outlined /> 12% {{ $t('dashboard.increase') }}
        </div>
      </a-card>
    </a-col>
    <a-col :span="6">
      <a-card class="stat-card stat-card-2">
        <template #title>
          <div class="card-title">
            <check-circle-outlined class="card-icon" />
            <span>{{ $t('dashboard.successRate') }}</span>
          </div>
        </template>
        <div class="stat-value">87%</div>
        <div class="stat-change increase">
          <arrow-up-outlined /> 3% {{ $t('dashboard.increase') }}
        </div>
      </a-card>
    </a-col>
    <a-col :span="6">
      <a-card class="stat-card stat-card-3">
        <template #title>
          <div class="card-title">
            <star-outlined class="card-icon" />
            <span>{{ $t('dashboard.averageScore') }}</span>
          </div>
        </template>
        <div class="stat-value">96</div>
        <div class="stat-change increase">
          <arrow-up-outlined /> 4 {{ $t('dashboard.increase') }}
        </div>
      </a-card>
    </a-col>
    <a-col :span="6">
      <a-card class="stat-card stat-card-4">
        <template #title>
          <div class="card-title">
            <clock-circle-outlined class="card-icon" />
            <span>{{ $t('dashboard.latestTest') }}</span>
          </div>
        </template>
        <div class="stat-value">2023-05-18</div>
        <div class="stat-change">3 hours ago</div>
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

const { t } = useI18n();
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
</style>
