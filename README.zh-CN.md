# vxSpeedtest Server

一个基于 Nginx 的纯净网络测速服务器，支持自定义 URL、下载测速和上传测速。完全使用 Nginx 实现，无需其他脚本语言，通过 Docker 部署，简单高效。

**[English Documentation](README.md) | [日本語ドキュメント](README.ja.md)**

## 特性

✅ **纯 Nginx 实现** - 无需 PHP、Python 等脚本语言  
✅ **自定义 URL** - 设置专属测速路径，其他路径返回 403  
✅ **GET 下载测速** - 可配置下载文件大小（MB）  
✅ **POST 上传测速** - 可配置上传大小限制（MB）  
✅ **Docker 部署** - 一键启动，开箱即用  
✅ **安全防护** - 只允许访问指定路径，其他请求一律拒绝  
✅ **健康检查** - 内置健康检查端点  

## 快速开始

### 使用 Docker Compose（推荐）

1. 克隆仓库：
```bash
git clone https://github.com/tmplink/vxSpeedtest-Server.git
cd vxSpeedtest-Server
```

2. 修改 `docker-compose.yml` 中的环境变量（可选）：
```yaml
environment:
  - CUSTOM_URL=speedtest      # 自定义 URL 路径
  - DOWNLOAD_SIZE=100         # 下载文件大小（MB）
  - POST_SIZE_LIMIT=1000      # 上传大小限制（MB）
```

3. 启动服务：
```bash
docker-compose up -d
```

4. 测试服务：
```bash
# 下载测速
curl -O http://localhost:8080/speedtest

# 上传测速
curl -X POST http://localhost:8080/speedtest \
  -H "Content-Type: application/octet-stream" \
  --data-binary "@largefile.bin"

# 访问其他路径（会返回 403）
curl http://localhost:8080/other-path
```

### 使用 Docker Run

```bash
# 构建镜像
docker build -t vxspeedtest-server .

# 运行容器
docker run -d \
  --name vxspeedtest \
  -p 8080:80 \
  -e CUSTOM_URL=abvcd5 \
  -e DOWNLOAD_SIZE=100 \
  -e POST_SIZE_LIMIT=1000 \
  vxspeedtest-server
```

## 配置参数

| 环境变量 | 说明 | 默认值 | 示例 |
|---------|------|--------|------|
| `CUSTOM_URL` | 自定义 URL 路径（不含前导斜杠） | `speedtest` | `abvcd5`, `test123` |
| `DOWNLOAD_SIZE` | 下载测速文件大小（MB） | `100` | `50`, `500`, `1000` |
| `POST_SIZE_LIMIT` | POST 上传大小限制（MB） | `1000` | `100`, `2000`, `5000` |

## 使用示例

### 1. 下载测速

```bash
# 使用 curl 测试下载速度
curl -o /dev/null http://your-domain.com/abvcd5

# 使用 wget 测试下载速度
wget -O /dev/null http://your-domain.com/abvcd5

# 显示下载进度和速度
curl -# http://your-domain.com/abvcd5 > /dev/null
```

### 2. 上传测速

```bash
# 生成测试文件
dd if=/dev/zero of=test.bin bs=1M count=100

# 上传测速
curl -X POST http://your-domain.com/abvcd5 \
  -H "Content-Type: application/octet-stream" \
  --data-binary "@test.bin" \
  -w "\nUpload Speed: %{speed_upload} bytes/sec\n"
```

### 3. 配合 Speedtest 客户端

可以将此服务器作为自定义测速节点，配合各种测速工具使用：

```bash
# 下载测试
time curl -o /dev/null -s http://your-domain.com/abvcd5

# 上传测试
time curl -X POST http://your-domain.com/abvcd5 \
  --data-binary "@test.bin" \
  -s -o /dev/null
```

## 生产环境部署

### 修改端口映射

在 `docker-compose.yml` 中修改端口：

```yaml
ports:
  - "80:80"   # 直接暴露 80 端口
  # 或
  - "自定义端口:80"
```

## 安全建议

1. **使用复杂的自定义 URL**：避免使用 `speedtest`、`test` 等容易被猜到的路径
2. **配置防火墙规则**：限制访问来源 IP
3. **启用 HTTPS**：生产环境建议使用反向代理配置 SSL 证书
4. **合理设置上传限制**：根据服务器带宽和存储设置 `POST_SIZE_LIMIT`
5. **监控资源使用**：定期检查服务器 CPU、内存、网络使用情况

## 健康检查

服务提供了健康检查端点：

```bash
curl http://localhost:8080/health
# 返回: OK
```

可用于负载均衡器或监控系统。

## 故障排查

### 查看日志

```bash
# 查看容器日志
docker logs vxspeedtest-server

# 实时查看日志
docker logs -f vxspeedtest-server
```

### 进入容器调试

```bash
# 进入容器
docker exec -it vxspeedtest-server sh

# 查看 Nginx 配置
cat /etc/nginx/nginx.conf

# 测试 Nginx 配置
nginx -t

# 查看测速文件
ls -lh /usr/share/nginx/html/testfile
```

### 常见问题

**Q: 访问自定义 URL 返回 404？**  
A: 检查 `CUSTOM_URL` 环境变量是否正确设置，不要包含前导斜杠 `/`。

**Q: 上传失败，提示文件太大？**  
A: 增加 `POST_SIZE_LIMIT` 环境变量的值。

**Q: 下载速度不准确？**  
A: 确保服务器带宽充足，可以增加 `DOWNLOAD_SIZE` 以获得更准确的测速结果。

## 性能优化

- 服务器使用 `nginx:alpine` 基础镜像，体积小、性能好
- 使用 `sendfile`、`tcp_nopush`、`tcp_nodelay` 优化传输性能
- 禁用不必要的缓冲以提高测速准确性
- Worker 进程数自动适配 CPU 核心数

## 技术架构

```
┌─────────────────┐
│   Docker 容器    │
│                 │
│  ┌───────────┐  │
│  │ Nginx     │  │
│  │ (Alpine)  │  │
│  └───────────┘  │
│       │         │
│  ┌───────────┐  │
│  │测速文件    │  │
│  │(/testfile)│  │
│  └───────────┘  │
└─────────────────┘
        │
        ▼
   端口 80/443
```

## 许可证

本项目采用 Apache License 2.0 许可证。详见 [LICENSE](LICENSE) 文件。

````
