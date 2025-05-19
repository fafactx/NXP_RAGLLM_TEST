import apiClient from './index';

/**
 * 获取所有评估结果
 * @returns {Promise} 包含评估结果的Promise
 */
export const getEvaluations = async () => {
  try {
    const response = await apiClient.get('/api/evaluations');
    return response.data;
  } catch (error) {
    console.error('获取评估结果失败:', error);
    throw error;
  }
};

/**
 * 获取MAG分数统计
 * @returns {Promise} 包含MAG分数统计的Promise
 */
export const getMagScores = async () => {
  try {
    const response = await apiClient.get('/api/mag-scores');
    return response.data;
  } catch (error) {
    console.error('获取MAG分数失败:', error);
    throw error;
  }
};

/**
 * 获取维度分数统计
 * @returns {Promise} 包含维度分数统计的Promise
 */
export const getDimensionScores = async () => {
  try {
    const response = await apiClient.get('/api/dimension-scores');
    return response.data;
  } catch (error) {
    console.error('获取维度分数失败:', error);
    throw error;
  }
};
