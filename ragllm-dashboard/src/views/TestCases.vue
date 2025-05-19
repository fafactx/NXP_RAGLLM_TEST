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
      <div v-if="error" class="error-message">
        <a-alert type="error" :message="error" show-icon />
      </div>
      <a-table
        :columns="columns"
        :data-source="data"
        :pagination="{ pageSize: 10 }"
        :row-class-name="(_record, index) => (index % 2 === 1 ? 'table-striped' : '')"
        :loading="loading"
      />
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { RightOutlined } from '@ant-design/icons-vue';
import { h } from 'vue';
import { Tag as ATag } from 'ant-design-vue';
import { getTestCases } from '../api/testcases';

const { t } = useI18n();

// 状态变量
const loading = ref(true);
const error = ref(null);
const testCases = ref([]);

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

// 获取测试用例数据
const fetchTestCases = async () => {
  try {
    loading.value = true;
    error.value = null;
    const response = await getTestCases();

    if (response.success && response.data) {
      // 转换API返回的数据格式为表格所需格式
      testCases.value = response.data.map((item, index) => {
        // 根据分数确定状态
        let status = 'success';
        if (item.average_score < 70) {
          status = 'failure';
        } else if (item.average_score < 80) {
          status = 'partial_success';
        }

        // 格式化日期
        const date = new Date(item.created_at);
        const formattedDate = date.toISOString().split('T')[0]; // 格式: YYYY-MM-DD

        // 使用question作为测试名称，如果太长则截断
        let testName = item.question || 'Unknown Test';
        if (testName.length > 30) {
          testName = testName.substring(0, 30) + '...';
        }

        return {
          key: (index + 1).toString(),
          id: `T-${item.id.toString().padStart(4, '0')}`,
          name: testName,
          date: formattedDate,
          score: item.average_score.toString(),
          status: status,
          raw_data: item // 保存原始数据，以便查看详情
        };
      });
    } else {
      // 如果没有数据，使用示例数据
      useExampleData();
    }
  } catch (err) {
    console.error('获取测试用例失败:', err);
    error.value = '获取数据失败，请稍后再试';
    // 使用示例数据作为后备
    useExampleData();
  } finally {
    loading.value = false;
  }
};

// 使用示例数据
const useExampleData = () => {
  testCases.value = [
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
};

// 在组件挂载时获取数据
onMounted(() => {
  fetchTestCases();
});

// 表格数据（使用计算属性，以便在testCases变化时自动更新）
const data = computed(() => testCases.value);
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

.error-message {
  margin-bottom: 16px;
}

.table-striped {
  background-color: #fafafa;
}
</style>
