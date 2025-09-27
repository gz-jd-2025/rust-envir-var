use clap::{Arg, Command};
use std::env;
use std::fs::{OpenOptions, read_to_string};
use std::io::{Write, BufWriter};
use std::process::Command as ProcessCommand;

fn main() {
    let matches = Command::new("envcli")
        .version("0.1.1")
        .author("<zjchal@163.com>")
        .about("跨平台环境变量管理工具")
        .arg(
            Arg::new("set")
                .short('s')
                .long("set")
                .value_name("KEY=VALUE")
                .help("Set one or more persistent environment variables")
                .num_args(1..),
        )
        .arg(
            Arg::new("get")
                .short('g')
                .long("get")
                .value_name("KEY")
                .help("Get an environment variable")
                .num_args(1),
        )
        .get_matches();

    // 获取 shell 类型
    let shell = env::var("SHELL").unwrap_or_default();

    // 处理 --set
    if let Some(kvs) = matches.get_many::<String>("set") {
        for kv in kvs {
            if let Some((key, value)) = kv.split_once('=') {
                if cfg!(target_os = "windows") {
                    // Windows
                    let output = ProcessCommand::new("setx")
                        .arg(key)
                        .arg(value)
                        .output()
                        .expect("failed to run setx");
                    if output.status.success() {
                        println!("✅ Windows: {}={} has been set", key, value);
                    } else {
                        eprintln!("❌ Failed to set environment variable on Windows");
                    }
                } else {
                    // Linux / macOS
                    let home = env::var("HOME").unwrap();
                    let rc_file = if shell.contains("zsh") {
                        format!("{}/.zshrc", home)
                    } else if shell.contains("fish") {
                        format!("{}/.config/fish/config.fish", home)
                    } else {
                        format!("{}/.bashrc", home)
                    };

                    // 读取现有内容
                    let content = read_to_string(&rc_file).unwrap_or_default();
                    let mut lines: Vec<String> = content.lines().map(|l| l.to_string()).collect();

                    // 构建要写入的行
                    let new_line = if shell.contains("fish") {
                        format!("set -x {} {}", key, value)
                    } else {
                        format!("export {}={}", key, value)
                    };

                    // 检查是否已有该变量，覆盖
                    let mut found = false;
                    for line in &mut lines {
                        if shell.contains("fish") {
                            if line.starts_with(&format!("set -x {} ", key)) {
                                *line = new_line.clone();
                                found = true;
                                break;
                            }
                        } else {
                            if line.starts_with(&format!("export {}=", key)) {
                                *line = new_line.clone();
                                found = true;
                                break;
                            }
                        }
                    }

                    if !found {
                        lines.push(new_line.clone());
                    }

                    // 写回文件
                    let file = OpenOptions::new()
                        .write(true)
                        .truncate(true)
                        .open(&rc_file)
                        .expect("failed to open rc file for writing");
                    let mut writer = BufWriter::new(file);
                    for line in lines {
                        writeln!(writer, "{}", line).unwrap();
                    }

                    println!("✅ Unix: {}={} has been added/updated in {}", key, value, rc_file);

                    // 自动刷新 shell 配置
                    if !shell.contains("fish") {
                        // bash / zsh
                        let status = ProcessCommand::new("sh")
                            .arg("-c")
                            .arg(format!("source {}", rc_file))
                            .status()
                            .unwrap_or_default();
                        if status.success() {
                            println!("🔄 Shell configuration reloaded automatically");
                        }
                    } else {
                        // fish
                        let status = ProcessCommand::new("fish")
                            .arg("-c")
                            .arg(format!("source {}", rc_file))
                            .status()
                            .unwrap_or_default();
                        if status.success() {
                            println!("🔄 Fish configuration reloaded automatically");
                        }
                    }
                }
            } else {
                eprintln!("❌ Invalid format, use KEY=VALUE");
            }
        }
    }

    // 处理 --get
    if let Some(key) = matches.get_one::<String>("get") {
        match env::var(key) {
            Ok(val) => println!("{}={}", key, val),
            Err(_) => println!("{} is not set", key),
        }
    }
}