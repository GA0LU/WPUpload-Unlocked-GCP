#!/bin/bash

#=============================================================================
#  WPUpload-Unlocked-GCP.sh
#  WordPress Upload Limit Configuration Tool for Google Cloud Platform
#  Version: 1.0
#  Author: Your Name
#  Description: Automatically configures PHP upload limits for WordPress on GCP
#  Usage: sudo ./WPUpload-Unlocked-GCP.sh [--force] [--c <size>]
#         wget -qO- https://raw.githubusercontent.com/GA0LU/WPUpload-Unlocked-GCP/main/WPUpload-Unlocked-GCP.sh | sudo bash
#=============================================================================

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# 初始化变量
FORCE_MODE=false
CUSTOM_SIZE=""

# 处理命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_MODE=true
            shift
            ;;
        --c)
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                CUSTOM_SIZE="$2"
                shift 2
            else
                echo "Error: --c requires a numeric value"
                exit 1
            fi
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Usage: sudo ./WPUpload-Unlocked-GCP.sh [--force] [--c <size>]"
            exit 1
            ;;
    esac
done

# 检查是否在管道中运行
if [ ! -t 0 ]; then
    echo "Running in non-interactive mode (pipeline)"
    if [ -n "$CUSTOM_SIZE" ]; then
        echo "Using custom upload size: ${CUSTOM_SIZE}MB"
        upload_size="$CUSTOM_SIZE"
    else
        echo "Using default values:"
        echo "- Upload size: 1024MB (1GB)"
        echo "- Memory limit: 2048MB (2GB)"
        echo "- Timeout: 600 seconds"
        upload_size=1024
    fi
    FORCE_MODE=true
fi

# ASCII Art Logo
echo "
                                                       
       _ _ _ _____     _____     _           _         
      | | | |  _  |___|  |  |___| |___ ___ _| |        
      | | | |   __|___|  |  | . | | . | .'| . |        
      |_____|__|      |_____|  _|_|___|__,|___|        
                            |_|                        
                                                       
 _____     _         _         _     _____ _____ _____ 
|  |  |___| |___ ___| |_ ___ _| |___|   __|     |  _  |
|  |  |   | | . |  _| '_| -_| . |___|  |  |   --|   __|
|_____|_|_|_|___|___|_,_|___|___|   |_____|_____|__|   
                                                       
"

# 检测PHP版本的函数
detect_php_version() {
    local php_ini_path=""
    
    # 首先尝试使用php -v命令检测
    if command -v php >/dev/null 2>&1; then
        local php_version=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
        if [ -f "/etc/php/${php_version}/fpm/php.ini" ]; then
            php_ini_path="/etc/php/${php_version}/fpm/php.ini"
            echo "$php_ini_path"
            return 0
        fi
    fi
    
    # 如果php -v命令失败，尝试查找所有PHP-FPM配置文件
    if [ -d "/etc/php" ]; then
        # 查找所有php.ini文件
        local php_ini_files=$(find /etc/php -name "php.ini" -type f 2>/dev/null)
        
        # 按版本号排序，选择最新的版本
        local latest_version=""
        local latest_path=""
        
        for ini_file in $php_ini_files; do
            if [[ $ini_file =~ /etc/php/([0-9]+\.[0-9]+)/ ]]; then
                local version="${BASH_REMATCH[1]}"
                if [ -z "$latest_version" ] || [ "$(printf '%s\n' "$version" "$latest_version" | sort -V | tail -n1)" = "$version" ]; then
                    latest_version="$version"
                    latest_path="$ini_file"
                fi
            fi
        done
        
        if [ -n "$latest_path" ]; then
            php_ini_path="$latest_path"
            echo "$php_ini_path"
            return 0
        fi
    fi
    
    # 如果还是没找到，尝试使用php-fpm命令
    if command -v php-fpm >/dev/null 2>&1; then
        local php_fpm_version=$(php-fpm -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
        if [ -f "/etc/php/${php_fpm_version}/fpm/php.ini" ]; then
            php_ini_path="/etc/php/${php_fpm_version}/fpm/php.ini"
            echo "$php_ini_path"
            return 0
        fi
    fi
    
    return 1
}

# 检测Web服务器类型
detect_web_server() {
    if systemctl is-active --quiet apache2; then
        echo "apache2"
    elif systemctl is-active --quiet nginx; then
        echo "nginx"
    else
        echo "unknown"
    fi
}

# 检测PHP-FPM服务名称
detect_php_fpm_service() {
    local version=$1
    local service_name=""
    
    # 尝试不同的服务名称格式
    local possible_names=(
        "php${version}-fpm"
        "php-fpm"
        "php${version//.}fpm"
    )
    
    for name in "${possible_names[@]}"; do
        if systemctl list-units --type=service | grep -q "${name}.service"; then
            service_name=$name
            break
        fi
    done
    
    echo "$service_name"
}

# 根据上传文件大小计算内存限制的函数
calculate_memory_limit() {
    local upload_size=$1
    # 将MB转换为字节进行比较
    local upload_bytes=$((upload_size * 1024 * 1024))
    
    if [ $upload_bytes -gt 1073741824 ]; then  # 如果大于1GB
        echo $((upload_size * 2))  # 将内存限制设置为上传大小的两倍
    else
        echo 128  # 默认128MB
    fi
}

# 根据上传文件大小计算超时时间的函数
calculate_timeout() {
    local upload_size=$1
    # 将MB转换为字节进行比较
    local upload_bytes=$((upload_size * 1024 * 1024))
    
    if [ $upload_bytes -gt 1073741824 ]; then  # 如果大于1GB
        echo 600  # 设置为10分钟
    else
        echo 300  # 默认5分钟
    fi
}

# 验证输入是否为有效数字的函数
validate_input() {
    local input=$1
    if [[ ! "$input" =~ ^[0-9]+$ ]] || [ "$input" -lt 1 ]; then
        return 1
    fi
    return 0
}

# 打印欢迎信息
echo "Welcome to WordPress Upload Limit Configuration Tool"
echo "This script will help you modify PHP configuration for file upload limits."
echo "----------------------------------------"

# 检测PHP版本和配置文件路径
PHP_INI=$(detect_php_version)
if [ -z "$PHP_INI" ]; then
    echo "Error: Could not detect PHP version or find PHP configuration file."
    echo "Please make sure PHP-FPM is installed on your system."
    exit 1
fi

# 获取PHP版本号
PHP_VERSION=$(echo "$PHP_INI" | grep -oP '\d+\.\d+')
echo "Detected PHP version: ${PHP_VERSION}"

# 检测Web服务器
WEB_SERVER=$(detect_web_server)
if [ "$WEB_SERVER" = "unknown" ]; then
    echo "Warning: Could not detect web server type."
    echo "Please make sure Apache2 or Nginx is installed and running."
    exit 1
fi
echo "Detected web server: ${WEB_SERVER}"

# 请求用户输入上传大小
if [ "$FORCE_MODE" = false ]; then
    while true; do
        echo "Please enter the maximum upload file size in MB (default: 1024MB = 1GB)"
        echo "Press Enter for default value or enter a custom value:"
        read -r upload_size
        
        if [ -z "$upload_size" ]; then
            upload_size=1024
            break
        fi
        
        if validate_input "$upload_size"; then
            break
        else
            echo "Invalid input. Please enter a positive number."
        fi
    done
else
    if [ -n "$CUSTOM_SIZE" ]; then
        upload_size="$CUSTOM_SIZE"
    else
        upload_size=1024  # 强制模式下使用默认值
    fi
fi

# 计算其他参数
memory_limit=$(calculate_memory_limit "$upload_size")
timeout=$(calculate_timeout "$upload_size")

# 显示将要应用的配置
echo "----------------------------------------"
echo "The following configuration will be applied:"
echo "upload_max_filesize = ${upload_size}M"
echo "post_max_size = ${upload_size}M"
echo "memory_limit = ${memory_limit}M"
echo "max_execution_time = ${timeout}"
echo "max_input_time = ${timeout}"
echo "----------------------------------------"

# 检查PHP配置文件是否存在
if [ ! -f "$PHP_INI" ]; then
    echo "Error: PHP configuration file not found at $PHP_INI"
    exit 1
fi

# 检查配置文件目录是否可写
if [ ! -w "$(dirname "$PHP_INI")" ]; then
    echo "Error: No write permission for PHP configuration directory"
    exit 1
fi

# 备份原始配置文件
backup_dir="/etc/php/backups"
if [ ! -d "$backup_dir" ]; then
    mkdir -p "$backup_dir"
fi

backup_file="${backup_dir}/php.ini.backup.$(date +%Y%m%d_%H%M%S)"
if ! cp "$PHP_INI" "$backup_file"; then
    echo "Error: Failed to create backup of PHP configuration file"
    exit 1
fi

# 更新配置（使用临时文件避免sed兼容性问题）
temp_file=$(mktemp)
cp "$PHP_INI" "$temp_file"

# 使用更健壮的sed命令，支持注释和缩进
sed -i.bak -E "s/^\s*;?\s*upload_max_filesize\s*=.*/upload_max_filesize = ${upload_size}M/" "$temp_file"
sed -i.bak -E "s/^\s*;?\s*post_max_size\s*=.*/post_max_size = ${upload_size}M/" "$temp_file"
sed -i.bak -E "s/^\s*;?\s*memory_limit\s*=.*/memory_limit = ${memory_limit}M/" "$temp_file"
sed -i.bak -E "s/^\s*;?\s*max_execution_time\s*=.*/max_execution_time = ${timeout}/" "$temp_file"
sed -i.bak -E "s/^\s*;?\s*max_input_time\s*=.*/max_input_time = ${timeout}/" "$temp_file"

# 检查sed是否成功
if [ $? -ne 0 ]; then
    echo "Error: Failed to update configuration"
    rm -f "$temp_file" "$temp_file.bak"
    exit 1
fi

# 移动临时文件到实际配置文件
mv "$temp_file" "$PHP_INI"
rm -f "$temp_file.bak"  # 删除不需要的备份文件

# 检测PHP-FPM服务名称
PHP_FPM_SERVICE=$(detect_php_fpm_service "$PHP_VERSION")
if [ -z "$PHP_FPM_SERVICE" ]; then
    echo "Error: Could not detect PHP-FPM service name"
    exit 1
fi

# 询问用户是否要重启服务
if [ "$FORCE_MODE" = false ]; then
    echo "Configuration has been updated successfully."
    echo "Do you want to restart PHP-FPM and ${WEB_SERVER} services to apply changes? (Y/n)"
    read -r restart_services
else
    restart_services="y"  # 强制模式下自动重启服务
fi

if [[ -z "$restart_services" || "$restart_services" =~ ^[Yy]$ ]]; then
    echo "Restarting services..."
    
    # 重启PHP-FPM服务
    if systemctl restart "$PHP_FPM_SERVICE"; then
        echo "PHP-FPM service restarted successfully"
    else
        echo "Warning: Failed to restart PHP-FPM service"
    fi
    
    # 重启Web服务器
    if systemctl restart "$WEB_SERVER"; then
        echo "${WEB_SERVER} service restarted successfully"
    else
        echo "Warning: Failed to restart ${WEB_SERVER} service"
    fi
fi

echo "----------------------------------------"
echo "Configuration completed successfully!"
echo "Backup of original configuration saved as: $backup_file"
echo "----------------------------------------" 
