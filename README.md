# Obsidian Knowledge Base · 第二大脑知识库搭建技能

一套可复用的 Obsidian 团队知识库搭建方案，含目录结构、维护规则、项目索引层、初始化脚本。

## 特性

- 🧠 **第二大脑**：任务产出回流为可复用知识，只存元信息不复制原文件
- 📋 **项目索引层**：所有项目一张索引卡，按状态分层管理
- 🔄 **Git 同步协议**：多 Agent 安全读写，冲突不自动 merge
- ⚡ **一键初始化**：PowerShell 脚本自动生成目录结构与模板

## 快速开始

### 方式一：使用初始化脚本（推荐）

```powershell
git clone https://github.com/<你的用户名>/obsidian-knowledge-base.git
cd obsidian-knowledge-base
.\scripts\init-vault.ps1 -VaultPath "D:\你的Vault路径"
```

### 方式二：手动搭建

1. 复制 `templates/` 下所有文件到你的 Vault 目录
2. 复制 `obsidian-config/` 下的配置到 Vault 的 `.obsidian/` 目录
3. 用 Obsidian 打开该目录作为仓库
4. 按需修改 `00-Vault入口.md` 和各模板中的团队信息

## 目录结构

```
obsidian-knowledge-base/
├── SKILL.md                    # 技能主文档（使用说明）
├── README.md                   # 本文件
├── templates/                  # Vault 文档模板
│   ├── 00-Vault入口.md
│   └── 03-知识库/
│       ├── README.md           # 知识库维护手册
│       ├── 00-索引.md          # MOC 按场景导航
│       ├── 00-模板/
│       │   ├── 知识卡片模板.md
│       │   └── 项目索引卡模板.md
│       └── 06-项目索引/
│           ├── README.md       # 项目索引维护规则
│           └── 00-项目总览.md
├── obsidian-config/            # Obsidian 配置文件
│   ├── app.json
│   ├── appearance.json
│   ├── core-plugins.json
│   └── templates.json
└── scripts/
    └── init-vault.ps1          # 一键初始化脚本
```

## 核心设计

1. **知识回流 = 元信息**：原文件留在任务目录，知识库只存提炼后的方法/结论 + 链接
2. **索引卡只存元信息**：项目索引卡记录路径、状态、负责人、关键文档链接
3. **审核三门槛**：可复用性、可验证性、简洁性（≤300 字）
4. **Git 同步**：`pull --rebase` → 读写 → `push`，冲突另存 `.conflict`

## 标签体系

`#内容/` `#技术/` `#设计/` `#流程/` `#决策/` `#踩坑/` `#项目/`

## License

MIT
