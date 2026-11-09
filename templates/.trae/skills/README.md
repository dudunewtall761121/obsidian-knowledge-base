# Vault 技能索引

> 本目录存放随 Vault 同步的 TRAE 技能。新设备 clone 本仓库后，TRAE 可自动识别并调用。

## 可用技能

### 自建技能

| 技能 | 说明 | 触发场景 |
|---|---|---|
| [obsidian-knowledge-base](./obsidian-knowledge-base/SKILL.md) | 搭建 Obsidian 第二大脑知识库 + 项目索引层 | 搭建团队知识库、Obsidian vault、第二大脑、项目索引 |

### 沉淀的常用技能

| 技能 | 说明 | 触发场景 |
|---|---|---|
| [research-guide](./research-guide/SKILL.md) | 深度研究与分析 | 研究报告、竞品分析、深度检索 |
| [frontend-design-templates](./frontend-design-templates/SKILL.md) | 前端设计风格模板 | 落地页、官网、作品集、设计风格 |
| [prototype-craft](./prototype-craft/SKILL.md) | 产品原型快速开发 | 高保真原型、Demo、原型迭代 |
| [uicraft](./uicraft/SKILL.md) | 网页界面设计开发 | 界面设计、前端美化、响应式 |
| [visual-image-generator](./visual-image-generator/SKILL.md) | 视觉图像生成 | 海报、封面、电商图、信息图 |
| [solo-graphic-generation](./solo-graphic-generation/SKILL.md) | 位图视觉素材生成 | 海报、Banner、KV、插画 |

### 系统内置技能（无需复制）

以下技能为 TRAE 系统内置，新设备安装后自动可用，无需随 Vault 同步：

- `last30days` — 近 30 天话题热度分析
- `design-taste-frontend` — 前端设计审美
- `high-end-visual-design` — 高端视觉设计

## 技能目录结构

```
.trae/skills/
└── <技能名>/
    ├── SKILL.md            # 技能主文档（必须）
    ├── scripts/            # 脚本
    ├── templates/          # 模板文件
    └── obsidian-config/    # Obsidian 配置
```

## 新增技能

1. 在 `.trae/skills/` 下创建 `<技能名>/` 目录
2. 编写 `SKILL.md`（含 `name` 和 `description` frontmatter，description 需包含触发条件）
3. 在本索引文件中登记
