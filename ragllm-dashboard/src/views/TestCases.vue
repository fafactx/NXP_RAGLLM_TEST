<template>
  <div class="testcases-container">
    <h2 class="page-title">{{ $t('menu.testCases') }}</h2>
    
    <div class="recent-tests-table">
      <div class="table-header">
        <h3>{{ $t('testCases.recentTests') }}</h3>
        <a-button type="primary" shape="round">
          <template #icon><right-outlined /></template>
          {{ $t('testCases.viewAll') }}
        </a-button>
      </div>
      <a-table
        :columns="columns"
        :data-source="data"
        :pagination="{ pageSize: 10 }"
        :row-class-name="(_record, index) => (index % 2 === 1 ? 'table-striped' : '')"
      />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { RightOutlined } from '@ant-design/icons-vue';
import { h } from 'vue';
import { Tag as ATag } from 'ant-design-vue';

const { t } = useI18n();

// Table columns
const columns = computed(() => [
  {
    title: t('testCases.testId'),
    dataIndex: 'id',
    key: 'id',
  },
  {
    title: t('testCases.testName'),
    dataIndex: 'name',
    key: 'name',
  },
  {
    title: t('testCases.date'),
    dataIndex: 'date',
    key: 'date',
  },
  {
    title: t('testCases.score'),
    dataIndex: 'score',
    key: 'score',
  },
  {
    title: t('testCases.status'),
    dataIndex: 'status',
    key: 'status',
    customRender: ({ text }) => {
      const statusMap = {
        'success': 'success',
        'failure': 'error',
        'partial_success': 'warning'
      };
      
      const textMap = {
        'success': t('testCases.success'),
        'failure': t('testCases.failure'),
        'partial_success': t('testCases.partialSuccess')
      };
      
      return h(ATag, { color: statusMap[text] }, () => textMap[text]);
    }
  },
  {
    title: t('testCases.action'),
    key: 'action',
    customRender: () => {
      return h('a', {}, t('testCases.viewDetails'));
    }
  }
]);

// Table data
const data = [
  {
    key: '1',
    id: 'T-1001',
    name: 'Basic Q&A Test',
    date: '2023-05-18',
    score: '96',
    status: 'success'
  },
  {
    key: '2',
    id: 'T-1002',
    name: 'Multi-turn Dialogue Test',
    date: '2023-05-17',
    score: '90',
    status: 'success'
  },
  {
    key: '3',
    id: 'T-1003',
    name: 'Knowledge Retrieval Test',
    date: '2023-05-16',
    score: '78',
    status: 'partial_success'
  },
  {
    key: '4',
    id: 'T-1004',
    name: 'Code Generation Test',
    date: '2023-05-15',
    score: '84',
    status: 'success'
  },
  {
    key: '5',
    id: 'T-1005',
    name: 'Edge Cases Test',
    date: '2023-05-14',
    score: '74',
    status: 'partial_success'
  },
  {
    key: '6',
    id: 'T-1006',
    name: 'Hallucination Test',
    date: '2023-05-13',
    score: '92',
    status: 'success'
  },
  {
    key: '7',
    id: 'T-1007',
    name: 'Reasoning Test',
    date: '2023-05-12',
    score: '88',
    status: 'success'
  },
  {
    key: '8',
    id: 'T-1008',
    name: 'Factual Accuracy Test',
    date: '2023-05-11',
    score: '65',
    status: 'failure'
  }
];
</script>

<style scoped>
.testcases-container {
  padding: 20px;
}

.page-title {
  margin-bottom: 20px;
  font-size: 24px;
  font-weight: 500;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
</style>
