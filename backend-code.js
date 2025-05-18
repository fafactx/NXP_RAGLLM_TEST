// backend-code.js
// Node.js + Express后端代码

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

// 创建Express应用
const app = express();
const port = process.env.PORT || 3333;

// 中间件
app.use(cors());
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '10mb' }));

// 确保数据目录存在
const dataDir = path.join(__dirname, 'data');
if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
}

// 创建SQLite数据库连接
const dbPath = path.join(dataDir, 'evaluations.db');
const db = new sqlite3.Database(dbPath);

// 初始化数据库
db.serialize(() => {
    db.run(`
        CREATE TABLE IF NOT EXISTS evaluation_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cas_name TEXT,
            product_family TEXT,
            mag TEXT,
            part_number TEXT,
            question TEXT,
            answer TEXT,
            question_scenario TEXT,
            answer_source TEXT,
            question_complexity TEXT,
            question_frequency TEXT,
            question_category TEXT,
            source_category TEXT,
            hallucination_control INTEGER,
            quality INTEGER,
            professionalism INTEGER,
            usefulness INTEGER,
            average_score INTEGER,
            summary TEXT,
            llm_answer TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    `);
});

// API路由
app.post('/api/save-evaluation', (req, res) => {
    try {
        const evaluationData = req.body;
        console.log('接收到评估数据:', JSON.stringify(evaluationData).substring(0, 200) + '...');

        let savedCount = 0;
        const results = [];

        // 遍历所有评估结果
        for (const key in evaluationData) {
            if (key.startsWith('result')) {
                const result = evaluationData[key];
                console.log(`处理结果: ${key}`);

                // 准备SQL语句
                const sql = `
                    INSERT INTO evaluation_results (
                        cas_name, product_family, mag, part_number, question, answer,
                        question_scenario, answer_source, question_complexity, question_frequency,
                        question_category, source_category, hallucination_control, quality,
                        professionalism, usefulness, average_score, summary, llm_answer
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                `;

                // 准备数据
                const params = [
                    result['CAS Name'] || '',
                    result['Product Family'] || '',
                    result['MAG'] || '',
                    result['Part Number'] || '',
                    result['Question'] || '',
                    result['Answer'] || '',
                    result['Question Scenario'] || '',
                    result['Answer Source'] || '',
                    result['Question Complexity'] || '',
                    result['Question Frequency'] || '',
                    result['Question Category'] || '',
                    result['Source Category'] || '',
                    result['hallucination_control'] || 0,
                    result['quality'] || 0,
                    result['professionalism'] || 0,
                    result['usefulness'] || 0,
                    result['average_score'] || 0,
                    result['summary'] || '',
                    result['LLM_ANSWER'] || ''
                ];

                // 执行插入操作
                db.run(sql, params, function(err) {
                    if (err) {
                        console.error(`插入数据时出错: ${err.message}`);
                    } else {
                        console.log(`插入数据成功，ID: ${this.lastID}`);
                        results.push({
                            id: this.lastID,
                            key: key
                        });
                    }
                });

                savedCount++;
            }
        }

        // 返回成功响应
        res.json({
            success: true,
            message: `成功保存了 ${savedCount} 条评估结果`,
            saved_count: savedCount,
            results: results
        });
    } catch (error) {
        console.error('处理评估数据时出错:', error);
        res.status(500).json({
            success: false,
            message: `处理评估数据时出错: ${error.message}`
        });
    }
});

// 获取所有评估结果
app.get('/api/evaluations', (req, res) => {
    db.all('SELECT * FROM evaluation_results ORDER BY created_at DESC', [], (err, rows) => {
        if (err) {
            console.error('查询数据时出错:', err);
            res.status(500).json({
                success: false,
                message: `查询数据时出错: ${err.message}`
            });
            return;
        }

        res.json({
            success: true,
            data: rows
        });
    });
});

// 获取MAG分数统计
app.get('/api/mag-scores', (req, res) => {
    db.all(`
        SELECT
            mag,
            AVG(hallucination_control) as avg_hallucination_control,
            AVG(quality) as avg_quality,
            AVG(professionalism) as avg_professionalism,
            AVG(usefulness) as avg_usefulness,
            AVG(average_score) as avg_score,
            COUNT(*) as count
        FROM evaluation_results
        GROUP BY mag
        ORDER BY avg_score DESC
    `, [], (err, rows) => {
        if (err) {
            console.error('查询MAG分数时出错:', err);
            res.status(500).json({
                success: false,
                message: `查询MAG分数时出错: ${err.message}`
            });
            return;
        }

        res.json({
            success: true,
            data: rows
        });
    });
});

// 获取维度分数统计
app.get('/api/dimension-scores', (req, res) => {
    db.all(`
        SELECT
            AVG(hallucination_control) as hallucination_control,
            AVG(quality) as quality,
            AVG(professionalism) as professionalism,
            AVG(usefulness) as usefulness,
            AVG(average_score) as average_score,
            COUNT(*) as count
        FROM evaluation_results
    `, [], (err, rows) => {
        if (err) {
            console.error('查询维度分数时出错:', err);
            res.status(500).json({
                success: false,
                message: `查询维度分数时出错: ${err.message}`
            });
            return;
        }

        if (rows.length > 0) {
            const dimensions = [
                { name: 'Hallucination Control', score: rows[0].hallucination_control },
                { name: 'Quality', score: rows[0].quality },
                { name: 'Professionalism', score: rows[0].professionalism },
                { name: 'Usefulness', score: rows[0].usefulness }
            ];

            res.json({
                success: true,
                data: dimensions,
                average_score: rows[0].average_score,
                count: rows[0].count
            });
        } else {
            res.json({
                success: true,
                data: [],
                average_score: 0,
                count: 0
            });
        }
    });
});

// 启动服务器
app.listen(port, '10.193.21.115', () => {
    console.log(`评估后端服务运行在 http://10.193.21.115:${port}`);
});
