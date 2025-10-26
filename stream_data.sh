#!/bin/sh
# 生成指定大小的随机数据流
# 用法: stream_data.sh <size_in_mb>

SIZE_MB=${1:-1024}
dd if=/dev/zero bs=1M count=${SIZE_MB} 2>/dev/null
