#!/bin/bash

# Simple startup script for RAGLLM Test Suite
# Author: Ken Li

# Directory paths
BASE_DIR="/home/ken/NXP_RAGLLM_TEST"
FRONTEND_DIR="$BASE_DIR/ragllm-dashboard"

# Kill processes using ports 3333 and 3000 if any
echo "Killing any processes using ports 3333 and 3000..."
fuser -k 3333/tcp 2>/dev/null
fuser -k 3000/tcp 2>/dev/null

# Install dependencies if needed
echo "Checking and installing dependencies..."
if [ ! -d "$BASE_DIR/node_modules" ]; then
    cd "$BASE_DIR" && npm install
fi

if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
    cd "$FRONTEND_DIR" && npm install
fi

# Start backend
echo "Starting backend service on port 3333..."
cd "$BASE_DIR" && node backend-code.js &
BACKEND_PID=$!

# Wait a bit for backend to start
sleep 3

# Start frontend
echo "Starting frontend service on port 3000..."
cd "$FRONTEND_DIR" && npm run dev &
FRONTEND_PID=$!

# Display access information
echo "Services started!"
echo "Backend API address: http://10.193.21.115:3333"
echo "Frontend access address: http://10.193.21.115:3000"
echo "Press Ctrl+C to stop services"

# Cleanup function
cleanup() {
    echo "Stopping services..."
    kill $FRONTEND_PID $BACKEND_PID 2>/dev/null
    echo "All services stopped"
    exit 0
}

# Set cleanup hook
trap cleanup SIGINT SIGTERM

# Keep script running
wait
