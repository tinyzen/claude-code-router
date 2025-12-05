# Claude Code Router 使用教程

这是一个基于 Docker 的 [Claude Code Router](https://github.com/musistudio/claude-code-router) 服务，通过 config.json 文件进行配置。

## 安装与基本使用

### Node.js 安装
- 安装 Claude Code：`npm install -g @anthropic-ai/claude-code`
- 安装 Claude Code Router：`npm install -g @musistudio/claude-code-router`

### Docker 使用

#### 基本使用（使用默认配置）

```bash
docker run -p 3456:3456 jetsung/claude-code-router
```

#### 使用 Docker Compose

```yaml
version: '3.8'

services:
  claude-code-router:
    image: jetsung/claude-code-router:latest
    container_name: claude-code-router
    restart: unless-stopped

    # 端口映射（根据config.json中的PORT配置）
    ports:
      - "3456:3456"

    # 数据持久化（包含config.json配置文件）
    volumes:
      - claude-config:/root/.claude-code-router

    # 健康检查
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3456/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

volumes:
  claude-config:
    driver: local
```

#### 使用自定义配置文件

```bash
# 创建本地配置目录
mkdir -p ./config

# 复制并编辑配置文件
docker run --rm jetsung/claude-code-router cat /root/.claude-code-router/config.json > ./config/config.json
# 编辑配置文件
vim ./config/config.json

# 使用自定义配置启动
docker run \
  -p 3456:3456 \
  -v ./config:/root/.claude-code-router \
  jetsung/claude-code-router
```

## 配置文件详解

配置文件位于 `~/.claude-code-router/config.json`，包含以下配置参数：

### 核心配置参数

- **`HOST`** (可选): 服务器监听的主机地址
  - `"0.0.0.0"` - 允许外部访问
  - `"127.0.0.1"` - 仅本地访问（更安全）
  - 如果未设置APIKEY，HOST会自动强制设置为127.0.0.1

- **`PORT`** (可选): 服务端口号，默认为3456

- **`APIKEY`** (可选): 用于认证请求的密钥
  - 当设置此字段时，客户端必须在请求头中提供此密钥：
  - Authorization header: `Bearer your-secret-key`
  - 或 x-api-key header: `your-secret-key`
  - 建议在生产环境中设置强密钥

- **`PROXY_URL`** (可选): 设置API请求的代理（例如：`"http://127.0.0.1:7890"）

- **`LOG`** (可选): 设置为 `true` 时启用日志记录。默认为 `true`

- **`LOG_LEVEL`** (可选): 设置日志级别，选项包括：`"fatal"`, `"error"`, `"warn"`, `"info"`, `"debug"`, `"trace"`。默认为 `"debug"`

- **`NON_INTERACTIVE_MODE`** (可选): 当设置为 `true` 时，启用与非交互式环境的兼容性，如GitHub Actions

- **`API_TIMEOUT_MS`** (可选): API请求超时时间（毫秒）

### 提供商配置 (Providers)

每个提供商配置需要包含：
- `name`: 唯一的提供商标识符
- `api_base_url`: 聊天完成的完整API端点
- `api_key`: 您的提供商API密钥
- `models`: 可用模型名称列表
- `transformer` (可选): 指定请求/响应处理的转换器

### 路由器配置 (Router)

定义不同场景的模型：
- **`default`**: 常规任务的默认模型
- **`background`**: 后台任务的模型（可以是较小的本地模型以节省成本）
- **`think`**: 推理密集型任务的模型，如规划模式
- **`longContext`**: 处理长上下文（>60K tokens）的模型
- **`longContextThreshold`** (可选): 长上下文模型的token计数阈值。默认值为60000
- **`webSearch`**: 网络搜索任务的模型（需要模型支持）
- **`image`** (测试版): 使用CCR内置代理支持的图像任务的模型

### 高级配置

- **`CUSTOM_ROUTER_PATH`**: 指定自定义路由器脚本以实现超越默认场景的高级路由逻辑

## 配置示例

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

### 提供商配置示例

```json
"Providers": [
  {
    "name": "openrouter",
    "api_base_url": "https://openrouter.ai/api/v1/chat/completions",
    "api_key": "sk-xxx",
    "models": ["google/gemini-2.5-pro-preview"],
    "transformer": {"use": ["openrouter"]}
  }
]
```

### 路由配置示例

```json
"Router": {
  "default": "deepseek,deepseek-chat",
  "background": "ollama,qwen2.5-coder:latest",
    "think": "deepseek,deepseek-reasoner",
  "longContext": "openrouter,google/gemini-2.5-pro-preview",
  "longContextThreshold": 60000
}
```

### 仅本地访问配置

```json
{
  "HOST": "127.0.0.1",
  "webSearch": "anthropic/claude-3-5-sonnet",
  "image": "anthropic/claude-3-5-sonnet",
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

## 命令行操作

- 启动服务：`ccr code`
- 重启服务：`ccr restart`（修改配置后需要）
- UI模式：`ccr ui`（提供Web界面管理配置）

## 环境变量激活

使用 `eval "$(ccr activate)"` 设置环境变量，使 `claude` 命令自动通过路由器。

## 带API密钥的客户端请求示例

```bash
# 使用Authorization header
curl -H "Authorization: Bearer your-secret-key" http://localhost:3456/api/endpoint

# 使用x-api-key header
curl -H "x-api-key: your-secret-key" http://localhost:3456/api/endpoint
```

## GitHub Actions 集成

在 workflow 中配置路由器服务，设置环境变量 `ANTHROPIC_BASE_URL: http://localhost:3456" 即可集成到 CI/CD 流程中。

## 安全注意事项

1. **生产环境建议**: 将 HOST 设置为 `"127.0.0.1"` 以限制仅本地访问
2. **网络访问**: 只有在需要外部访问时才将 HOST 设置为 `"0.0.0.0"`
3. **防火墙**: 确保适当的防火墙规则配置
4. **配置文件保护**: 确保配置文件包含敏感信息时得到适当保护

## 数据持久化

使用 Docker 卷来持久化配置数据：

```bash
docker run -v claude-config:/root/.claude-code-router -p 3456:3456 jetsung/claude-code-router
```

或使用主机目录：

```bash
docker run -v /your/local/path:/root/.claude-code-router -p 3456:3456 jetsung/claude-code-router
```