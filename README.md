# EasySkillHub 1.0（ESKH）· 资源站模式的 SkillHub

> **一句话**：一个和 [skillhub.openeuler.org](https://skillhub.openeuler.org) 同构的 Skill 资源站 ——
> **浏览、编辑、贡献、分发、静态风险评估**五件事都能在页面上完成，**不依赖任何外部网络**。

| 项 | 值 |
| --- | --- |
| 产品全名 | **EasySkillHub** |
| 版本 | **1.0** |
| 缩写 | **ESKH** |
| 端口 | **30800** |
| 定位 | 资源站模式（对标 openEuler SkillHub / GitHub） |
| 软件开发方法 | 原型开发 |
| 目标客户 | 中小型信息企业、需求较低的 Skill 管理与开发企业 |
| 运行期外部依赖 | **无**（断网全功能可用） |
| 数据库 | H2 2.2.x（默认，零安装）/ MySQL 8（`SKHUB_DB=mysql`） |

## 30 秒跑起来

```cmd
cd NS-EasySkillHub
start.cmd
```

`start.cmd` 会自动：检查 JDK 17 / 端口 → 缺产物就构建 → 用正确的 JVM 参数启动 →
轮询 `/api/v1/health` → 打开 <http://127.0.0.1:30800>。
首次启动会自动建表并导入 **375 个 Skill**（约 10 秒）。

停止：`stop.cmd`。换端口：`start.cmd 30810`。

## 这个版本做什么

| 能力 | 在哪 | 说明 |
| --- | --- | --- |
| Skill 库浏览 | 「Skill 库」 | 375 个 Skill，15 个分类 / 6 个行业场景 / 5 档风险等级，条件查询 + 4 种排序 + 格子/列表双视图 |
| 详情 | 详情页 | 完整 SKILL.md、版本历史、附件清单、风险评估报告、源码直链 |
| 编辑 | 详情页「编辑」 | 名称/标题/简介/分类/标签/版本/许可/源码直链/正文；自动追加版本快照并重扫风险 |
| 删除 | 详情页「归档」 | 默认软删（可恢复）；物理删除需管理员 |
| 贡献 | 「在线贡献」 | 个人 / 部门两种身份，四步向导：上传 → 签 CLA → 提交 → 评估发布 |
| 分发 | 详情页「安装」 | 下载 ZIP / 复制命令 / 源码直链（GitHub / Gitee / GitLab） |
| 风险评估 | 「安全评估」 | 6 维度 32 指标、0-100 分、四档等级；在线试算 + 每 Skill 报告 |
| 在线文档 | 「在线文档」 | 6 篇站点指南，由 Markdown 驱动 |

## 这个版本**不**做什么（能力边界）

- ❌ **不发起任何外部网络调用** —— 这是 ESKH 的核心承诺，也是它的性能与可靠性来源
- ❌ 没有库语义（索引 / 约束 / 事件 / 事务）—— 属于标准版 SSKH
- ❌ 没有在线实测（不连 Agent / MCP / 大模型）—— 属于标准版 SSKH
- ❌ 没有知识级分析（知识图谱 / 统计检验）—— 属于专业版 PSKH
- ❌ 不做登录鉴权 —— 用轻量身份头 `X-SKH-Actor` / `X-SKH-Role`
- ❌ 不做 Docker / 镜像 / 部署交付

需要上面这些时请换版本：`NS-StanSkillHub`（30801）、`NS-ProSkillHub`（30802）。
三个版本界面与操作习惯一致，**Skill 库是同一个**（逐字节相同）。

## 目录结构

```
NS-EasySkillHub/
├─ start.cmd / stop.cmd              一键启动 / 停止（ASCII-only，中文提示在 ps1 里）
├─ scripts/
│   ├─ start.ps1                     启动（含构建、健康轮询、开浏览器）
│   ├─ stop.ps1                      按端口停（netstat 定位，只杀 java）
│   ├─ build.ps1                     构建后端 + 前端
│   ├─ verify.ps1                    一键验收（接口 29 项 + 页面 11 项 ×7 路由）
│   └─ db-check.ps1                  在 MySQL 上跑一遍建表与导入
├─ backend/                          Spring Boot 单体（五层分包）
│   ├─ pom.xml
│   └─ src/main/
│       ├─ java/org/skillhub/         common / config / action / business / port / adapter / mapper / model / dto / support
│       └─ resources/
│           ├─ application.yml
│           ├─ db/schema.sql          可移植 DDL（H2 与 MySQL 8 共一份）
│           ├─ risk/indicators.json   6 维度 / 32 指标字典
│           ├─ docs/*.md              在线文档（6 篇）
│           └─ static/                前端构建产物（由 build.mjs 写入）
├─ frontend/                         Vue 3 + Rollup（零 UI 组件库）
│   ├─ src/{views,components,layout,api,router,store,styles,utils}
│   ├─ build.mjs                      构建脚本（Rollup，不用 Vite/esbuild）
│   └─ test/smoke.mjs                 jsdom 页面级冒烟测试
├─ skills/                           375 个 Skill（与另两个工程逐字节一致）
├─ config/                           （本版本不发起外部调用，用不到证书；副本里也带了一份 config/certs/ 以便统一）
├─ data/                             运行时数据：db/（H2 文件库）、uploads/（贡献上传）
├─ logs/                             启动日志（UTF-8）
├─ docs/                             本工程的规划与设计文档（5 篇）
└─ legacy/                           历史工程归档（仅作参考，不参与构建）
```

## 验收

```powershell
# 接口 29 项 + 页面 11 项（需要服务已启动）
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1

# 只跑接口
node scripts\api-test.mjs

# 只跑页面（jsdom）
cd frontend; node test\smoke.mjs --route /skills

# MySQL 双跑
powershell -ExecutionPolicy Bypass -File scripts\db-check.ps1 -DbPort 3307
```

当前状态：接口 **29/29 通过**，页面 **11×7 路由全通过**，H2 与 MySQL 8 双向验证通过。

## 文档

| 文档 | 内容 |
| --- | --- |
| [docs/01-需求与定位.md](docs/01-需求与定位.md) | 需求、用户、场景、原型迭代记录 |
| [docs/02-系统设计.md](docs/02-系统设计.md) | 五层架构、模块清单、关键时序 |
| [docs/03-数据与接口.md](docs/03-数据与接口.md) | 11 张表、接口清单、错误码 |
| [docs/04-业务规则与算法.md](docs/04-业务规则与算法.md) | 贡献状态机、风险评分、检索打分、skill_id 规则 |
| [docs/05-测试与验收.md](docs/05-测试与验收.md) | 用例矩阵、验收脚本、已知限制 |

仓库级共享基线（三系统共同遵守）：[../docs/00](../docs/00-三系统总纲与递进设计.md) 起 8 篇。

## 已知限制（诚实清单）

1. **不做登录**：身份靠请求头，任何能访问页面的人都能切换成 admin。生产需接 SSO。
2. **检索是关键词加权**，不是向量检索；中文分词未做（依赖子串匹配）。
3. **风险评估是静态规则**：不运行 Skill、不联网、不调模型。漏检是必然的。
4. **版本无 diff 视图**：只保存快照，未做版本间逐行对比。
5. **无速率限制**：登录失败锁定、幂等有，但限流建议由网关承担。
6. **贡献无审核队列**：`submitted → published` 由同一人完成（内网工具场景的取舍）。
7. **ZIP 下载包含库里的全部附件**，若某 Skill 目录很大则下载也大。
