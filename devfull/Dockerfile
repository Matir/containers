FROM ghcr.io/matir/containers/devbase:latest

LABEL maintainer="Matir <matir@users.noreply.github.com>" \
      org.opencontainers.image.base.name="docker.io/library/debian:trixie-slim"

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-transport-https ca-certificates gnupg curl && \
    # Google Cloud CLI
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    # Kubernetes
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
    # Docker
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list && \
    # Helm
    curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor -o /usr/share/keyrings/helm.gpg && \
    test "$(gpg --show-keys --with-colons "/usr/share/keyrings/helm.gpg" | awk -F: '$1 == "fpr" {print $10}' | head -n 1)" = "DDF78C3E6EBB2D2CC223C95C62BA89D07698DBC6" && \
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" > /etc/apt/sources.list.d/helm.list &&\
    chmod 644 /etc/apt/keyrings/* && chmod 644 /etc/apt/sources.list.d/* && \
    # Install packages
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    clang-format \
    shellcheck \
    ripgrep \
    strace \
    jq fq jqp xq yq \
    git-lfs \
    google-cloud-cli \
    google-cloud-cli-gke-gcloud-auth-plugin \
    kubectl \
    docker-ce-cli \
    helm \
    nodejs \
    npm \
    fish && \
    npm install -g @anthropic-ai/claude-code && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- -d /usr/local/bin

USER dev
RUN mkdir -p /home/dev/.config/fish
COPY --chown=dev:dev config.fish /home/dev/.config/fish/config.fish
