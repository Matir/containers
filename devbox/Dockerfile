FROM docker.io/library/debian:trixie-slim

LABEL maintainer="Matir <matir@users.noreply.github.com>" \
      org.opencontainers.image.authors="Matir <matir@users.noreply.github.com>" \
      org.opencontainers.image.base.name="docker.io/library/debian:trixie-slim"

# Add Docker CLI and Google Cloud CLI repos, then install everything in one layer
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates gnupg curl && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" \
      | tee /etc/apt/sources.list.d/docker.list && \
    chmod 644 /etc/apt/keyrings/docker.gpg /etc/apt/sources.list.d/docker.list && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
      | tee /etc/apt/sources.list.d/google-cloud-sdk.list && \
    chmod 644 /etc/apt/keyrings/cloud.google.gpg /etc/apt/sources.list.d/google-cloud-sdk.list && \
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
    # Benchmarking
    hyperfine \
    # HTTP clients
    httpie xh \
    # Man pages
    man-db manpages-dev \
    # Container client
    docker-ce-cli \
    # Cloud tooling
    google-cloud-cli \
    # Privilege drop helper for entrypoint
    gosu && \
    npm install -g @anthropic-ai/claude-code && \
    curl -sS https://starship.rs/install.sh | sh -s -- -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install mitmproxy from testing (not yet in trixie/stable)
RUN echo "deb http://deb.debian.org/debian testing main" > /etc/apt/sources.list.d/debian-testing.list && \
    printf 'Package: *\nPin: release a=testing\nPin-Priority: 100\n' > /etc/apt/preferences.d/testing-pin && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -t testing mitmproxy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install watchexec (not packaged in Debian)
ARG WATCHEXEC_VERSION=2.5.1
ARG WATCHEXEC_SHA256_AMD64=9bf40f223b3651e59c99ed463c44635fa71ab3f81b69927b5343b3935a4fdb14
ARG WATCHEXEC_SHA256_ARM64=ce125d1e4c86e69e1e088bf1cfc5db68d74d0bb933dc4555ae727bab49dc62ca
RUN ARCH="$(dpkg --print-architecture)" && \
    case "${ARCH}" in \
      amd64) WX_TARGET=x86_64-unknown-linux-gnu; WX_SHA256="${WATCHEXEC_SHA256_AMD64}" ;; \
      arm64) WX_TARGET=aarch64-unknown-linux-gnu; WX_SHA256="${WATCHEXEC_SHA256_ARM64}" ;; \
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;; \
    esac && \
    WX_DEB="watchexec-${WATCHEXEC_VERSION}-${WX_TARGET}.deb" && \
    curl -fsSLO "https://github.com/watchexec/watchexec/releases/download/v${WATCHEXEC_VERSION}/${WX_DEB}" && \
    echo "${WX_SHA256}  ${WX_DEB}" | sha256sum -c - && \
    dpkg -i "${WX_DEB}" && \
    rm "${WX_DEB}"

# Install lazygit (not packaged in Debian)
ARG LAZYGIT_VERSION=0.62.2
ARG LAZYGIT_SHA256_AMD64=8b9a4c2d0969cbea92b45c956dd2a44e1ba76900c9df49f1c60984045ce77984
ARG LAZYGIT_SHA256_ARM64=9ab63dd75a7e9711c4c68a37d77f4334b8099a5d6a3f8fbe8f4e2768b159c9e9
RUN ARCH="$(dpkg --print-architecture)" && \
    case "${ARCH}" in \
      amd64) LG_TARGET=x86_64; LG_SHA256="${LAZYGIT_SHA256_AMD64}" ;; \
      arm64) LG_TARGET=arm64; LG_SHA256="${LAZYGIT_SHA256_ARM64}" ;; \
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;; \
    esac && \
    LG_TAR="lazygit_${LAZYGIT_VERSION}_linux_${LG_TARGET}.tar.gz" && \
    curl -fsSLO "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/${LG_TAR}" && \
    echo "${LG_SHA256}  ${LG_TAR}" | sha256sum -c - && \
    tar -xzf "${LG_TAR}" lazygit && \
    install -m 755 lazygit /usr/local/bin/lazygit && \
    rm "${LG_TAR}" lazygit

# Install Google Antigravity CLI
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- -d /usr/local/bin

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
