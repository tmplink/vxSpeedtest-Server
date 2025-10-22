# vxSpeedtest Server

A pure Nginx-based network speed test server that supports custom URLs, download speed testing, and upload speed testing. Fully implemented with Nginx, no other scripting languages required. Deploy with Docker for simplicity and efficiency.

**[中文文档](README.zh-CN.md) | [日本語ドキュメント](README.ja.md)**

## Features

✅ **Pure Nginx Implementation** - No PHP, Python, or other scripting languages required  
✅ **Custom URL** - Set exclusive speed test paths, other paths return 403  
✅ **GET Download Speed Test** - Configurable download file size (MB)  
✅ **POST Upload Speed Test** - Configurable upload size limit (MB)  
✅ **Docker Deployment** - One-click startup, ready to use  
✅ **Security Protection** - Only allows access to specified paths, all other requests are rejected  
✅ **Health Check** - Built-in health check endpoint  

## Quick Start

### Using Docker Compose (Recommended)

1. Clone the repository:
```bash
git clone https://github.com/tmplink/vxSpeedtest-Server.git
cd vxSpeedtest-Server
```

2. Modify environment variables in `docker-compose.yml` (optional):
```yaml
environment:
  - CUSTOM_URL=speedtest      # Custom URL path
  - DOWNLOAD_SIZE=128         # Download file size (MB)
  - POST_SIZE_LIMIT=128       # Upload size limit (MB)
```

3. Start the service:
```bash
docker-compose up -d
```

4. Test the service:
```bash
# Download speed test
curl -O http://localhost:8080/speedtest

# Upload speed test
curl -X POST http://localhost:8080/speedtest \
  -H "Content-Type: application/octet-stream" \
  --data-binary "@largefile.bin"

# Access other paths (returns 403)
curl http://localhost:8080/other-path
```

### Using Docker Run

```bash
# Build image
docker build -t vxspeedtest-server .

# Run container
docker run -d \
  --name vxspeedtest \
  -p 8080:80 \
  -e CUSTOM_URL=speedtest \
  -e DOWNLOAD_SIZE=128 \
  -e POST_SIZE_LIMIT=128 \
  vxspeedtest-server
```

## Configuration Parameters

| Environment Variable | Description | Default | Example |
|---------|------|--------|------|
| `CUSTOM_URL` | Custom URL path (without leading slash) | `speedtest` | `abvcd5`, `test123` |
| `DOWNLOAD_SIZE` | Download speed test file size (MB) | `100` | `1`, `8`, `128`, `512`, `1024` |
| `POST_SIZE_LIMIT` | POST upload size limit (MB) | `1000` | `1`, `8`, `128`, `512`, `1024` |

## Usage Examples

### 1. Download Speed Test

```bash
# Test download speed with curl
curl -o /dev/null http://your-domain.com:8080/speedtest

# Test download speed with wget
wget -O /dev/null http://your-domain.com:8080/speedtest

# Show download progress and speed
curl -# http://your-domain.com:8080/speedtest > /dev/null
```

### 2. Upload Speed Test

```bash
# Generate test file
dd if=/dev/zero of=test.bin bs=1M count=100

# Upload speed test
curl -X POST http://your-domain.com:8080/speedtest \
  -H "Content-Type: application/octet-stream" \
  --data-binary "@test.bin" \
  -w "\nUpload Speed: %{speed_upload} bytes/sec\n"
```

### 3. Integration with Speedtest Clients

Use this server as a custom speed test node with various speed test tools:

```bash
# Download test
time curl -o /dev/null -s http://your-domain.com:8080/speedtest

# Upload test
time curl -X POST http://your-domain.com:8080/speedtest \
  --data-binary "@test.bin" \
  -s -o /dev/null
```

## Production Deployment

### Modify Port Mapping

Modify the port in `docker-compose.yml`:

```yaml
ports:
  - "80:80"   # Expose port 80 directly
  # or
  - "custom-port:80"
```

## Security Recommendations

1. **Use Complex Custom URLs**: Avoid easily guessable paths like `speedtest`, `test`
2. **Configure Firewall Rules**: Restrict access to source IPs
3. **Enable HTTPS**: Use reverse proxy to configure SSL certificates in production
4. **Set Reasonable Upload Limits**: Configure `POST_SIZE_LIMIT` based on server bandwidth and storage
5. **Monitor Resource Usage**: Regularly check server CPU, memory, and network usage

## Health Check

The service provides a health check endpoint:

```bash
curl http://localhost:8080/health
# Returns: OK
```

Can be used with load balancers or monitoring systems.

## Troubleshooting

### View Logs

```bash
# View container logs
docker logs vxspeedtest-server

# View logs in real-time
docker logs -f vxspeedtest-server
```

### Enter Container for Debugging

```bash
# Enter container
docker exec -it vxspeedtest-server sh

# View Nginx configuration
cat /etc/nginx/nginx.conf

# Test Nginx configuration
nginx -t

# View speed test file
ls -lh /usr/share/nginx/html/testfile
```

### Common Issues

**Q: Accessing custom URL returns 404?**  
A: Check if the `CUSTOM_URL` environment variable is set correctly, do not include leading slash `/`.

**Q: Upload fails with file too large error?**  
A: Increase the value of the `POST_SIZE_LIMIT` environment variable.

**Q: Download speed is inaccurate?**  
A: Ensure sufficient server bandwidth, you can increase `DOWNLOAD_SIZE` for more accurate speed test results.

## Performance Optimization

- Server uses `nginx:alpine` base image for small size and good performance
- Uses `sendfile`, `tcp_nopush`, `tcp_nodelay` to optimize transfer performance
- Disables unnecessary buffering to improve speed test accuracy
- Worker process count automatically adapts to CPU cores

## Technical Architecture

```
┌─────────────────┐
│  Docker Container│
│                 │
│  ┌───────────┐  │
│  │ Nginx     │  │
│  │ (Alpine)  │  │
│  └───────────┘  │
│       │         │
│  ┌───────────┐  │
│  │Test File  │  │
│  │(/testfile)│  │
│  └───────────┘  │
└─────────────────┘
        │
        ▼
   Port 80/443
```

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
