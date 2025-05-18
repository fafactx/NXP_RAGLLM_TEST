# 评估结果后端服务

这是一个用于处理和存储评估结果的Node.js后端服务。

## 安装步骤

1. 确保已安装Node.js（推荐v16或更高版本）
2. 安装依赖：
   ```
   npm install
   ```

## 启动服务

```
npm start
```

服务将在 http://localhost:3000 上运行。

## 开发模式（自动重启）

```
npm run dev
```

## API端点

### 保存评估结果
- **URL**: `/api/save-evaluation`
- **方法**: POST
- **数据格式**:
  ```json
  {
    "result0": {
      "CAS Name": "example@nxp.com",
      "Product Family": "IVN",
      "MAG": "R16",
      "Part Number": "TJA1145A",
      "Question": "Why can't TJA1145 enter sleep mode？",
      "Answer": "...",
      "hallucination_control": 90,
      "quality": 85,
      "professionalism": 80,
      "usefulness": 85,
      "average_score": 85,
      "summary": "...",
      "LLM_ANSWER": "..."
    },
    "result1": {
      // 另一个评估结果
    }
  }
  ```

### 获取所有评估结果
- **URL**: `/api/evaluations`
- **方法**: GET

### 获取MAG分数统计
- **URL**: `/api/mag-scores`
- **方法**: GET

### 获取维度分数统计
- **URL**: `/api/dimension-scores`
- **方法**: GET

## 数据库

服务使用SQLite数据库存储评估结果，数据库文件位于`data/evaluations.db`。

## Linux部署

1. 安装Node.js和npm
2. 克隆或上传代码到服务器
3. 安装依赖：`npm install --production`
4. 使用PM2启动服务：
   ```
   npm install -g pm2
   pm2 start backend-code.js --name "evaluation-backend"
   pm2 startup
   pm2 save
   ```

## 与Dify集成

在Dify的Python函数中，使用以下代码将评估结果发送到后端服务：

```python
import requests
import json

def main(arg1: dict) -> dict:
    """
    将评估结果发送到可视化后端服务

    参数:
        arg1: 包含评估结果的对象，格式为 {"arg1": {"result0": {...}, "result1": {...}}}

    返回:
        包含操作结果的字典
    """
    try:
        # 检查数据格式并提取评估结果
        if isinstance(arg1, dict) and "arg1" in arg1:
            # 新格式：提取 arg1 字段中的数据
            evaluation_data = arg1["arg1"]
            print(f"检测到新数据格式，提取 arg1 字段中的数据: {json.dumps(evaluation_data)[:100]}...")
        else:
            # 旧格式：直接使用 arg1
            evaluation_data = arg1
            print(f"使用旧数据格式: {json.dumps(evaluation_data)[:100]}...")

        # 发送到后端服务
        response = requests.post(
            "http://your-server-ip:3000/api/save-evaluation",
            headers={"Content-Type": "application/json"},
            data=json.dumps(evaluation_data)
        )

        # 检查响应
        if response.status_code == 200:
            result = response.json()
            return {
                "result": {
                    "success": True,
                    "message": "评估数据已成功发送到可视化服务",
                    "details": result
                }
            }
        else:
            return {
                "result": {
                    "success": False,
                    "message": f"发送数据失败: HTTP {response.status_code}",
                    "details": response.text
                }
            }
    except Exception as e:
        return {
            "result": {
                "success": False,
                "message": f"处理评估数据时出错: {str(e)}"
            }
        }
```
