FROM node:22-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl wget git nginx apache2-utils \
    && rm -rf /var/lib/apt/lists/*

# Install ttyd
RUN wget -qO /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 \
    && chmod +x /usr/local/bin/ttyd

# Install Codex CLI + OpenCode (fallback)
RUN npm install -g @openai/codex

# Basic auth user:server38
RUN htpasswd -cb /etc/nginx/.htpasswd user server38

# Nginx reverse proxy -> ttyd 7681
RUN printf 'server {\n\
    listen 8080;\n\
    location / {\n\
        auth_basic "Codex Terminal - user/server38";\n\
        auth_basic_user_file /etc/nginx/.htpasswd;\n\
        proxy_pass http://127.0.0.1:7681;\n\
        proxy_http_version 1.1;\n\
        proxy_set_header Upgrade $http_upgrade;\n\
        proxy_set_header Connection "upgrade";\n\
        proxy_set_header Host $host;\n\
        proxy_set_header X-Real-IP $remote_addr;\n\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\
        proxy_set_header X-Forwarded-Proto $scheme;\n\
        proxy_read_timeout 86400;\n\
    }\n\
}\n' > /etc/nginx/sites-available/default

RUN mkdir -p /workspace /root/.codex
WORKDIR /workspace

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
