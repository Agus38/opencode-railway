FROM node:22-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl wget git nginx apache2-utils python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install uv (required by agent-canvas)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install OpenHands Agent Canvas
RUN npm install -g @openhands/agent-canvas@1.16.0

# Create nginx basic auth (user: server38)
RUN htpasswd -cb /etc/nginx/.htpasswd user server38

# Nginx reverse proxy with basic auth -> agent-canvas on 8000
RUN printf 'server {\n\
    listen 8080;\n\
    location / {\n\
        auth_basic "OpenHands - Access Code: server38 (user/server38)";\n\
        auth_basic_user_file /etc/nginx/.htpasswd;\n\
        proxy_pass http://127.0.0.1:8000;\n\
        proxy_http_version 1.1;\n\
        proxy_set_header Upgrade $http_upgrade;\n\
        proxy_set_header Connection "upgrade";\n\
        proxy_set_header Host $host;\n\
        proxy_set_header X-Real-IP $remote_addr;\n\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n\
        proxy_set_header X-Forwarded-Proto $scheme;\n\
        proxy_read_timeout 86400;\n\
        proxy_send_timeout 86400;\n\
    }\n\
}\n' > /etc/nginx/sites-available/default

# Setup workspace
RUN mkdir -p /workspace /root/.openhands
WORKDIR /workspace

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
