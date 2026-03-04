````md
# PRD：macOS 终端侧边快捷助手（iTerm2/Terminal Snippet Helper）

## 1. 背景与问题
很多 CLI 工具把终端当作 AI 聊天窗，界面大、流程重，反而打断开发者心流。我们要做的是一个**极轻量**、**不依赖 AI** 的“快捷查询/命令片段助手”。

### 现有痛点
1) 命令行操作复杂、参数多、需要记忆  
2) 文档/文件打开依赖路径输入，不可视化  
3) 粘贴图片/参考内容不能一键完成（本版本可暂不做或弱化）

### 核心定位
一个贴在终端旁边（或快捷键呼出）的 macOS 面板，提供：
- **一键复制**命令到剪贴板（默认）
- **可选一键执行**：把命令发送到当前 iTerm2 / Terminal 会话执行（用户可关闭）

> 关键原则：**不做 AI**、不做复杂自动化，只做“片段库 + 快捷触发”。

---

## 2. 目标与非目标

### 2.1 产品目标（Goals）
- G1：用户能在 1-2 秒内通过面板找到常用命令并复制到剪贴板
- G2：在 iTerm2 上可稳定将命令写入当前 session（可选直接执行）
- G3：同一套片段库，兼容 iTerm2 与 macOS Terminal.app
- G4：片段库可由用户本地编辑（JSON/YAML），支持导入导出

### 2.2 非目标（Non-goals）
- NG1：不做 AI 对话、不做自然语言解析生成命令
- NG2：不做复杂文件可视化浏览器（可在后续版本扩展）
- NG3：不做命令输出采集/解析、不接管终端历史
- NG4：不做云同步/账户体系（MVP 仅本地）

---

## 3. 用户与使用场景

### 3.1 目标用户
- macOS 上使用 iTerm2/Terminal 的开发者、运维、数据工程师、游戏开发者等

### 3.2 典型场景（Jobs To Be Done）
- “我想快速查一个常用命令，不想翻笔记/文档”
- “我经常输入同一串 docker/git/grep/find 参数，想一键复制”
- “我希望选中一个片段后直接写入 iTerm2 执行，减少粘贴步骤（可选）”

---

## 4. 产品形态与交互

### 4.1 形态（MVP 推荐）
- **快捷键呼出浮窗**（默认）：
  - 快捷键：例如 `⌥Space`（可配置）
  - 浮窗置顶、可拖动、可固定
- 可选：常驻侧边栏模式（后续）

### 4.2 核心页面结构
1) 顶部：
   - 搜索框（支持 title/tags 模糊匹配）
   - 当前目标终端显示（iTerm2 / Terminal / 未识别）
2) 中部：
   - **一级分类：按 CLI 工具分组**（Claude Code / Codex / Gemini CLI / Aider / OpenClaw / OpenCode / GitHub Copilot CLI / 通用）
   - **二级分类：按功能分组**（常用命令 / 配置 / 调试 / 项目管理 / 插件&扩展）
   - 片段条目（Title + tags + 简短描述）
3) 底部：
   - 片段详情（多行命令预览）
   - 按钮：`Copy`（默认显示）、`Run`（可选显示）、`Edit`（打开配置文件/内置编辑）
   - Danger 提示（若片段标记为危险）

### 4.3 关键交互流程

#### 流程 A：复制（默认）
1. 用户快捷键呼出面板
2. 搜索/点击片段
3. 点击 `Copy`
4. 命令写入剪贴板
5. 用户切换到终端粘贴执行

成功标准：复制后提示 “Copied”，并支持再次点击覆盖剪贴板。

#### 流程 B：执行（可选）
前提：用户在设置中开启 “显示 Run 按钮”
1. 用户选择片段
2. 点击 `Run`
3. 若 dangerLevel = danger/caution，弹出确认（可配置是否跳过）
4. 将命令发送到当前终端（iTerm2 或 Terminal）
5. 终端执行（写入文本并回车）

成功标准：在前台终端窗口可见命令被输入并执行。

#### 流程 C：变量替换（MVP 可做）
片段包含变量，如 `{PORT}`、`{KEY}`、`{FILE}`
1. 用户点击片段
2. 系统检测到 variables
3. 弹出小输入框（或在详情区提供输入栏）
4. 替换后生成最终命令
5. Copy/Run 使用替换结果

---

## 5. 功能需求（FRD）

### 5.1 片段库管理
- FR1：内置默认片段库（首次启动生成/拷贝到用户目录）
- FR2：从本地文件加载片段（JSON 或 YAML，MVP 先 JSON）
- FR3：支持导入/导出（将 JSON 文件复制到指定路径即可，UI 可简化为“打开片段目录”）
- FR4：支持启用/禁用某条片段（字段 enabled）

### 5.2 搜索与分类
- FR5：搜索支持 title / tags / description（模糊）
- FR6：支持**两级分类**：一级按 CLI 工具（Claude Code / Codex / Gemini CLI / Aider / OpenClaw / OpenCode / GitHub Copilot CLI / 通用），二级按功能（常用命令 / 配置 / 调试 / 项目管理 / 插件&扩展）
- FR7：最近使用（可选，MVP 可做简单 LRU 10 条）

### 5.3 Copy（必须）
- FR8：一键 Copy 将最终命令写入 macOS 剪贴板
- FR9：Copy 后显示 toast/状态提示
- FR10：支持多行命令完整复制

### 5.4 Run（可选但建议）
- FR11：支持 iTerm2：将命令写入当前窗口当前 session 并执行
- FR12：支持 Terminal.app：将命令写入前台窗口 selected tab 并执行
- FR13：Run 支持多行命令（逐行写入）
- FR14：Run 支持危险提示确认（按 dangerLevel）

### 5.5 设置（MVP 最少）
- FR15：快捷键配置（或固定一个默认键）
- FR16：Run 按钮开关（默认关闭）
- FR17：危险命令确认开关（默认开启）
- FR18：片段目录入口（打开 Finder 显示配置文件路径）

---

## 6. 非功能需求（NFR）

### 6.1 性能
- NFR1：面板呼出 < 200ms 主观感受（冷启动可放宽）
- NFR2：搜索过滤 < 50ms（片段数 < 2000 仍流畅）

### 6.2 稳定性与兼容
- NFR3：macOS 13+（可调整目标版本）
- NFR4：iTerm2 最新稳定版为主（AppleScript API 兼容）
- NFR5：Terminal.app 原生支持

### 6.3 安全与权限
- NFR6：Run 功能需要 macOS “自动化控制”授权（控制 iTerm2/Terminal）
- NFR7：不得在未经用户操作下自动执行任何命令（无后台自动化）
- NFR8：不上传用户命令/片段（本地工具）

---

## 7. 片段数据结构（建议 JSON Schema）

### 7.1 文件路径
- 默认：`~/Library/Application Support/TermSnippetHelper/snippets.json`
- 首次启动：若不存在则写入内置默认模板

### 7.2 JSON 结构（示例）
```json
{
  "version": 2,
  "snippets": [
    {
      "id": "claude_start",
      "title": "启动 Claude Code",
      "description": "在当前目录启动 Claude Code 对话",
      "tool": "Claude Code",
      "category": "常用命令",
      "tags": ["claude", "start", "chat"],
      "command": "claude",
      "variables": null,
      "dangerLevel": "safe",
      "enabled": true
    },
    {
      "id": "port_lsof",
      "title": "查看端口占用",
      "description": "lsof 查询端口占用进程",
      "tool": "通用",
      "category": "调试",
      "tags": ["port", "lsof", "debug"],
      "command": "lsof -i :{PORT}",
      "variables": [
        { "key": "PORT", "label": "端口号", "default": "3000" }
      ],
      "dangerLevel": "safe",
      "enabled": true
    }
  ]
}
```

### 7.3 字段说明

* id：唯一标识
* title：按钮显示
* description：列表副标题
* **tool**：所属 CLI 工具（一级分类）— `Claude Code | Codex | Gemini CLI | Aider | OpenClaw | OpenCode | GitHub Copilot CLI | 通用`
* **category**：功能分类（二级分类）— `常用命令 | 配置 | 调试 | 项目管理 | 插件&扩展`
* tags：搜索关键词
* command：支持多行（`\n`）
* variables：变量列表（MVP 可支持 string 输入）
* dangerLevel：`safe | caution | danger`
* enabled：是否显示

---

## 8. iTerm2 / Terminal 执行方案（实现要求）

### 8.1 iTerm2（AppleScript）

需求：写入“当前窗口当前 session”

* 使用 `write text` 发送命令
* 多行：分行循环 write
* 必须处理字符串转义（双引号、反斜杠）

执行成功标准：

* iTerm2 前台窗口可见命令被输入
* 命令自动回车执行（write text 行为）

### 8.2 Terminal.app（AppleScript）

* `do script "..."`
* 在 `front window` 的 `selected tab` 执行

### 8.3 前台终端识别策略

* 读取当前 active application bundle id/name
* 若为 iTerm2 → iTerm2 脚本；若为 Terminal → Terminal 脚本；否则：

  * Run 按钮置灰/提示“未识别终端”
  * Copy 仍可用

---

## 9. 危险命令策略（MVP 简化规则）

### 9.1 dangerLevel 的来源

* 优先：片段作者在 JSON 中显式标注
* 可选自动检测（后续）：命令包含以下关键字之一则建议提升等级：

  * danger：`rm -rf`, `sudo`, `dd`, `mkfs`, `:(){ :|:& };:`, `> /dev/`
  * caution：`kill -9`, `chmod -R`, `chown -R`, `git reset --hard`, `docker system prune`

> MVP 建议：只用显式标注 + 简单关键字提醒即可。

### 9.2 确认弹窗

* danger：默认必须确认
* caution：默认确认（可在设置关闭）
* safe：不弹窗

---

## 10. 边界情况与错误处理

* E1：iTerm2 未运行 → 点击 Run 时自动 activate 并尝试执行；失败则提示
* E2：无窗口/无 session → 提示“未找到可用 session”，建议用户打开一个 tab
* E3：用户未授权自动化权限 → 提示引导到系统设置开启
* E4：命令包含复杂引号导致脚本失败 → 提示“转义失败”，建议使用 Copy 或简化命令；记录日志便于排查
* E5：多屏/多终端窗口切换 → 以“前台应用 + 当前窗口”为准（不做后台跟踪）

---

## 11. 里程碑与开发计划（MVP）

### M0：项目骨架（0.5 天）

* SwiftUI App + 浮窗/Panel
* 全局快捷键呼出（先固定一个快捷键也可）

### M1：片段加载与展示（1 天）

* 读取 snippets.json
* 列表/分类/搜索
* 片段详情展示

### M2：Copy（0.5 天）

* NSPasteboard 写入
* Toast 提示

### M3：Run iTerm2（1 天）

* AppleScript 调用 iTerm2 write text
* 多行支持
* 权限失败提示

### M4：Run Terminal（0.5 天）

* AppleScript do script
* 基础兼容

### M5：变量替换（1 天）

* 解析 `{VAR}`
* UI 输入框
* 替换生成最终命令

### M6：设置与打磨（1 天）

* Run 开关、确认开关
* 打开片段目录按钮
* 最近使用（可选）

> MVP 总计：约 5~6 天净开发（视你熟练度调整）

---

## 12. 验收标准（Acceptance Criteria）

### Copy

* AC1：点击 Copy 后剪贴板内容与 command 完全一致（含换行）
* AC2：搜索/分类不影响 Copy 正确性

### Run - iTerm2

* AC3：iTerm2 前台时，点击 Run 命令会进入当前 session 并执行
* AC4：多行命令可按行执行（顺序正确）
* AC5：无权限时有明确提示与引导

### Run - Terminal

* AC6：Terminal 前台时，点击 Run 命令在当前 tab 执行
* AC7：不识别终端时 Run 不可用，但 Copy 正常

### 变量

* AC8：带 `{PORT}` 的片段在输入 3000 后生成正确命令
* AC9：变量为空时提示或使用默认值

---

## 13. 指标与埋点（本地即可，不上报也可）

* 使用频次：每天 Copy 次数、Run 次数
* 搜索使用率：是否更偏向搜索还是分类点击
* 失败率：Run 失败原因（无权限/无窗口/脚本错误）

> 若不做埋点，可仅本地日志文件，供用户自查。

---

## 14. 风险与对策

* R1：AppleScript 转义复杂导致 Run 不稳定

  * 对策：MVP 允许“复杂命令用 Copy”；Run 先支持常规命令；逐步完善转义
* R2：自动化权限影响体验

  * 对策：Run 默认关闭；提供“连接测试”引导一次授权
* R3：不同 iTerm2 版本脚本接口差异

  * 对策：锁定当前稳定 API（write text），回退 Copy

---

## 15. 附录：内置片段库

### 15.1 分类架构

**一级分类（按 CLI 工具）：**

| 工具 | 说明 |
|------|------|
| Claude Code | Anthropic 官方 AI 编程 CLI |
| Codex CLI | OpenAI 官方终端编程工具 |
| Gemini CLI | Google Gemini 终端版 |
| Aider | 开源 AI 结对编程 CLI，支持 100+ 模型 |
| OpenClaw | 257K Star 开源编程代理 |
| OpenCode | 95K Star 开源编程代理，75+ 模型供应商 |
| GitHub Copilot CLI | GitHub/Microsoft 的 CLI AI 工具 |
| 通用 | 不绑定特定 CLI 工具的通用命令（Git / Docker / Debug 等） |

**二级分类（按功能）：**
- 常用命令：日常高频操作
- 配置：安装、初始化、环境设置
- 调试：排查问题、日志查看
- 项目管理：文件操作、Git 工作流
- 插件&扩展：MCP、skill、自定义工具

### 15.2 各工具内置片段（待研究补充）

> 下一步开发时，需研究每个 CLI 工具的常用命令，为每个工具预置 5-10 条高频片段。

#### 通用（保留原有）

* 查看端口占用：`lsof -i :{PORT}`
* 杀掉端口进程：`kill -9 $(lsof -t -i :{PORT})`
* tail 日志：`tail -f {FILE}`
* 全文搜索：`rg "{KEY}" -n`
* 查找文件：`find . -name "{NAME}"`
* Git 状态：`git status -sb`
* Git 清理远端已删分支：`git fetch -p`
* Git 重置（谨慎）：`git reset --hard HEAD~1`（danger）
* Docker 容器列表：`docker ps -a`
* Docker 清理（谨慎）：`docker system prune`（caution）

#### Claude Code（示例）

* 启动对话：`claude`
* 带提示启动：`claude "帮我review这段代码"`
* 恢复上次对话：`claude --continue`
* 非交互模式：`claude -p "解释这个函数"`
* 查看配置：`claude config list`

#### Codex CLI（示例）

* 启动：`codex`
* 安静模式：`codex --quiet`
* 全自主模式：`codex --full-auto`

#### Gemini CLI（示例）

* 启动：`gemini`
* 查看模型：`gemini models`

#### Aider（示例）

* 启动：`aider`
* 指定模型：`aider --model claude-3.5-sonnet`
* 添加文件：`aider --file src/main.py`

#### OpenClaw（示例）

* 启动：`openclaw`

#### OpenCode（示例）

* 启动：`opencode`

#### GitHub Copilot CLI（示例）

* 解释命令：`gh copilot explain "{CMD}"`
* 建议命令：`gh copilot suggest "{DESC}"`

---

## 16. 开始制作的最小切入点（给开发者）

1. 先做 SwiftUI 面板 + 列表展示
2. 实现 Copy（剪贴板）
3. 加入 iTerm2 Run（AppleScript write text）
4. 再补 Terminal Run
5. 最后加变量替换与设置项

```

如果你下一步希望“让 CLI 里的 AI 看了就能开工”，我还可以再补一份更偏工程的 **Technical Spec**（模块划分、类/文件结构、关键函数签名、转义策略、AppleScript 模板），同样用 md 给你。
```
