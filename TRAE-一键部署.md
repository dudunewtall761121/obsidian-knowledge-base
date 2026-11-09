# Obsidian 第二大脑 · 一键部署到新电脑

> 本文档给 TRAE Agent 读取执行。按顺序完成所有步骤即可在新电脑上搭建完整知识库。
> 目标仓库：https://github.com/dudunewtall761121/obsidian-knowledge-base

---

## 执行前确认

请向用户确认以下信息，如未指定则使用默认值：

| 配置项 | 默认值 | 说明 |
|---|---|---|
| Vault 路径 | `D:\Work Space\第二大脑知识库` | Obsidian 仓库本地路径 |
| Git 远程仓库 | 无 | 如需同步，提供仓库 URL；不需要则跳过 |
| Obsidian 路径 | 自动检测 | 已安装则自动打开 |

---

## 步骤 1：环境检查

执行以下命令，确认 git 和 PowerShell 可用：

```powershell
git --version
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

---

## 步骤 5（可选）：配置 Git 同步

如果用户提供了远程仓库 URL，执行：

```powershell
$remoteUrl = "<用户提供的仓库URL>"
cd $vaultPath
git init
git config user.name "<用户名>"
git config user.email "<邮箱>"
git add -A
git commit -m "feat: 初始化知识库"
git branch -M main
git remote add origin $remoteUrl
git push -u origin main
```

如果用户未提供远程仓库，跳过此步骤。

---

## 步骤 6：用 Obsidian 打开 Vault

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

## 步骤 7：告知用户后续操作

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
