# 安全模式
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ----------------------------
# 配置
# ----------------------------
$Repo = "gz-jd-2025/rust-envir-var"
$BinName = "envcli"
$InstallDir = "$env:USERPROFILE\bin"  # 默认安装到用户目录 bin，可自定义

# 创建目录（如果不存在）
if (-Not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
}

# ----------------------------
# 检测架构
# ----------------------------
$arch = if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") { "amd64" } else { "arm64" }

# ----------------------------
# 获取最新 Release
# ----------------------------
$LatestTag = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest" | Select-Object -ExpandProperty tag_name
Write-Host "Latest version: $LatestTag"

# 构建下载 URL
$Url = "https://github.com/$Repo/releases/download/$LatestTag/$BinName-windows-$arch.exe"
Write-Host "Downloading $Url ..."

# 下载文件
$OutFile = Join-Path $InstallDir $BinName
Invoke-WebRequest -Uri $Url -OutFile $OutFile

# ----------------------------
# 添加 PATH（如果未包含）
# ----------------------------
$CurrentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($CurrentPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$CurrentPath;$InstallDir", "User")
    Write-Host "✅ Added $InstallDir to PATH. Restart your terminal to take effect."
} else {
    Write-Host "✅ $InstallDir is already in PATH."
}

Write-Host "✅ $BinName installed to $InstallDir"
Write-Host "🎉 Installation complete! Run 'envcli --help' to get started."