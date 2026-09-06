FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl wget git nginx apache2-utils \
    && rm -rf /var/lib/apt/lists/*

# Install ttyd from pre-built binary
RUN wget -qO /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 \
    && chmod +x /usr/local/bin/ttyd

# Install OpenCode via official installer
RUN curl -fsSL https://opencode.ai/install | bash
ENV PATH="/root/.opencode/bin:$PATH"

# Create nginx basic auth (user: server38)
RUN htpasswd -cb /etc/nginx/.htpasswd user server38

# Setup workspace
RUN mkdir -p /workspace /root/.config/opencode /root/.local/share/opencode
WORKDIR /workspace

COPY nginx.conf /etc/nginx/sites-available/default
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
