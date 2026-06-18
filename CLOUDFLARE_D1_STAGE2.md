# 第二阶段：Cloudflare Worker + D1 云端保存

这一阶段的目标是让线上网站不只在前端生成报告，还能把用户的测算记录保存到 Cloudflare D1 数据库，后续再继续接用户中心、会员次数、订单和后台管理。

## 当前代码已经完成

- `worker/index.mjs`：线上 Worker API。
- `schema.sql`：D1 数据库建表脚本。
- `wrangler.jsonc`：已加入 Worker 入口，D1 绑定块暂时保留为注释。
- `src/utils/api.js`：线上默认请求同域 `/api`，不再写死本机地址。

## 创建 D1 数据库

1. 打开 Cloudflare Dashboard。
2. 进入 `Workers & Pages`。
3. 找到左侧 `D1 SQL Database` 或 `D1`。
4. 点击 `Create database`。
5. 数据库名称建议填写：

```text
xuanxue
```

6. 创建后复制页面里的 `database_id`。

## 初始化数据表

进入刚创建的 D1 数据库，打开 `Console`，粘贴并执行 `schema.sql` 的内容：

```sql
CREATE TABLE IF NOT EXISTS reports (
  id TEXT PRIMARY KEY,
  created_at TEXT NOT NULL,
  method_id TEXT,
  method_name TEXT,
  question TEXT NOT NULL,
  concern_type TEXT,
  report_json TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_reports_created_at
ON reports(created_at DESC);
```

## 打开 D1 绑定

编辑 `wrangler.jsonc`，把注释掉的 `d1_databases` 打开，并把 `database_id` 换成真实 ID：

```jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "xx",
  "compatibility_date": "2026-06-18",
  "main": "./worker/index.mjs",
  "assets": {
    "directory": "./dist",
    "not_found_handling": "single-page-application"
  },
  "d1_databases": [
    {
      "binding": "DB",
      "database_name": "xuanxue",
      "database_id": "这里换成你的真实 database_id"
    }
  ]
}
```

## 重新上传 GitHub 并部署

Cloudflare 当前项目使用 GitHub 自动部署，所以更新 GitHub 后点击 `Retry build` 或等待自动部署即可。

部署成功后检查：

```text
https://你的域名/api/health
```

如果返回：

```json
{
  "ok": true,
  "service": "xuanxue-worker-api",
  "storage": "d1"
}
```

说明云端 API 与 D1 绑定成功。

## 用户侧验证

1. 打开网站。
2. 进入免费体验。
3. 填写问题并生成报告。
4. 页面提示应变成已连接后端/可保存历史。
5. 下方历史报告区域应出现刚才生成的记录。

## 下一阶段建议

- 用户登录与会员身份。
- 测算次数余额。
- 订单与支付。
- 管理员后台查看报告记录。
- 报告详情页和可分享链接。
- 敏感内容审核与高风险问题拦截。

