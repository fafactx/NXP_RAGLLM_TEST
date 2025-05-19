#!/bin/bash

# 启动脚本 - 用于启动RAGLLM测试套件的后端和前端应用
# 作者: Ken Li
# 日期: 2023

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查目录是否存在
check_directory() {
    if [ ! -d "$1" ]; then
        log_error "目录 $1 不存在!"
        exit 1
    fi
}

# 检查Node.js是否安装
check_nodejs() {
    if ! command -v node &> /dev/null; then
        log_error "Node.js未安装! 请安装Node.js后再运行此脚本。"
        exit 1
    fi
    
    log_info "Node.js版本: $(node -v)"
    log_info "NPM版本: $(npm -v)"
}

# 检查依赖是否安装
check_dependencies() {
    local dir=$1
    
    if [ ! -d "$dir/node_modules" ]; then
        log_warning "依赖未安装，正在安装..."
        cd "$dir" && npm install
        if [ $? -ne 0 ]; then
            log_error "依赖安装失败!"
            exit 1
        fi
        log_success "依赖安装成功!"
    else
        log_info "依赖已安装."
    fi
}

# 启动后端
start_backend() {
    log_info "正在启动后端服务..."
    
    # 检查后端目录
    check_directory "$BASE_DIR"
    
    # 检查后端依赖
    check_dependencies "$BASE_DIR"
    
    # 启动后端服务
    cd "$BASE_DIR" && node backend-code.js &
    BACKEND_PID=$!
    
    # 检查后端是否成功启动
    sleep 3
    if ps -p $BACKEND_PID > /dev/null; then
        log_success "后端服务已启动，PID: $BACKEND_PID"
    else
        log_error "后端服务启动失败!"
        exit 1
    fi
}

# 启动前端
start_frontend() {
    log_info "正在启动前端服务..."
    
    # 检查前端目录
    check_directory "$FRONTEND_DIR"
    
    # 检查前端依赖
    check_dependencies "$FRONTEND_DIR"
    
    # 启动前端服务
    cd "$FRONTEND_DIR" && npm run dev &
    FRONTEND_PID=$!
    
    # 检查前端是否成功启动
    sleep 5
    if ps -p $FRONTEND_PID > /dev/null; then
        log_success "前端服务已启动，PID: $FRONTEND_PID"
    else
        log_error "前端服务启动失败!"
        exit 1
    fi
}

# 显示访问信息
show_access_info() {
    log_info "服务已启动!"
    log_info "后端API地址: http://10.193.21.115:3333"
    log_info "前端访问地址: http://10.193.21.115:3000"
    log_info "按 Ctrl+C 停止服务"
}

# 清理函数
cleanup() {
    log_info "正在停止服务..."
    
    # 停止前端服务
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
        log_success "前端服务已停止"
    fi
    
    # 停止后端服务
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
        log_success "后端服务已停止"
    fi
    
    log_success "所有服务已停止"
    exit 0
}

# 设置清理钩子
trap cleanup SIGINT SIGTERM

# 主函数
main() {
    log_info "正在启动RAGLLM测试套件..."
    
    # 检查Node.js
    check_nodejs
    
    # 启动后端
    start_backend
    
    # 启动前端
    start_frontend
    
    # 显示访问信息
    show_access_info
    
    # 保持脚本运行
    wait
}

# 设置目录路径
BASE_DIR="/home/ken/NXP_RAGLLM_TEST"
FRONTEND_DIR="$BASE_DIR/ragllm-dashboard"

# 执行主函数
main
