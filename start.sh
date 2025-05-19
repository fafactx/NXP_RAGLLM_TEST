#!/bin/bash

# Startup script - For starting the RAGLLM Test Suite backend and frontend applications
# Author: Ken Li
# Date: 2023

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Show help information
show_help() {
    echo -e "${GREEN}RAGLLM Test Suite Startup Script${NC}"
    echo -e "Used to start the RAGLLM Test Suite backend and frontend services"
    echo
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  $0 [options]"
    echo
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  --help, -h       Display this help information and exit"
    echo -e "  --backend-only   Start only the backend service"
    echo -e "  --frontend-only  Start only the frontend service"
    echo -e "  --no-check       Skip port checking"
    echo -e "  --force-kill     Automatically kill processes occupying ports, without asking"
    echo
    echo -e "${YELLOW}Specific Examples:${NC}"
    echo -e "  1. Start the complete application (backend + frontend):"
    echo -e "     $ ./start.sh"
    echo
    echo -e "  2. Start only the backend service:"
    echo -e "     $ ./start.sh --backend-only"
    echo
    echo -e "  3. Start only the frontend service:"
    echo -e "     $ ./start.sh --frontend-only"
    echo
    echo -e "  4. Start services and automatically kill processes occupying ports:"
    echo -e "     $ ./start.sh --force-kill"
    echo
    echo -e "  5. Skip port checking and start services directly:"
    echo -e "     $ ./start.sh --no-check"
    echo
    echo -e "  6. Combine multiple options:"
    echo -e "     $ ./start.sh --backend-only --force-kill"
    echo
    echo -e "${YELLOW}Port Settings:${NC}"
    echo -e "  Backend port: $BACKEND_HOST:$BACKEND_PORT"
    echo -e "  Frontend port: $FRONTEND_HOST:$FRONTEND_PORT"
    echo
    echo -e "${YELLOW}Directory Settings:${NC}"
    echo -e "  Backend directory: $BASE_DIR"
    echo -e "  Frontend directory: $FRONTEND_DIR"
    echo
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo -e "  1. Port is in use:"
    echo -e "     $ lsof -i :3333          # Find process occupying backend port"
    echo -e "     $ kill -9 <PID>          # Kill the process"
    echo -e "     $ ./start.sh             # Restart services"
    echo
    echo -e "  2. Dependency installation failure:"
    echo -e "     $ cd $BASE_DIR           # Go to backend directory"
    echo -e "     $ npm install            # Manually install backend dependencies"
    echo -e "     $ cd $FRONTEND_DIR       # Go to frontend directory"
    echo -e "     $ npm install            # Manually install frontend dependencies"
    echo -e "     $ ./start.sh             # Restart services"
    echo
    echo -e "  3. View running logs:"
    echo -e "     $ ps aux | grep node     # View running Node.js processes"
    echo -e "     $ tail -f nohup.out      # If started with nohup, view output logs"
    echo
    echo -e "${YELLOW}Notes:${NC}"
    echo -e "  1. Ensure Node.js is installed (v16+ recommended)"
    echo -e "  2. Ensure ports are not in use"
    echo -e "  3. Press Ctrl+C to stop all services"
    echo -e "  4. First run may take longer to install dependencies"
    echo
}

# Check if directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        log_error "Directory $1 does not exist!"
        exit 1
    fi
}

# Check if Node.js is installed
check_nodejs() {
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed! Please install Node.js before running this script."
        exit 1
    fi

    log_info "Node.js version: $(node -v)"
    log_info "NPM version: $(npm -v)"
}

# Check if port is in use
check_port() {
    local port=$1
    local address=$2

    # If no address is specified, use 0.0.0.0 (all addresses)
    if [ -z "$address" ]; then
        address="0.0.0.0"
    fi

    # Check if port is in use
    if netstat -tuln | grep -q "$address:$port"; then
        return 0 # Port is in use
    else
        return 1 # Port is not in use
    fi
}

# Kill process occupying a port
kill_process_on_port() {
    local port=$1
    local address=$2

    # If no address is specified, use 0.0.0.0 (all addresses)
    if [ -z "$address" ]; then
        address="0.0.0.0"
    fi

    log_warning "Port $address:$port is in use, attempting to kill the process..."

    # Find PID of process occupying the port
    local pid=$(netstat -tulnp | awk -v port="$PORT" '$4 ~ ":"port"$" {split($7,a,/\/); print a[1]}'
)

    if [ -z "$pid" ]; then
        log_error "Cannot find process occupying port $port!"
        return 1
    fi

    # Kill the process
    kill -9 $pid 2>/dev/null

    if [ $? -eq 0 ]; then
        log_success "Successfully killed process occupying port $port (PID: $pid)"
        return 0
    else
        log_error "Cannot kill process occupying port $port (PID: $pid)"
        return 1
    fi
}

# Check if dependencies are installed
check_dependencies() {
    local dir=$1

    if [ ! -d "$dir/node_modules" ]; then
        log_warning "Dependencies not installed, installing now..."
        cd "$dir" && npm install
        if [ $? -ne 0 ]; then
            log_error "Dependency installation failed!"
            exit 1
        fi
        log_success "Dependencies installed successfully!"
    else
        log_info "Dependencies already installed."
    fi
}

# Start backend
start_backend() {
    log_info "Starting backend service..."

    # Check backend directory
    check_directory "$BASE_DIR"

    # Check backend dependencies
    check_dependencies "$BASE_DIR"

    # Check if backend port is in use
    if check_port $BACKEND_PORT $BACKEND_HOST; then
        log_warning "Backend port $BACKEND_HOST:$BACKEND_PORT is in use!"

        # Ask user if they want to kill the process
        read -p "Kill the process occupying the port? (y/n): " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            if ! kill_process_on_port $BACKEND_PORT $BACKEND_HOST; then
                log_error "Cannot free port $BACKEND_HOST:$BACKEND_PORT, please manually close the process and try again."
                exit 1
            fi
        else
            log_error "Port $BACKEND_HOST:$BACKEND_PORT is in use, cannot start backend service."
            exit 1
        fi
    fi

    # Start backend service
    cd "$BASE_DIR" && node backend-code.js &
    BACKEND_PID=$!

    # Check if backend started successfully
    sleep 3
    if ps -p $BACKEND_PID > /dev/null; then
        log_success "Backend service started, PID: $BACKEND_PID"
    else
        log_error "Backend service failed to start!"
        exit 1
    fi
}

# Start frontend
start_frontend() {
    log_info "Starting frontend service..."

    # Check frontend directory
    check_directory "$FRONTEND_DIR"

    # Check frontend dependencies
    check_dependencies "$FRONTEND_DIR"

    # Create a named pipe for capturing output
    PIPE_FILE="/tmp/frontend_pipe_$$"
    mkfifo "$PIPE_FILE"

    # Start a background process to read from the pipe and capture the port
    {
        # Read from the pipe and look for the port
        while read line; do
            echo "$line" >> "$FRONTEND_DIR/frontend.log"

            # Check if the line contains the network URL
            if echo "$line" | grep -q "Network:"; then
                # Extract the actual port
                actual_port=$(echo "$line" | grep -o ":[0-9]\+" | grep -o "[0-9]\+")
                if [ ! -z "$actual_port" ]; then
                    # Save the actual port to a file so the main process can read it
                    echo "$actual_port" > "/tmp/frontend_port_$$"
                fi
            fi
        done < "$PIPE_FILE"

        # Remove the pipe when done
        rm -f "$PIPE_FILE"
    } &
    PIPE_READER_PID=$!

    # Start frontend service and redirect output to the pipe
    cd "$FRONTEND_DIR" && npm run dev > "$PIPE_FILE" 2>&1 &
    FRONTEND_PID=$!

    # Wait for Vite to start and detect the actual port
    local max_wait=30
    local waited=0

    while [ $waited -lt $max_wait ]; do
        # Check if the process is still running
        if ! ps -p $FRONTEND_PID > /dev/null; then
            log_error "Frontend service failed to start!"
            kill $PIPE_READER_PID 2>/dev/null
            rm -f "$PIPE_FILE" "/tmp/frontend_port_$$"
            exit 1
        fi

        # Check if we've detected the port
        if [ -f "/tmp/frontend_port_$$" ]; then
            FRONTEND_PORT=$(cat "/tmp/frontend_port_$$")
            rm -f "/tmp/frontend_port_$$"
            log_info "Detected frontend running on port: $FRONTEND_PORT"
            break
        fi

        sleep 1
        waited=$((waited + 1))
    done

    # If we couldn't detect the port after max_wait, use the default
    if [ $waited -eq $max_wait ]; then
        log_warning "Could not detect the actual frontend port within $max_wait seconds, using default: $FRONTEND_PORT"
    fi

    # Check if frontend started successfully
    if ps -p $FRONTEND_PID > /dev/null; then
        log_success "Frontend service started, PID: $FRONTEND_PID"
    else
        log_error "Frontend service failed to start!"
        kill $PIPE_READER_PID 2>/dev/null
        rm -f "$PIPE_FILE" "/tmp/frontend_port_$$"
        exit 1
    fi
}

# Show access information
show_access_info() {
    log_info "Services started!"
    log_info "Backend API address: http://$BACKEND_HOST:$BACKEND_PORT"
    log_info "Frontend access address: http://$FRONTEND_HOST:$FRONTEND_PORT"
    log_info "Press Ctrl+C to stop services"
}

# Cleanup function
cleanup() {
    log_info "Stopping services..."

    # Stop frontend service
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
        log_success "Frontend service stopped"
    fi

    # Stop pipe reader process if it exists
    if [ ! -z "$PIPE_READER_PID" ]; then
        kill $PIPE_READER_PID 2>/dev/null
    fi

    # Stop backend service
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
        log_success "Backend service stopped"
    fi

    # Clean up temporary files
    rm -f "/tmp/frontend_pipe_$$" "/tmp/frontend_port_$$"

    log_success "All services stopped"
    exit 0
}

# Set cleanup hook
trap cleanup SIGINT SIGTERM

# Parse command line arguments
parse_args() {
    # Default values
    BACKEND_ONLY=false
    FRONTEND_ONLY=false
    NO_CHECK=false
    FORCE_KILL=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --backend-only)
                BACKEND_ONLY=true
                ;;
            --frontend-only)
                FRONTEND_ONLY=true
                ;;
            --no-check)
                NO_CHECK=true
                ;;
            --force-kill)
                FORCE_KILL=true
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done

    # If both backend-only and frontend-only are specified, show error
    if $BACKEND_ONLY && $FRONTEND_ONLY; then
        log_error "Cannot specify both --backend-only and --frontend-only"
        show_help
        exit 1
    fi
}

# Main function
main() {
    log_info "Starting RAGLLM Test Suite..."

    npm install

    wait
    # Parse command line arguments
    parse_args "$@"

    # Check Node.js
    check_nodejs

    # Start backend if not frontend-only
    if ! $FRONTEND_ONLY; then
        start_backend
    fi

    # Start frontend if not backend-only
    if ! $BACKEND_ONLY; then
        start_frontend
    fi

    # Show access information
    show_access_info

    # Keep script running
    wait
}

# Set directory paths
BASE_DIR="/home/ken/NXP_RAGLLM_TEST"
FRONTEND_DIR="$BASE_DIR/ragllm-dashboard"

# Set ports and hosts
BACKEND_HOST="10.193.21.115"
BACKEND_PORT="3333"
FRONTEND_HOST="10.193.21.115"
FRONTEND_PORT="3000"

# Execute main function with all arguments
main "$@"
