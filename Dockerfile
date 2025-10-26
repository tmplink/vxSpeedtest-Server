FROM nginx:alpine

# 安装 envsubst 工具（alpine 版本已包含）
RUN apk add --no-cache bash

# 复制配置模板和启动脚本
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
COPY stream_data.sh /stream_data.sh

# 设置脚本执行权限
RUN chmod +x /entrypoint.sh /stream_data.sh

# 设置默认环境变量
ENV CUSTOM_URL=speedtest \
    SIZE_LIMIT=1025

# 暴露端口
EXPOSE 80

# 使用自定义入口脚本
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
