#!/bin/bash
# 生成指定大小的随机数据文件
# 用法: generate_data.sh <size_in_mb> <output_file>

SIZE_MB=$1
OUTPUT_FILE=$2

if [ -z "$SIZE_MB" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: $0 <size_in_mb> <output_file>"
    exit 1
fi

# 使用 dd 和 /dev/urandom 生成随机数据
# 为了提高性能，使用 /dev/zero 生成数据（对测速来说足够了）
echo "Generating ${SIZE_MB}MB file at ${OUTPUT_FILE}..."
dd if=/dev/zero of=${OUTPUT_FILE} bs=1M count=${SIZE_MB} 2>/dev/null

# 设置文件权限
chmod 644 ${OUTPUT_FILE}

echo "File generated successfully: ${OUTPUT_FILE} (${SIZE_MB}MB)"
