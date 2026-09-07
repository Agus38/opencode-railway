#!/bin/bash
PORT=${PORT:-8080}
echo "=== Codex CLI Terminal ==="
echo "External: $PORT -> ttyd:7681"
echo "Login: user / server38"
echo "Bitdeer: OPENAI_BASE_URL=https://api-inference.bitdeer.ai/v1"
echo "OpenRouter: OPENAI_BASE_URL=https://openrouter.ai/api/v1"
echo "Set: export OPENAI_API_KEY=xxx && export OPENAI_BASE_URL=... && codex"

# Decrypt old OpenHands keys if exists
mkdir -p /workspace

# ttyd on 7681
ttyd -p 7681 --writable \
    -t fontSize=14 \
    -t fontFamily="monospace" \
    -t theme='{"background":"#1a1b26","foreground":"#a9b1d6"}' \
    -t cursorBlink=true \
    bash -c 'export PATH="/usr/local/bin:$PATH"; cd /workspace; echo "=== Codex Ready ==="; echo "Bitdeer: export OPENAI_API_KEY=\$BITDEER_KEY && export OPENAI_BASE_URL=https://api-inference.bitdeer.ai/v1 && codex --model Qwen/Qwen3.5-397B-A17B"; echo "OpenRouter: export OPENAI_API_KEY=\$OR_KEY && export OPENAI_BASE_URL=https://openrouter.ai/api/v1 && codex --model minimax/minimax-m2.7:free"; exec bash' &

sed -i "s/listen 8080/listen $PORT/" /etc/nginx/sites-available/default
nginx -t
exec nginx -g "daemon off;"
