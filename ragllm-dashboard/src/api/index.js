import axios from 'axios';

// 创建axios实例
const apiClient = axios.create({
  baseURL: 'http://10.193.21.115:3333',
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 请求超时时间
});

// 请求拦截器
apiClient.interceptors.request.use(
  (config) => {
    // 在发送请求之前做些什么
    return config;
  },
  (error) => {
    // 对请求错误做些什么
    console.error('Request error:', error);
    return Promise.reject(error);
  }
);

// 响应拦截器
apiClient.interceptors.response.use(
  (response) => {
    // 对响应数据做点什么
    return response;
  },
  (error) => {
    // 对响应错误做点什么
    console.error('Response error:', error);
    return Promise.reject(error);
  }
);

export default apiClient;
