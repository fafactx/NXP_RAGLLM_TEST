<template>
  <div class="recent-tests-table">
    <div class="table-header">
      <h3>最近测试结果</h3>
      <a-button type="primary" shape="round">
        <template #icon><right-outlined /></template>
        View All
      </a-button>
    </div>
    <a-table
      :columns="columns"
      :data-source="data"
      :pagination="false"
      :row-class-name="(_record, index) => (index % 2 === 1 ? 'table-striped' : '')"
    />
  </div>
</template>

<script setup>
import { ref, h } from 'vue';
import { Tag as ATag } from 'ant-design-vue';
import { RightOutlined } from '@ant-design/icons-vue';

// 表格列定义
const columns = [
  {
    title: '测试ID',
    dataIndex: 'id',
    key: 'id',
  },
  {
    title: '测试名称',
    dataIndex: 'name',
    key: 'name',
  },
  {
    title: '日期',
    dataIndex: 'date',
    key: 'date',
  },
  {
    title: '评分',
    dataIndex: 'score',
    key: 'score',
  },
  {
    title: '状态',
    dataIndex: 'status',
    key: 'status',
    customRender: ({ text }) => {
      const color = text === '成功' ? 'success' : text === '失败' ? 'error' : 'warning';
      return h(ATag, { color: color }, () => text);
    }
  },
  {
    title: '操作',
    key: 'action',
    customRender: () => {
      return h('a', {}, '查看详情');
    }
  }
];

// 表格数据
const data = [
  {
    key: '1',
    id: 'T-1001',
    name: '基础问答测试',
    date: '2023-05-18',
    score: '4.8',
    status: '成功'
  },
  {
    key: '2',
    id: 'T-1002',
    name: '多轮对话测试',
    date: '2023-05-17',
    score: '4.5',
    status: '成功'
  },
  {
    key: '3',
    id: 'T-1003',
    name: '知识检索测试',
    date: '2023-05-16',
    score: '3.9',
    status: '部分成功'
  },
  {
    key: '4',
    id: 'T-1004',
    name: '代码生成测试',
    date: '2023-05-15',
    score: '4.2',
    status: '成功'
  },
  {
    key: '5',
    id: 'T-1005',
    name: '边界情况测试',
    date: '2023-05-14',
    score: '3.7',
    status: '部分成功'
  }
];
</script>

<style scoped>
.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
</style>
