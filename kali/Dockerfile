# Use the official Kali Linux rolling base image
FROM docker.io/kalilinux/kali-rolling:latest

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Build-time argument for the default user name
ARG USER_NAME=matir
ENV USER_NAME=$USER_NAME

# Update system and install apt packages
# Includes python3, pip, nodejs/npm (for gemini-cli/opencode), and kali-linux-headless
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    kali-linux-headless \
    nodejs \
    npm \
    curl \
    ca-certificates \
    git \
    zsh \
    sudo \
    tmux \
    bat \
    eza \
    jq \
    htop \
    ffuf \
    ripgrep \
    fzf \
    nuclei \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Add symlinks for common tools that might have different names in Debian/Ubuntu
RUN ln -s /usr/bin/batcat /usr/local/bin/bat 2>/dev/null || true

# Install uv (Fast Python package manager)
# Using the official binary for efficiency
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Install mise (Universal tool manager)
RUN curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh
# Add mise to PATH globally
ENV PATH="/usr/local/bin:$PATH"

# Install starship (Cross-shell prompt)
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install gemini-cli, opencode, and kilocode via npm
RUN npm install -g @google/gemini-cli opencode-ai @kilocode/cli

# Configure zsh template for new users (/etc/skel)
RUN touch /etc/skel/.zshrc && \
    echo 'eval "$(starship init zsh)"' >> /etc/skel/.zshrc && \
    echo 'eval "$(mise activate zsh)"' >> /etc/skel/.zshrc

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set working directory to workspace
WORKDIR /workspace

# Use entrypoint to handle UID/GID mapping
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start zsh by default
CMD ["zsh"]
