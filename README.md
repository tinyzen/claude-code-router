# Claude Code Router Docker

这是一个基于Docker的[Claude Code Router](https://github.com/musistudio/claude-code-router)服务，通过config.json文件进行配置。

## 配置文件

服务通过 `/root/.claude-code-router/config.json` 文件进行配置。容器启动时会自动创建默认配置文件。

### 默认配置文件结构
```json
{
  "HOST": "0.0.0.0",
  "PORT": 3456,
  "APIKEY": "your-secret-key",
  "Providers": [],
  "Router": {}
}
```

### 配置说明

- **HOST**: 服务器监听的主机地址
  - `"0.0.0.0"` - 允许外部访问
  - `"127.0.0.1"` - 仅本地访问（更安全）
  
- **PORT**: 服务端口号，默认为3456

- **APIKEY**: 用于认证请求的密钥
  - 当设置此字段时，客户端必须在请求头中提供此密钥：
    - Authorization header: `Bearer your-secret-key`
    - 或 x-api-key header: `your-secret-key`
  - 建议在生产环境中设置强密钥

- **Providers**: 服务提供商配置数组

- **Router**: 路由器配置对象

## 使用示例

### 基本使用（使用默认配置）
```bash
 docker run -p 3456:3456 ghcr.io/tinyzen/claude-code-router```

### 使用自定义配置文件
```bash
# 创建本地配置目录
mkdir -p ./config

# 复制并编辑配置文件
 docker run --rm ghcr.io/tinyzen/claude-code-router cat /root/.claude-code-router/config.json > ./config/config.json
# 编辑配置文件
vim ./config/config.json

# 使用自定义配置启动
docker run \
  -p 3456:3456 \
  -v ./config:/root/.claude-code-router \
ghcr.io/tinyzen/claude-code-router
```

### 仅本地访问配置
```json
{
  "HOST": "127.0.0.1",
  "PORT": 3456,
  "APIKEY": "your-secret-key",
  "Providers": [],
  "Router": {}
}
```

### 外部访问配置
```json
{
  "HOST": "0.0.0.0",
  "PORT": 3456,
  "APIKEY": "your-secret-key",
  "Providers": [],
  "Router": {}
}
```

### 自定义端口配置
```json
{
  "HOST": "0.0.0.0",
  "PORT": 8080,
  "APIKEY": "your-secret-key",
  "Providers": [],
  "Router": {}
}
```

### 带API密钥的客户端请求示例
```bash
# 使用Authorization header
curl -H "Authorization: Bearer your-secret-key" http://localhost:3456/api/endpoint

# 使用x-api-key header
curl -H "x-api-key: your-secret-key" http://localhost:3456/api/endpoint
```

## 安全注意事项

1. **生产环境建议**: 将HOST设置为`"127.0.0.1"`以限制仅本地访问
2. **网络访问**: 只有在需要外部访问时才将HOST设置为`"0.0.0.0"`
3. **防火墙**: 确保适当的防火墙规则配置
4. **配置文件保护**: 确保配置文件包含敏感信息时得到适当保护

## 数据持久化

使用Docker卷来持久化配置数据：
```bash
 docker run -v claude-config:/root/.claude-code-router -p 3456:3456 ghcr.io/tinyzen/claude-code-router```

或使用主机目录：
```bash
 docker run -v /your/local/path:/root/.claude-code-router -p 3456:3456 ghcr.io/tinyzen/claude-code-router
