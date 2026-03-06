# TermKit PRD v2：⌘ 长按分层菜单（Cmd Hold Menu）

## 0. 一句话定位
TermKit 是一个 macOS 常驻后台的“命令入口”。用户**长按 ⌘** 呼出分层菜单，选择“文件夹 / CLI / 动作”，**松开 ⌘** 即把生成的命令粘贴到终端光标处（不自动回车），并**还原剪贴板**。

---

## 1. 背景与问题
开发者日常反复做三类事：
1) 切到某个项目目录（`cd`）
2) 启动或继续某个 CLI（Claude Code / Codex / Gemini / Aider / OpenCode…）
3) 把素材（尤其图片）落盘后，把路径交给 CLI 读取

传统快捷面板/片段库需要“呼出 → 搜索 → 点击”，且会覆盖剪贴板；你希望把交互变成更轻、更快的“按住 ⌘ 就选，松开 ⌘ 就粘贴”。

---

## 2. 目标（Goals）
- G1：长按 ⌘ 后 0~1 秒完成“选文件夹 → cd → 执行 CLI 动作（Start/Continue/Resume/自定义）”。
- G2：支持鼠标点选、方向键 `↑↓←→`、数字键 `1..9/0` 快速选择、`~`/`` ` `` 返回。
- G3：松开 ⌘ 即确认并粘贴；不自动回车。
- G4：粘贴后恢复用户原剪贴板内容（尽量保持所有类型）。
- G5：文件夹/CLI/动作可在 UI 里配置：可添加/编辑/删除/排序；默认内置一套主流 CLI 模板。
- G6：提供一级菜单“粘贴图片”：把剪贴板图片保存到固定目录并粘贴该路径。
- G7：不干扰系统快捷键：用户正常使用 `⌘C/⌘V/⌘Tab/⌘1...` 不应误触发菜单。

## 3. 非目标（Non-goals）
- NG1：不自动执行（不模拟回车）。
- NG2：不做“解析各 CLI 的历史会话列表并在菜单里精确选择某条会话”；仅调用 CLI 自带的 continue/resume（如支持）。
- NG3：不做图片上传/图片理解；仅做“落盘 + 粘贴路径”。
- NG4：不做云同步/账号体系（先本地）。

---

## 4. 核心交互（Interaction）

### 4.1 触发：长按 ⌘
- 用户开启“⌘ 长按菜单模式”后生效。
- 用户按下并持续按住 ⌘ 超过阈值 `T`（默认 300ms）→ 弹出菜单。
- 仅当 ⌘ 为“单独按住”时触发：若期间出现其他按键或其他修饰键参与（如 `⌘C/⌘Tab/⌘Shift`），则不触发或立刻取消。

### 4.2 导航
- 鼠标：点击进入下一层；叶子节点点击仅高亮，等待松开 ⌘ 确认。
- 键盘：
  - `↑/↓`：移动高亮
  - `→`：进入下一层（或确认进入）
  - `←`：返回上一层
  - `Esc`：取消关闭（不粘贴）
  - `1..9`：选择当前层第 1..9 个选项；若该项可展开则自动进入下一层
  - `0`：选择当前层第 10 个选项（如存在）；同上
  - `~` 或 `` ` ``：返回上一层（同 `←`）

### 4.3 确认：松开 ⌘
- 若菜单可见：松开 ⌘ 视为“确认当前高亮路径”，触发动作：
  - 生成最终命令/文本
  - 临时写入剪贴板
  - 切回用户原前台应用
  - 模拟一次 `⌘V` 粘贴
  - 延迟 `D`（默认 200ms）后还原剪贴板
  - 关闭菜单

例外（不走粘贴）：
- 若高亮项是“添加文件夹… / 添加 CLI… / 添加动作…”：松开 ⌘ 打开对应配置表单。

---

## 5. 一级菜单结构（MVP）

1) 打开文件夹
2) 选择启动 CLI
3) 粘贴图片

菜单顶部显示面包屑与命令预览（只读）：
- 面包屑例：`打开文件夹 › MyProject › Claude Code › Resume`
- 命令预览例：`cd '/path' && claude --resume`

---

## 6. “打开文件夹”菜单

### 6.1 列表
展示用户维护的文件夹列表（可排序/删除），每一项代表一个目录。

列表末尾固定存在：
- `添加文件夹…`

### 6.2 选择效果
- 选中某个文件夹并进入下一层（`→` 或点击）：进入“选择启动 CLI”（带上下文 `DIR`）。
- 若用户在该层松开 ⌘（未进入下一层），默认动作是：粘贴 `cd '<DIR>'`。

### 6.3 添加文件夹（松开 ⌘ 弹表单）
表单字段：
- 文件夹路径（支持 `~` 展开）

校验：
- 路径存在
- 为目录

保存后：
- 立刻出现在“打开文件夹”的列表中

---

## 7. “选择启动 CLI”菜单

### 7.1 CLI 列表
展示用户维护的 CLI 列表（可排序/删除/编辑）。

列表末尾固定存在：
- `添加 CLI…`

### 7.2 进入 CLI 的动作层
选中某个 CLI 并进入下一层 → 展示该 CLI 的动作列表。

动作列表由该 CLI 的配置决定：
- `仅 cd`（通用）
- `Start`（如配置了 Start 模板则显示）
- `Continue`（如配置了 Continue 模板则显示）
- `Resume`（如配置了 Resume 模板则显示）
- 自定义动作（用户添加）

动作列表末尾固定存在：
- `添加动作…`

### 7.3 命令生成（统一规则）
最终命令统一用：
- 有目录：`cd '<DIR>' && <ACTION_COMMAND>`
- 无目录：`<ACTION_COMMAND>`

目录必须做 shell 安全引用（单引号优先）。

---

## 8. “粘贴图片”菜单

### 8.1 行为
用户在一级菜单高亮“粘贴图片”并松开 ⌘：
1) 检测剪贴板是否包含图片
2) 写入固定目录：`~/Library/Application Support/TermKit/Images/`
3) 文件名默认：`termkit-YYYYMMDD-HHMMSS.png`
4) 将该图片文件路径粘贴到终端光标处（走同一套“临时覆盖剪贴板 + ⌘V + 还原”流程）

### 8.2 失败提示
- 剪贴板无图片：提示“剪贴板没有图片”
- 写文件失败：提示失败原因
- 没有辅助功能权限：提示如何授权

---

## 9. 配置（Settings / Config）

### 9.1 配置入口
设置页需要提供清晰入口：
- 文件夹管理
- CLI 管理
- 图片落盘目录（可选：先固定，不做 UI）
- ⌘ 长按阈值 `T` 与剪贴板恢复延迟 `D`

### 9.2 CLI 配置数据模型（MVP）
每个 CLI 至少包含：
- `name`：展示名（如 Claude Code）
- `startCommand`（可选）
- `continueCommand`（可选）
- `resumeCommand`（可选）
- `customActions[]`（可选）：每项包含 `title` + `command`

规则：
- 某动作模板为空 → 菜单里隐藏该动作
- “Resume”默认只在配置了 `resumeCommand` 的 CLI 上出现

### 9.3 默认内置 CLI（可编辑）
MVP 内置一套默认模板，用户可在 UI 中覆盖/删改：
- Claude Code（参考：`claude`, `claude --continue/-c`, `claude --resume`；文档：https://docs.claude.com/en/docs/claude-code/cli-reference）
- OpenAI Codex（偏交互：`codex`；部分模式/审批可作为自定义动作；文档：https://help.openai.com/en/articles/11096431-openai-codex-cli-getting-started）
- Gemini CLI（交互：`gemini`；headless：`gemini -p "<PROMPT>"` 建议作为自定义动作；文档：https://google-gemini.github.io/gemini-cli/）
- Aider（`aider`；恢复历史：`aider --restore-chat-history` 可作为 Continue/Resume；文档：https://aider.chat/docs/config/options.html）
- OpenCode（`opencode`；继续：`opencode --continue/-c`；文档：https://opencode.ai/docs/cli/reference）
- OpenClaw（按其 CLI 文档；可作为自定义动作；文档：https://docs.openclaw.ai/cli/）
- GitHub Copilot CLI（`gh copilot suggest/explain` 需参数，默认不放在“松开 ⌘ 立即粘贴执行链路”；文档：https://docs.github.com/en/copilot/using-github-copilot/using-github-copilot-in-the-command-line）

> 原则：默认值尽量来自官方/主流用法；但最终以“用户可配置”兜底，避免 CLI 版本演进导致 TermKit 不可用。

---

## 10. 权限与系统要求（macOS）
为实现“全局检测 ⌘ 长按 + 模拟 ⌘V”，通常需要：
- Input Monitoring（输入监控）
- Accessibility（辅助功能）

要求：
- 无权限时要给出明确提示，并提供一键跳转到系统设置的路径。
- 无权限时不应产生半截粘贴或异常状态。

---

## 11. 验收标准（Acceptance Criteria）
- AC1：长按 ⌘（单独按住）稳定唤出菜单；松开 ⌘ 确认；`Esc` 取消。
- AC2：鼠标/方向键/数字键/`~`/`` ` `` 导航符合预期。
- AC3：确认后能粘贴到终端当前光标处；不自动回车。
- AC4：粘贴后剪贴板恢复（至少字符串/图片不丢；尽量完整恢复所有 type）。
- AC5：可在 UI 添加文件夹路径，保存后“打开文件夹”可选并生成 `cd` 命令。
- AC6：可在 UI 添加 CLI、添加/编辑动作命令模板；菜单立即生效；空模板动作隐藏。
- AC7：剪贴板有图片时，“粘贴图片”能落盘并粘贴路径；无图片时有提示。
- AC8：用户正常使用系统 `⌘` 快捷键不误触发菜单。

---

## 12. 后续迭代（Roadmap）
- R1：为需要参数的命令提供轻量输入（例如 `gh copilot suggest` 的描述输入框、`gemini -p` 的 prompt 输入框）。
- R2：高级菜单编辑器（任意层级新增子菜单/动态列表节点）。
- R3：从 Finder/终端快速“加入文件夹列表”（右键服务/拖拽）。
