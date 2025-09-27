# rust-envir-var

使用 **Rust** 开发的跨平台 CLI 工具，用于管理环境变量。

---

## 版本历史

### v0.1.0
- 设置单个环境变量

### v0.1.1
新增功能说明：
- **自动刷新 Shell**  
  设置完成后，CLI 会自动执行 `source ~/.bashrc` / `~/.zshrc` / `config.fish`，让变量立即生效。
- **覆盖旧变量**  
  已有同名变量会被替换，不重复追加。
- **支持多变量一次设置**  
  可以一次性设置多个环境变量。

### v0.1.2
- **压缩二进制包体积**  
  通过 Release 编译优化、LTO 和 panic 配置等方式减小可执行文件大小，CLI 工具更轻量。

---

## 安装

### 编译安装
```bash
cargo build --release
# 可执行文件在 target/release/envcli
# 可选：拷贝到 PATH
cp target/release/envcli /usr/local/bin/