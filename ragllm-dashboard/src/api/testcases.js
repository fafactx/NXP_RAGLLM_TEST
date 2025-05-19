import apiClient from './index';

/**
 * 获取所有测试用例
 * @returns {Promise} 包含测试用例的Promise
 */
export const getTestCases = async () => {
  try {
    // 使用评估结果API，因为测试用例数据来自同一个表
    const response = await apiClient.get('/api/evaluations');
    return response.data;
  } catch (error) {
    console.error('获取测试用例失败:', error);
    throw error;
  }
};

/**
 * 获取测试用例详情
 * @param {string} id 测试用例ID
 * @returns {Promise} 包含测试用例详情的Promise
 */
export const getTestCaseDetails = async (id) => {
  try {
    const response = await apiClient.get(`/api/evaluations/${id}`);
    return response.data;
  } catch (error) {
    console.error(`获取测试用例详情失败 (ID: ${id}):`, error);
    throw error;
  }
};

/**
 * 删除测试用例
 * @param {Array<number>} ids 要删除的测试用例ID数组
 * @returns {Promise} 包含删除结果的Promise
 */
export const deleteTestCasesAPI = async (ids) => {
  try {
    const response = await apiClient.delete('/api/evaluations', {
      data: { ids }
    });
    return response.data;
  } catch (error) {
    console.error('删除测试用例失败:', error);
    throw error;
  }
};
