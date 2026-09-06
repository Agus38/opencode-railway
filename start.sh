#!/bin/bash
# Start ttyd + nginx with basic auth

PORT=${PORT:-8080}

# Set default API key if not provided
if [ -z "$OPENAI_API_KEY" ] && [ -z "$ANTHROPIC_API_KEY" ] && [ -z "$GOOGLE_API_KEY" ]; then
    echo "=========================================="
    echo "  OpenCode - AI Coding Assistant"
    echo "=========================================="
    echo ""
    echo "  API Key belum dikonfigurasi!"
    echo ""
    echo "  Silakan set environment variable di Railway:"
    echo "  - OPENAI_API_KEY=sk-xxx"
    echo "  - ANTHROPIC_API_KEY=sk-ant-xxx"
    echo "  - GOOGLE_API_KEY=xxx"
    echo ""
    echo "  Atau jalankan opencode lalu set manual:"
    echo "  export OPENAI_API_KEY=sk-xxx"
    echo ""
    echo "=========================================="
fi

# Start ttyd on internal port 7681
ttyd -p 7681 --writable \
    -t fontSize=14 \
    -t fontFamily="monospace" \
    -t theme='{"background":"#1a1b26","foreground":"#a9b1d6"}' \
    -t cursorBlink=true \
    bash -c 'export PATH="/root/.opencode/bin:$PATH" && cd /workspace && exec bash' &

# Update nginx to listen on Railway's PORT
sed -i "s/listen 8080/listen $PORT/" /etc/nginx/sites-available/default

# Start nginx in foreground
exec nginx -g "daemon off;"
