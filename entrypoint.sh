#!/bin/bash
set -e

echo "=== vxSpeedtest Server Starting ==="
echo "CUSTOM_URL: ${CUSTOM_URL}"
echo "DOWNLOAD_SIZE: ${DOWNLOAD_SIZE} MB"
echo "POST_SIZE_LIMIT: ${POST_SIZE_LIMIT} MB"

# 替换 nginx 配置模板中的环境变量
envsubst '${CUSTOM_URL} ${POST_SIZE_LIMIT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf.tmp

# 生成指定大小的随机数据文件用于下载测速
echo "Generating ${DOWNLOAD_SIZE}MB test file..."
/generate_data.sh ${DOWNLOAD_SIZE} /usr/share/nginx/html/testfile

# 在临时配置中添加下载文件的配置
# 找到 location = /${CUSTOM_URL} 块，在 GET 请求部分添加文件返回
sed -i "s|return 200;|root /usr/share/nginx/html;\ntry_files /testfile =404;\nadd_header Content-Type application/octet-stream;\nadd_header Content-Disposition \"attachment; filename=testfile\";\nadd_header Cache-Control \"no-cache, no-store, must-revalidate\";|g" /etc/nginx/nginx.conf.tmp

# 移动最终配置
mv /etc/nginx/nginx.conf.tmp /etc/nginx/nginx.conf

echo "Configuration completed!"
echo "Access URL: http://your-domain/${CUSTOM_URL}"
echo "  - GET  : Download ${DOWNLOAD_SIZE}MB file for speed test"
echo "  - POST : Upload up to ${POST_SIZE_LIMIT}MB for speed test"
echo "=================================="

# 测试配置
nginx -t

# 执行传入的命令（启动 nginx）
exec "$@"
