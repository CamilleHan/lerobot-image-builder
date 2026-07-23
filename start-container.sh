#!/usr/bin/env bash

set -euo pipefail

if [ -z "${SSH_PASSWORD:-}" ]; then
    echo "错误：未设置 SSH_PASSWORD 环境变量"
    exit 1
fi

echo "正在初始化 SSH 服务……"

mkdir -p /run/sshd

# 为当前容器生成缺失的SSH主机密钥
ssh-keygen -A

# 设置root登录密码
echo "root:${SSH_PASSWORD}" | chpasswd

echo "SSH服务已启动，监听容器端口22"

# 前台运行，保证容器不会退出
exec /usr/sbin/sshd -D -e
