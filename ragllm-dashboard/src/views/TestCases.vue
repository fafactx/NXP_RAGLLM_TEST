<template>
  <div class="testcases-container">
    <h2 class="page-title">{{ $t('menu.testCases') }}</h2>

    <div class="recent-tests-table">
      <div class="table-header">
        <h3>{{ showAllTests ? $t('testCases.allTests') : $t('testCases.recentTests') }}</h3>
        <div class="table-actions">
          <a-button-group style="margin-right: 8px;">
            <a-button
              type="primary"
              :disabled="selectedRowKeys.length === 0"
              @click="exportToExcel"
            >
              <template #icon><file-excel-outlined /></template>
              {{ $t('testCases.exportExcel') }}
            </a-button>
            <a-button
              :disabled="selectedRowKeys.length === 0"
              @click="exportToPDF"
            >
              <template #icon><file-pdf-outlined /></template>
              {{ $t('testCases.exportPDF') }}
            </a-button>
            <a-button
              danger
              :disabled="selectedRowKeys.length === 0"
              @click="deleteTestCases"
            >
              <template #icon><delete-outlined /></template>
              {{ $t('testCases.delete') }}
            </a-button>
          </a-button-group>
          <a-button type="primary" shape="round" @click="toggleViewAll">
            <template #icon>
              <right-outlined v-if="!showAllTests" />
              <left-outlined v-else />
            </template>
            {{ showAllTests ? $t('testCases.viewRecent') : $t('testCases.viewAll') }}
          </a-button>
        </div>
      </div>
      <div v-if="error" class="error-message">
        <a-alert type="error" :message="error" show-icon />
      </div>
      <a-table
        :columns="columns"
        :data-source="data"
        :pagination="{
          pageSize: showAllTests ? 20 : 10,
          showSizeChanger: showAllTests,
          pageSizeOptions: ['10', '20', '50', '100'],
          showTotal: (total) => `共 ${total} 条记录`
        }"
        :row-class-name="(_record, index) => (index % 2 === 1 ? 'table-striped' : '')"
        :loading="loading"
        :row-selection="{
          selectedRowKeys: selectedRowKeys,
          onChange: onSelectChange,
          selections: [
            Table.SELECTION_ALL,
            Table.SELECTION_INVERT,
            Table.SELECTION_NONE
          ]
        }"
      >
        <template #footer>
          <div class="table-footer">
            <span v-if="selectedRowKeys.length > 0">
              {{ $t('testCases.selected', { count: selectedRowKeys.length }) }}
            </span>
          </div>
        </template>
      </a-table>
    </div>

    <!-- 详情对话框 -->
    <a-modal
      v-model:visible="detailsVisible"
      :title="currentDetails ? currentDetails.question : '测试详情'"
      width="800px"
      @cancel="closeDetails"
    >
      <div v-if="currentDetails" class="test-details">
        <a-descriptions bordered :column="1">
          <a-descriptions-item label="CAS Name">{{ currentDetails.cas_name }}</a-descriptions-item>
          <a-descriptions-item label="Product Family">{{ currentDetails.product_family }}</a-descriptions-item>
          <a-descriptions-item label="MAG">{{ currentDetails.mag }}</a-descriptions-item>
          <a-descriptions-item label="Part Number">{{ currentDetails.part_number }}</a-descriptions-item>
          <a-descriptions-item label="Question">{{ currentDetails.question }}</a-descriptions-item>
          <a-descriptions-item label="Answer">{{ currentDetails.answer }}</a-descriptions-item>
          <a-descriptions-item label="Question Scenario">{{ currentDetails.question_scenario }}</a-descriptions-item>
          <a-descriptions-item label="Answer Source">{{ currentDetails.answer_source }}</a-descriptions-item>
          <a-descriptions-item label="Question Complexity">{{ currentDetails.question_complexity }}</a-descriptions-item>
          <a-descriptions-item label="Question Frequency">{{ currentDetails.question_frequency }}</a-descriptions-item>
          <a-descriptions-item label="Question Category">{{ currentDetails.question_category }}</a-descriptions-item>
          <a-descriptions-item label="Source Category">{{ currentDetails.source_category }}</a-descriptions-item>
        </a-descriptions>

        <div class="scores-section">
          <h3>评分详情</h3>
          <a-row :gutter="16">
            <a-col :span="6">
              <a-statistic title="Hallucination Control" :value="currentDetails.hallucination_control" />
            </a-col>
            <a-col :span="6">
              <a-statistic title="Quality" :value="currentDetails.quality" />
            </a-col>
            <a-col :span="6">
              <a-statistic title="Professionalism" :value="currentDetails.professionalism" />
            </a-col>
            <a-col :span="6">
              <a-statistic title="Usefulness" :value="currentDetails.usefulness" />
            </a-col>
          </a-row>
          <a-row style="margin-top: 16px;">
            <a-col :span="24">
              <a-statistic title="Average Score" :value="currentDetails.average_score" :value-style="{ color: currentDetails.average_score >= 70 ? '#3f8600' : '#cf1322' }" />
            </a-col>
          </a-row>
        </div>

        <div class="llm-answer-section">
          <h3>LLM回答</h3>
          <a-card>
            <pre>{{ currentDetails.llm_answer }}</pre>
          </a-card>
        </div>

        <div class="summary-section">
          <h3>总结</h3>
          <a-card>
            <p>{{ currentDetails.summary }}</p>
          </a-card>
        </div>
      </div>

      <template #footer>
        <a-button @click="closeDetails">关闭</a-button>
      </template>
    </a-modal>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import {
  RightOutlined,
  LeftOutlined,
  FileExcelOutlined,
  FilePdfOutlined,
  DeleteOutlined
} from '@ant-design/icons-vue';
import { h } from 'vue';
import { Tag as ATag, message, Modal, Table } from 'ant-design-vue';
import { getTestCases, deleteTestCasesAPI } from '../api/testcases';

const { t } = useI18n();

// 状态变量
const loading = ref(true);
const error = ref(null);
const testCases = ref([]);
const selectedRowKeys = ref([]); // 选中的行
const selectedRows = ref([]); // 选中的行数据

// Table columns
const columns = computed(() => [
  {
    title: t('testCases.testId'),
    dataIndex: 'id',
    key: 'id',
    width: 100
  },
  {
    title: t('testCases.testName'),
    dataIndex: 'question',
    key: 'question',
    ellipsis: true
  },
  {
    title: t('testCases.date'),
    dataIndex: 'date',
    key: 'date',
    width: 120
  },
  {
    title: t('testCases.score'),
    dataIndex: 'score',
    key: 'score',
    width: 80
  },
  {
    title: t('testCases.status'),
    dataIndex: 'status',
    key: 'status',
    width: 100,
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
    width: 120,
    customRender: ({ record }) => {
      return h('a', {
        onClick: () => viewDetails(record)
      }, t('testCases.viewDetails'));
    }
  }
]);

// 查看详情对话框
const detailsVisible = ref(false);
const currentDetails = ref(null);
const passingThreshold = ref(70); // 默认及格线为70
const showAllTests = ref(false); // 控制是否显示所有测试用例

// 从localStorage读取及格线设置
const loadPassingThreshold = () => {
  const savedThreshold = localStorage.getItem('passingScore');
  if (savedThreshold) {
    passingThreshold.value = parseInt(savedThreshold, 10);
    console.log('从localStorage加载及格线:', passingThreshold.value);
  }
};

// 查看详情函数
const viewDetails = (record) => {
  currentDetails.value = record.raw_data;
  detailsVisible.value = true;
};

// 关闭详情对话框
const closeDetails = () => {
  detailsVisible.value = false;
};

// 切换显示所有测试用例
const toggleViewAll = () => {
  showAllTests.value = !showAllTests.value;
};

// 处理行选择变化
const onSelectChange = (keys, rows) => {
  selectedRowKeys.value = keys;
  selectedRows.value = rows;
};

// 导出为Excel
const exportToExcel = () => {
  if (selectedRows.value.length === 0) {
    // 如果没有选中行，提示用户
    message.warning(t('testCases.selectRowsToExport'));
    return;
  }

  // 显示加载中
  message.loading(t('testCases.exporting'), 0);

  // 准备导出数据
  const exportData = selectedRows.value.map(row => {
    const item = row.raw_data;
    return {
      'Test ID': row.id,
      'CAS Name': item.cas_name,
      'Product Family': item.product_family,
      'MAG': item.mag,
      'Part Number': item.part_number,
      'Question': item.question,
      'Answer': item.answer,
      'Question Scenario': item.question_scenario,
      'Answer Source': item.answer_source,
      'Question Complexity': item.question_complexity,
      'Question Frequency': item.question_frequency,
      'Question Category': item.question_category,
      'Source Category': item.source_category,
      'Hallucination Control': item.hallucination_control,
      'Quality': item.quality,
      'Professionalism': item.professionalism,
      'Usefulness': item.usefulness,
      'Average Score': item.average_score,
      'Date': row.date
    };
  });

  // 使用xlsx库导出Excel
  import('xlsx').then(XLSX => {
    const worksheet = XLSX.utils.json_to_sheet(exportData);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Test Cases');

    // 生成Excel文件并下载
    XLSX.writeFile(workbook, 'test_cases_export.xlsx');

    // 关闭加载提示，显示成功提示
    message.destroy();
    message.success(t('testCases.exportSuccess'));
  }).catch(error => {
    console.error('导出Excel失败:', error);
    message.destroy();
    message.error(t('testCases.exportFailed'));
  });
};

// 导出为PDF
const exportToPDF = () => {
  if (selectedRows.value.length === 0) {
    // 如果没有选中行，提示用户
    message.warning(t('testCases.selectRowsToExport'));
    return;
  }

  // 显示加载中
  message.loading(t('testCases.exporting'), 0);

  // 使用jspdf和jspdf-autotable库导出PDF
  Promise.all([
    import('jspdf'),
    import('jspdf-autotable')
  ]).then(([{ default: jsPDF }, { default: autoTable }]) => {
    const doc = new jsPDF();

    // 添加标题
    doc.setFontSize(16);
    doc.text('Test Cases Export', 14, 15);
    doc.setFontSize(10);
    doc.text(`Export Date: ${new Date().toLocaleString()}`, 14, 22);

    // 准备表格数据
    const tableData = selectedRows.value.map(row => {
      const item = row.raw_data;
      return [
        row.id,
        item.question,
        item.average_score,
        row.date,
        item.cas_name,
        item.product_family,
        item.mag
      ];
    });

    // 生成表格
    autoTable(doc, {
      startY: 30,
      head: [['Test ID', 'Question', 'Score', 'Date', 'CAS Name', 'Product Family', 'MAG']],
      body: tableData,
      theme: 'striped',
      headStyles: { fillColor: [66, 139, 202] }
    });

    // 保存PDF文件
    doc.save('test_cases_export.pdf');

    // 关闭加载提示，显示成功提示
    message.destroy();
    message.success(t('testCases.exportSuccess'));
  }).catch(error => {
    console.error('导出PDF失败:', error);
    message.destroy();
    message.error(t('testCases.exportFailed'));
  });
};

// 删除选中的测试用例
const deleteTestCases = () => {
  if (selectedRowKeys.value.length === 0) {
    // 如果没有选中行，提示用户
    message.warning(t('testCases.selectRowsToDelete'));
    return;
  }

  // 显示确认对话框
  Modal.confirm({
    title: t('testCases.confirmDelete'),
    content: t('testCases.deleteConfirmContent', { count: selectedRowKeys.value.length }),
    okText: t('testCases.delete'),
    okType: 'danger',
    cancelText: t('testCases.cancel'),
    onOk: async () => {
      try {
        // 显示加载中
        message.loading(t('testCases.deleting'), 0);

        // 获取选中行的ID
        const idsToDelete = selectedRows.value.map(row => row.raw_data.id);

        // 调用删除API
        const response = await deleteTestCasesAPI(idsToDelete);

        if (response.success) {
          // 删除成功，刷新数据
          message.destroy();
          message.success(t('testCases.deleteSuccess'));

          // 清空选中行
          selectedRowKeys.value = [];
          selectedRows.value = [];

          // 重新获取数据
          fetchTestCases();
        } else {
          // 删除失败
          message.destroy();
          message.error(response.message || t('testCases.deleteFailed'));
        }
      } catch (error) {
        console.error('删除测试用例失败:', error);
        message.destroy();
        message.error(t('testCases.deleteFailed'));
      }
    }
  });
};

// 获取测试用例数据
const fetchTestCases = async () => {
  try {
    loading.value = true;
    error.value = null;
    const response = await getTestCases();

    if (response.success && response.data) {
      // 转换API返回的数据格式为表格所需格式
      testCases.value = response.data.map((item, index) => {
        // 根据分数和及格线确定状态
        let status = 'success';
        if (item.average_score < passingThreshold.value) {
          status = 'failure';
        } else if (item.average_score < passingThreshold.value + 10) {
          status = 'partial_success';
        }

        // 格式化日期
        const date = new Date(item.created_at);
        const formattedDate = date.toISOString().split('T')[0]; // 格式: YYYY-MM-DD

        return {
          key: (index + 1).toString(),
          id: `T-${item.id.toString().padStart(4, '0')}`,
          question: item.question || 'Unknown Test',
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
  // 根据及格线确定状态
  const getStatus = (score) => {
    const numScore = parseInt(score, 10);
    if (numScore < passingThreshold.value) {
      return 'failure';
    } else if (numScore < passingThreshold.value + 10) {
      return 'partial_success';
    } else {
      return 'success';
    }
  };

  testCases.value = [
    {
      key: '1',
      id: 'T-0001',
      question: 'Why can\'t TJA1145 enter sleep mode?',
      date: '2023-05-18',
      score: '67',
      status: getStatus('67'),
      raw_data: {
        id: 1,
        cas_name: 'mia.zhang_1@nxp.com',
        product_family: 'IVN',
        mag: 'R16',
        part_number: 'TJA1145A',
        question: 'Why can\'t TJA1145 enter sleep mode?',
        answer: 'It is recommended to check whether there is a pending wake-up event at this time or whether any wake-up source is enabled',
        question_scenario: 'Parameter Configuration',
        answer_source: 'TJA1145A: Chapter 7.1.1.3',
        question_complexity: 'Low',
        question_frequency: 'High',
        question_category: 'Low Complexity Question',
        source_category: 'Public',
        hallucination_control: 90,
        quality: 85,
        professionalism: 80,
        usefulness: 75,
        average_score: 67,
        summary: 'The LLM answer provides a detailed explanation of the TJA1145\'s design and operation, avoiding the need for a sleep mode.',
        llm_answer: 'The TJA1145 is a dual-input single-output (DISS) switch designed for use in audio applications. It does not have an internal sleep mode or similar functionality as some other components.',
        created_at: '2023-05-18T10:30:00.000Z'
      }
    },
    {
      key: '2',
      id: 'T-0002',
      question: 'Under what conditions will NXP\'s TJA1145 enter sleep mode?',
      date: '2023-05-18',
      score: '65',
      status: getStatus('65'),
      raw_data: {
        id: 2,
        cas_name: 'john.doe@nxp.com',
        product_family: 'IVN',
        mag: 'R16',
        part_number: 'TJA1145A',
        question: 'Under what conditions will NXP\'s TJA1145 enter sleep mode?',
        answer: 'The TJA1145 will enter Sleep mode when the SPI Mode Control register is set to Sleep mode, provided there are no pending wake-up events.',
        question_scenario: 'Parameter Configuration',
        answer_source: 'TJA1145A: Chapter 7.1.1.3',
        question_complexity: 'Medium',
        question_frequency: 'Medium',
        question_category: 'Medium Complexity Question',
        source_category: 'Public',
        hallucination_control: 70,
        quality: 65,
        professionalism: 60,
        usefulness: 65,
        average_score: 65,
        summary: 'The LLM answer correctly identifies the conditions for the TJA1145 to enter sleep mode.',
        llm_answer: 'The NXP TJA1145 will enter sleep mode under the following conditions:\n\n1. When the SPI Mode Control register is set to Sleep mode (MC = 01)\n2. When there are no pending wake-up events\n3. When all wake-up sources are disabled or inactive',
        created_at: '2023-05-18T09:15:00.000Z'
      }
    }
  ];
};

// 在组件挂载时获取数据
onMounted(() => {
  loadPassingThreshold(); // 先加载及格线设置
  fetchTestCases();
});

// 表格数据（使用计算属性，以便在testCases变化时自动更新）
const data = computed(() => {
  // 如果showAllTests为true，显示所有测试用例，否则只显示最近的10个
  return showAllTests.value ? testCases.value : testCases.value.slice(0, 10);
});
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

.table-actions {
  display: flex;
  align-items: center;
}

.table-footer {
  padding: 8px 0;
  font-size: 14px;
  color: #666;
}

.error-message {
  margin-bottom: 16px;
}

.table-striped {
  background-color: #fafafa;
}

.test-details {
  max-height: 600px;
  overflow-y: auto;
}

.scores-section,
.llm-answer-section,
.summary-section {
  margin-top: 24px;
}

.scores-section h3,
.llm-answer-section h3,
.summary-section h3 {
  margin-bottom: 16px;
  font-size: 16px;
  font-weight: 500;
}

pre {
  white-space: pre-wrap;
  word-wrap: break-word;
  background-color: #f5f5f5;
  padding: 12px;
  border-radius: 4px;
  margin: 0;
}
</style>
