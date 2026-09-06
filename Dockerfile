FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl wget git build-essential cmake \
    libevent-dev libncurses-dev libjson-c-dev libwebsockets-dev \
    && rm -rf /var/lib/apt/lists/*

# Install tmux
RUN wget -q https://github.com/tmux/tmux/releases/download/3.4/tmux-3.4.tar.gz \
    && tar -xzf tmux-3.4.tar.gz \
    && cd tmux-3.4 && ./configure && make && make install \
    && cd .. && rm -rf tmux-3.4 tmux-3.4.tar.gz

# Install ttyd
RUN git clone https://github.com/nicm/ttyd.git /tmp/ttyd \
    && cd /tmp/ttyd && mkdir build && cd build \
    && cmake .. && make && make install \
    && cd / && rm -rf /tmp/ttyd

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# Install OpenCode
RUN git clone https://github.com/anomalyco/opencode.git /opt/opencode
WORKDIR /opt/opencode
RUN bun install --production

# Setup workspace
RUN mkdir -p /workspace /root/.config/opencode /root/.local/share/opencode
WORKDIR /workspace

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 7681

CMD ["/start.sh"]
