#!/usr/bin/env bash

set -e

if [ -z "${SSH_PASSWORD:-}" ]; then
    echo "错误：没有设置 SSH_PASSWORD 环境变量"
    exit 1
fi

echo "root:${SSH_PASSWORD}" | chpasswd

mkdir -p /run/sshd
ssh-keygen -A

/usr/sbin/sshd

echo "SSH server started on port 22"

exec sleep infinity
