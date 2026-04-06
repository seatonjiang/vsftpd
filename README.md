# vsftpd

基于 Docker 构建的 vsftpd 服务器，集成了 Caddy 服务。

## 🚀 快速入门

### 第一步：克隆仓库

国外用户可以使用 GitHub 克隆仓库：

```bash
git clone --depth 1 https://github.com/seatonjiang/vsftpd.git
```

国内用户可以使用 CNB 克隆仓库：

```bash
git clone --depth 1 https://cnb.cool/seatonjiang/vsftpd.git
```

### 第二步：编辑配置

进入项目文件夹：

```bash
cd vsftpd/
```

重命名环境配置文件：

```bash
cp env.example .env
```

编辑 `.env` 文件，根据需要修改配置：

```bash
vi .env
```

重点配置项：

```ini
# vsftpd 端口
VSFTPD_PORT=21

# 被动模式端口范围
VSFTPD_PASSIVE_PORT=50000-50100

# 允许连接的 IP 地址
VSFTPD_PASV_ADDRESS=127.0.0.1
```

> 提示：云服务器需要在防火墙中放通 vsftpd 端口（默认为 21）以及被动模式端口范围（默认为 50000-50100）。

### 第三步：修改密码

修改 `secrets` 目录中的配置文件：

- `vsftpd-user-name`：vsftpd 用户名称（默认为 `vsftpd`）
- `vsftpd-user-pwd`：vsftpd 用户密码

> 提示：在生产环境中，请务必修改默认密码，并确保使用强密码，使用用户级权限进行访问。

### 第四步：配置网站

配置 Caddy 网站，将 `services/caddy/Caddyfile` 中的 `:80` 替换为您的域名，并根据实际情况配置 SSL 证书。

### 第五步：构建容器

构建并后台运行全部容器：

```bash
docker compose up -d
```

### 第六步：网站浏览

- 本地环境：`http://127.0.0.1`
- 线上环境：`http://<服务器 IP 地址>`

## 📦 镜像列表

### 构建的镜像

| 镜像名称 | 官方镜像 | 分发镜像 | 镜像标签 | 构建时间 |
| :--- | :--- | :--- | :--- | :--- |
| Caddy | `seatonjiang/caddy` | `ghcr.io/seatonjiang/caddy` <br> `docker.cnb.cool/seatonjiang/vsftpd/caddy` | alpine | 2026-04-06 |
| vsftpd | `seatonjiang/vsftpd` | `ghcr.io/seatonjiang/vsftpd` <br> `docker.cnb.cool/seatonjiang/vsftpd/vsftpd` | alpine | 2026-04-06 |

## 📂 目录结构

项目目录结构说明：

```bash
vsftpd
├── data                            数据持久化目录
│   ├── caddy                       Caddy 数据目录
│   └── vsftpd                      vsftpd 数据目录
├── logs                            日志存储目录
│   ├── caddy                       Caddy 日志目录
│   └── vsftpd                      vsftpd 日志目录
├── secrets                         密钥配置目录
│   ├── vsftpd-user-name            vsftpd 用户名称
│   └── vsftpd-user-pwd             vsftpd 用户密码
├── services                        服务配置目录
│   ├── caddy                       Caddy 配置目录
│   └── vsftpd                      vsftpd 配置目录
├── compose.yaml                    Docker Compose 配置文件
└── env.example                     环境配置示例文件
```

## 💻 管理命令

### 进入容器

运维过程中经常会使用 `docker exec -it` 进入容器，下面是常用的命令：

```bash
# 进入运行中的 Caddy 容器
docker exec -it caddy /bin/sh

# 进入运行中的 vsftpd 容器
docker exec -it vsftpd /bin/sh
```

## 📚 常见问题

### Caddy 自动配置 SSL 证书

要在 Caddy 中自动配置 SSL 证书（以 `example.com` 域名为例），请按照以下步骤操作：

#### 第一步：添加证书配置

在 `services/caddy/Caddyfile` 文件中添加证书配置，如果已经手动配置了证书，需要将 `tls` 部分改为以下内容：

```caddyfile
example.com {
    ...
    # 手动配置证书（如果已配置证书，需要将这行注释掉）
    # tls /etc/caddy/ssl/example.com.crt /etc/caddy/ssl/example.com.key

    # 自动配置证书（以腾讯云 DNS 为例）
    tls name@example.com {
        dns tencentcloud {
            secret_id <TENCENTCLOUD_SECRET_ID>
            secret_key <TENCENTCLOUD_SECRET_KEY>
        }
    }
    ...
}
```

Caddy 镜像编译了以下 DNS 模块：

- `dns.providers.tencentcloud`
- `dns.providers.alidns`
- `dns.providers.route53`
- `dns.providers.cloudflare`
- `dns.providers.godaddy`
- `dns.providers.digitalocean`

可以根据实际情况选择不同的 DNS 提供商，以下是各个供应商的配置示例：

```caddyfile
# 腾讯云 DNS
dns tencentcloud {
    secret_id <TENCENTCLOUD_SECRET_ID>
    secret_key <TENCENTCLOUD_SECRET_KEY>
}

# 阿里云 DNS
dns alidns {
    access_key_id <ALIYUN_ACCESS_KEY_ID>
    access_key_secret <ALIYUN_ACCESS_KEY_SECRET>
}

# Route53 DNS
dns route53 {
    access_key_id <AWS_ACCESS_KEY_ID>
    secret_access_key <AWS_SECRET_ACCESS_KEY>
}

# Cloudflare DNS
dns cloudflare <CF_API_TOKEN>

# Godaddy DNS
dns godaddy {
    api_token <GODADDY_API_TOKEN>
}

# DigitalOcean DNS
dns digitalocean <DIGITALOCEAN_API_TOKEN>
```

#### 第二步：重新加载

```bash
docker exec -w /etc/caddy caddy caddy reload
```

#### 第三步：测试访问

在浏览器中输入 `https://example.com` 测试网站是否正常访问。

## 💖 项目支持

如果这个项目为你带来了便利，请考虑为这个项目点个 Star 或者通过微信赞赏码支持我，每一份支持都是我持续优化和添加新功能的动力源泉！

<div align="center">
    <b>微信赞赏码</b>
    <br>
    <img src=".github/assets/wechat-reward.png" width="230">
</div>

## 🤝 参与共建

我们欢迎所有的贡献，你可以将任何想法作为 [Pull Requests](https://github.com/seatonjiang/vsftpd/pulls) 或 [Issues](https://github.com/seatonjiang/vsftpd/issues) 提交。

## 📃 开源许可

项目基于 MIT 许可证发布，详细说明请参阅 [LICENSE](https://github.com/seatonjiang/vsftpd/blob/main/LICENSE) 文件。
