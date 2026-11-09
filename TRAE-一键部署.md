# Obsidian 第二大脑 · 一键部署到新电脑

> 本文档给 TRAE Agent 读取执行。按顺序完成所有步骤即可在新电脑上搭建完整知识库。
> 目标仓库：https://github.com/dudunewtall761121/obsidian-knowledge-base

---

## 执行前确认

以下信息已预置默认值，如用户无特殊要求可直接使用。如需修改请询问用户。

| 配置项 | 默认值 | 说明 |
|---|---|---|
| Vault 路径 | `D:\Work Space\第二大脑知识库` | Obsidian 仓库本地路径 |
| Git 远程仓库 | `https://github.com/dudunewtall761121/ai-team.git` | Vault 同步仓库，可直接使用 |
| Git 用户名 | `dudunewtall761121` | 提交者用户名 |
| Git 邮箱 | `dudunewtall761121@users.noreply.github.com` | GitHub noreply 邮箱，不暴露真实邮箱 |
| 默认分支 | `master` | 仓库主分支名 |
| Obsidian 路径 | 自动检测 | 已安装则自动打开 |

---

## 步骤 1：环境检查与 Git 安装

检查 git 是否可用，如缺失则自动安装：

```powershell
$gitAvailable = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitAvailable) {
    Write-Host "Git 未安装，尝试用 winget 安装..."
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    # 安装后刷新 PATH，用绝对路径调用
    $gitPath = "C:\Program Files\Git\cmd\git.exe"
    if (Test-Path $gitPath) {
        & $gitPath --version
    } else {
        Write-Error "Git 安装失败，请手动安装：https://git-scm.com/download/win"
        exit 1
    }
} else {
    git --version
}
$PSVersionTable.PSVersion
```

预期：git 版本号 + PowerShell 5.x 或 7.x。

---

## 步骤 2：克隆技能仓库

```powershell
$skillDir = "D:\Work Space\obsidian-knowledge-base"
if (Test-Path $skillDir) {
    Write-Host "技能目录已存在，跳过克隆"
} else {
    git clone https://github.com/dudunewtall761121/obsidian-knowledge-base.git $skillDir
}
```

---

## 步骤 3：运行初始化脚本

```powershell
$vaultPath = "D:\Work Space\第二大脑知识库"
& "$skillDir\scripts\init-vault.ps1" -VaultPath $vaultPath
```

预期输出：
```
[*] Target vault: D:\Work Space\第二大脑知识库
[*] Copying template files...
[+] Template files copied
[*] Copying Obsidian config...
[+] Obsidian config copied
[+] Vault initialized!
```

---

## 步骤 4：验证 Vault 结构

```powershell
Get-ChildItem -Path $vaultPath -Recurse -File | 
    Select-Object @{Name="Path";Expression={$_.FullName.Substring($vaultPath.Length)}} | 
    Sort-Object Path | Format-Table -AutoSize
```

预期包含以下关键文件：
- `00-Vault入口.md`
- `03-知识库\README.md`
- `03-知识库\00-索引.md`
- `03-知识库\06-项目索引\00-项目总览.md`
- `.obsidian\app.json`
- `.obsidian\templates.json`
- `.trae\skills\` （技能目录）

---

## 步骤 5：链接技能到 TRAE

将 Vault 中的技能链接到 TRAE 全局目录，这样 Agent 才能识别和调用。

```powershell
& "$vaultPath\.trae\skills\link-skills.ps1"
```

预期输出：
```
Vault skills: D:\Work Space\第二大脑知识库\.trae\skills
TRAE skills:  C:\Users\...\.trae-cn\skills

[LINK] obsidian-knowledge-base
[LINK] research-guide
...
Done. Linked 7 skills.
```

> 原理：TRAE 从 `~/.trae-cn/skills/` 加载技能。脚本用 Windows Directory Junction 把 Vault 里的技能映射过去，无需复制，Vault 更新后技能自动同步。

---

## 步骤 6（可选）：配置 Git 同步

> 本步骤需要与用户交互确认。用提问工具收集以下信息后再执行。

### 6.1 确认是否需要 Git 同步

询问用户：是否需要将 Vault 同步到远程 Git 仓库？

- **需要** → 继续 6.2
- **不需要** → 跳过整个步骤 6，直接到步骤 7

### 6.2 确认远程仓库

已预置仓库 URL，直接使用。如需切换到其他仓库，询问用户后修改：

```powershell
$remoteUrl = "https://github.com/dudunewtall761121/ai-team.git"
$defaultBranch = "master"
```

> 如果用户要使用其他仓库，引导在 GitHub 创建空仓库（不要勾选初始化 README），替换 `$remoteUrl` 的值。

### 6.3 确认认证方式

询问用户选择哪种认证方式：

| 方式 | 适用场景 | 操作 |
|---|---|---|
| HTTPS + Token | 推荐，简单 | 用户在 GitHub 生成 Personal Access Token，首次 push 时输入 |
| SSH | 已有 SSH 密钥 | 检查 `~/.ssh/id_ed25519.pub`，无则引导生成并添加到 GitHub |

**选择 HTTPS + Token 时**，告诉用户生成 Token 的步骤：
1. 打开 https://github.com/settings/tokens
2. 点击「Generate new token」→「Generate new token (classic)」
3. 勾选 `repo` 权限，生成后复制保存（只显示一次）

### 6.4 配置 Git 身份（仓库级，避免全局权限问题）

```powershell
cd $vaultPath

# 已预置身份信息，直接使用
$gitUserName = "dudunewtall761121"
$gitUserEmail = "dudunewtall761121@users.noreply.github.com"

git init
# 用 --local 只写入当前仓库，不污染全局配置
git config --local user.name $gitUserName
git config --local user.email $gitUserEmail
git config --local init.defaultBranch $defaultBranch
git config --local pull.rebase true
git config --local credential.helper manager
```

### 6.5 首次提交并推送

```powershell
git add -A
git commit -m "feat: 初始化知识库"
git branch -M $defaultBranch
git remote add origin $remoteUrl
git push -u origin $defaultBranch
```

**如果 push 失败（认证问题）**：

- HTTPS 方式：弹出 Git Credential Manager 窗口，输入用户名和 Token（Token 作为密码）
- 如果未弹出，手动配置：
  ```powershell
  # 把 Token 写入 credential helper（不落盘到脚本）
  git credential-manager configure
  # 重新 push，按提示输入
  git push -u origin main
  ```

### 6.6 日常同步协议（写入 Vault 的 README 或告知用户）

```
读取前：  git pull --rebase
写入后：  git add -A
         git commit -m "描述"
         git push
冲突时：  将冲突文件另存为 <原名>.conflict，推送本地版本，标记待人工处理
禁止：    Agent 自动 merge
```

---

## 步骤 7：用 Obsidian 打开 Vault

尝试自动检测并打开 Obsidian：

```powershell
$obsidianPaths = @(
    "D:\Obsidian\Obsidian.exe",
    "C:\Program Files\Obsidian\Obsidian.exe",
    "$env:LOCALAPPDATA\Obsidian\Obsidian.exe"
)
$obsidianExe = $obsidianPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($obsidianExe) {
    Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = "`"$obsidianExe`"" }
    Write-Host "Obsidian 已启动，请在 Obsidian 中：管理仓库 → 打开本地仓库 → 选择 $vaultPath"
} else {
    Write-Host "未检测到 Obsidian，请手动安装后打开：$vaultPath"
    Write-Host "下载地址：https://obsidian.md"
}
```

> 注意：Obsidian 首次打开需要手动选择仓库文件夹，无法通过命令行直接指定。

---

## 步骤 8：告知用户后续操作

部署完成后，向用户说明：

1. Vault 路径：`$vaultPath`
2. 关键入口文件：`00-Vault入口.md`
3. 知识库维护规则：`03-知识库\README.md`
4. 项目索引总览：`03-知识库\06-项目索引\00-项目总览.md`
5. 如需添加项目索引卡，使用模板：`03-知识库\00-模板\项目索引卡模板.md`

---

## 常见问题

**Q：git clone 失败？**
A：检查网络连接，或手动从 GitHub 下载 ZIP 解压到 `D:\Work Space\obsidian-knowledge-base`。

**Q：脚本执行报编码错误？**
A：确保用 PowerShell 5+ 运行，脚本本身不含中文路径硬编码。

**Q：Obsidian 打开后附件路径不对？**
A：检查 `.obsidian/app.json` 中 `attachmentFolderPath` 是否为 `03-知识库/99-附件`。

**Q：git push 提示认证失败？**
A：HTTPS 方式用 GitHub Personal Access Token 作为密码（不是 GitHub 登录密码）。生成地址：https://github.com/settings/tokens，勾选 `repo` 权限。

**Q：git config --global 报 Permission denied？**
A：改用 `--local` 写入仓库级配置，本文档步骤 5.4 已采用此方式，不修改全局配置。

**Q：想用 SSH 方式认证？**
A：执行以下命令生成密钥并添加到 GitHub：
```powershell
# 检查是否已有密钥
if (-not (Test-Path "$env:USERPROFILE\.ssh\id_ed25519.pub")) {
    ssh-keygen -t ed25519 -C "dudunewtall761121@users.noreply.github.com" -f "$env:USERPROFILE\.ssh\id_ed25519" -N '""'
}
# 显示公钥，复制后添加到 GitHub → Settings → SSH and GPG keys
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub"
# 测试连接
ssh -T git@github.com
```

**Q：push 时提示 fatal: remote origin already exists？**
A：先删除旧 remote 再添加：`git remote remove origin`，然后重新执行 `git remote add origin <URL>`。

**Q：首次 push 提示 src refspec main does not match any？**
A：还没有 commit。先执行 `git add -A` 和 `git commit -m "..."`，再 push。
