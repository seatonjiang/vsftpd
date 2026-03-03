#!/bin/sh
set -e

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"
}

error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1"
    exit 1
}

# 读取 Secret 或环境变量
get_secret_or_env() {
    local secret_name="$1"
    local env_name="$2"
    local secret_path="/run/secrets/$secret_name"

    if [ -f "$secret_path" ]; then
        tr -d '\n\r' < "$secret_path"
    elif [ -n "$(eval echo \$$env_name)" ]; then
        eval echo \$$env_name
    else
        return 1
    fi
}

# 获取 FTP 用户名和密码
FTP_USER=$(get_secret_or_env "vsftpd-user-name" "FTP_USER") || error "未设置 FTP 用户名 (Secret: vsftpd-user-name 或 ENV: FTP_USER)"
FTP_PASS=$(get_secret_or_env "vsftpd-user-pwd" "FTP_PASS") || error "未设置 FTP 密码 (Secret: vsftpd-user-pwd 或 ENV: FTP_PASS)"

# 创建系统用户和组
log "配置 FTP 用户: $FTP_USER"

# 检查组是否存在，不存在则创建
if ! getent group "$FTP_USER" >/dev/null 2>&1; then
    addgroup -S "$FTP_USER"
fi

# 检查用户是否存在，不存在则创建
if ! id -u "$FTP_USER" >/dev/null 2>&1; then
    adduser -D -G "$FTP_USER" -h "/var/lib/ftp" -s /bin/false "$FTP_USER"
    log "已创建系统用户: $FTP_USER"
else
    log "用户 $FTP_USER 已存在，跳过创建"
fi

# 设置/更新密码
echo "$FTP_USER:$FTP_PASS" | chpasswd
log "已更新用户密码"

# 配置目录权限
FTP_ROOT="/var/lib/ftp"
if [ ! -d "$FTP_ROOT" ]; then
    mkdir -p "$FTP_ROOT"
    log "创建 FTP 根目录: $FTP_ROOT"
fi

# 确保目录权限正确
chown -R "$FTP_USER:$FTP_USER" "$FTP_ROOT"
chmod 755 "$FTP_ROOT"
log "已设置目录权限 (Owner: $FTP_USER, Mode: 755)"

# 配置被动模式地址
VSFTPD_CONF="/etc/vsftpd/vsftpd.conf"
if [ -n "$PASV_ADDRESS" ]; then
    log "配置被动模式地址: $PASV_ADDRESS"
    sed -i "s/^pasv_address=.*/pasv_address=${PASV_ADDRESS}/" "$VSFTPD_CONF"
fi

# 启动服务
log "启动 vsftpd 服务..."
exec vsftpd "$VSFTPD_CONF"
