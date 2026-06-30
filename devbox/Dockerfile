FROM docker.io/library/debian:trixie-slim

LABEL maintainer="Matir <matir@users.noreply.github.com>" \
      org.opencontainers.image.authors="Matir <matir@users.noreply.github.com>" \
      org.opencontainers.image.base.name="docker.io/library/debian:trixie-slim"

# Add Docker CLI repo, then install everything in one layer
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates gnupg curl && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" \
      | tee /etc/apt/sources.list.d/docker.list && \
    chmod 644 /etc/apt/keyrings/docker.gpg /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # Shells
    bash bash-completion \
    zsh zsh-autosuggestions zsh-syntax-highlighting \
    fish \
    # Editors
    vim neovim \
    # Core utilities
    git git-lfs git-delta \
    less sudo locales gnupg ca-certificates curl wget pkg-config \
    file zip unzip rsync \
    openssh-client \
    # Build tools
    build-essential python3 python3-pip python3-venv pipx \
    # Debugging
    procps lldb gdb strace ltrace lsof \
    # Networking
    net-tools iputils-ping iproute2 dnsutils netcat-openbsd tcpdump \
    # Terminal multiplexer
    tmux \
    # Modern CLI replacements
    bat fd-find eza ripgrep \
    # Fuzzy finder & directory jumping
    fzf zoxide \
    # Per-directory env management
    direnv \
    # Process and disk viewers
    htop ncdu \
    # Data tools
    jq fq jqp xq yq \
    # Dev tools
    shellcheck clang-format gh \
    nodejs npm \
    # HTTP clients
    httpie xh \
    # File watcher
    watchexec \
    # Intercepting proxy
    mitmproxy \
    # Man pages
    man-db manpages-dev \
    # Container client
    docker-ce-cli \
    # Privilege drop helper for entrypoint
    gosu && \
    curl -sS https://starship.rs/install.sh | sh -s -- -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    EDITOR=nvim \
    VISUAL=nvim \
    PAGER=delta \
    TERM=xterm-256color

# Install mise
ARG MISE_KEYID=24853EC9F655CE80B48E6C3A8B81C9D17413A06D
RUN curl -fSsL https://mise.jdx.dev/gpg-key.pub | gpg --batch --import && \
    curl -fsSL https://mise.jdx.dev/install.sh.sig | \
    gpg --decrypt --assert-signer ${MISE_KEYID} > /tmp/install.sh && \
    MISE_INSTALL_PATH=/usr/local/bin/mise sh /tmp/install.sh && \
    rm /tmp/install.sh

# Create dev user with zsh as login shell
ARG USERNAME=matir
ENV USERNAME=${USERNAME}
ARG UID=1000
ARG GID=1000

ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

RUN groupadd -g ${GID} ${USERNAME} \
    && useradd -m -u ${UID} -g ${GID} -s /bin/zsh ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && mkdir -p /home/${USERNAME}/.config/fish \
    && mkdir -p /workspace

COPY bashrc /home/${USERNAME}/.bashrc
COPY zshrc /home/${USERNAME}/.zshrc
COPY config.fish /home/${USERNAME}/.config/fish/config.fish

# entrypoint will setup the skel files
RUN git clone --depth=1 https://github.com/Matir/skel.git /home/${USERNAME}/.skel

RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /home/${USERNAME}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/zsh"]
