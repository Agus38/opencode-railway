#!/bin/bash
# OpenHands Agent Canvas + nginx basic auth (user:server38)
set -e

PORT=${PORT:-8080}
echo "=== OpenHands Agent Canvas ==="
echo "External port: $PORT"
echo "Internal port: 8000"

# Start Agent Canvas in background on 8000
echo "Starting agent-canvas..."
mkdir -p /workspace /root/.openhands
agent-canvas &
AGENT_PID=$!
echo "agent-canvas PID $AGENT_PID"

# Give it a moment to start, then configure nginx
sleep 5

# Update nginx to listen on Railway's PORT
sed -i "s/listen 8080/listen $PORT/" /etc/nginx/sites-available/default
echo "nginx configured for port $PORT"

# Remove default nginx site if exists on 80
rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default 2>/dev/null || true

# Test nginx config
nginx -t

# Start nginx in foreground (will proxy to agent-canvas)
echo "Starting nginx..."
exec nginx -g "daemon off;"
