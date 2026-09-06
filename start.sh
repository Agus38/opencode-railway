#!/bin/bash
# Start ttyd on internal port + nginx on external port with basic auth

PORT=${PORT:-8080}

echo "=== OpenCode Terminal ==="
echo "External port: $PORT"

# Start ttyd on internal port 7681
ttyd -p 7681 --writable \
    -t fontSize=14 \
    -t fontFamily="monospace" \
    -t theme='{"background":"#1a1b26","foreground":"#a9b1d6"}' \
    -t cursorBlink=true \
    bash -c 'export PATH="/root/.opencode/bin:$PATH" && cd /workspace && exec bash' &

# Update nginx to listen on Railway's assigned port
sed -i "s/listen 8080/listen $PORT/" /etc/nginx/sites-available/default

# Start nginx in foreground
exec nginx -g "daemon off;"
