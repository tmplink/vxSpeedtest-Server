#!/bin/bash
set -e

echo "=== vxSpeedtest Server Starting ==="
echo "CUSTOM_URL: ${CUSTOM_URL}"
echo "SIZE_LIMIT: ${SIZE_LIMIT} MB"

# 计算字节数（MB 转 Bytes）
SIZE_LIMIT_BYTES=$((SIZE_LIMIT * 1024 * 1024))

# 替换 nginx 配置模板中的环境变量
export SIZE_LIMIT_BYTES
envsubst '${CUSTOM_URL} ${SIZE_LIMIT} ${SIZE_LIMIT_BYTES}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# 创建指向 /dev/zero 的符号链接，用于动态生成数据
# 或者创建一个空的稀疏文件
echo "Creating ${SIZE_LIMIT}MB sparse test file..."
mkdir -p /usr/share/nginx/html
dd if=/dev/zero of=/usr/share/nginx/html/testfile bs=1M count=0 seek=${SIZE_LIMIT} 2>/dev/null
chmod 644 /usr/share/nginx/html/testfile

echo "Configuration completed!"
echo "Access URL: http://your-domain/${CUSTOM_URL}"
echo "  - GET  : Download ${SIZE_LIMIT}MB data stream"
echo "  - POST : Upload up to ${SIZE_LIMIT}MB for speed test"
echo "=================================="

# 测试配置
nginx -t

# 执行传入的命令（启动 nginx）
exec "$@"
