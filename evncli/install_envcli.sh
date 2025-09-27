#!/bin/bash
set -e

# ----------------------------
# 配置
# ----------------------------
REPO="gz-jd-2025/rust-envir-var"   # 你的 GitHub 仓库
BIN_NAME="envcli"
INSTALL_DIR="/usr/local/bin"

# ----------------------------
# 检测操作系统和架构
# ----------------------------
OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
elif [[ "$ARCH" =~ ^arm ]]; then
    ARCH="arm64"
fi

echo "Detected OS=$OS, ARCH=$ARCH"

# ----------------------------
# 获取最新 Release
# ----------------------------
LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" \
             | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
echo "Latest version: $LATEST_TAG"

# 构建下载 URL
URL="https://github.com/$REPO/releases/download/$LATEST_TAG/$BIN_NAME-$OS-$ARCH"
echo "Downloading $URL ..."

# ----------------------------
# 下载并安装
# ----------------------------
curl -L -o "$INSTALL_DIR/$BIN_NAME" "$URL"
chmod +x "$INSTALL_DIR/$BIN_NAME"

echo "✅ $BIN_NAME installed to $INSTALL_DIR"

# ----------------------------
# 自动刷新 shell 配置（仅 Linux/macOS）
# ----------------------------
SHELL_NAME=$(basename "$SHELL")
RC_FILE=""

if [[ "$SHELL_NAME" == "bash" ]]; then
    RC_FILE="$HOME/.bashrc"
elif [[ "$SHELL_NAME" == "zsh" ]]; then
    RC_FILE="$HOME/.zshrc"
elif [[ "$SHELL_NAME" == "fish" ]]; then
    RC_FILE="$HOME/.config/fish/config.fish"
fi

if [[ -n "$RC_FILE" && -f "$RC_FILE" ]]; then
    echo "🔄 Reloading shell configuration..."
    if [[ "$SHELL_NAME" == "fish" ]]; then
        fish -c "source $RC_FILE"
    else
        source "$RC_FILE"
    fi
fi

echo "🎉 Installation complete! Run '$BIN_NAME --help' to get started."
