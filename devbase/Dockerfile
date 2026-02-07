FROM docker.io/library/debian:trixie-slim

LABEL maintainer="Matir <matir@users.noreply.github.com>"

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  zsh git vim build-essential procps lldb gdb python3 net-tools strace \
  jq curl ripgrep gnupg ca-certificates pkg-config less sudo locales \
  git-lfs bash-completion && \
  curl -sS https://starship.rs/install.sh | sh -s -- -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# install mise
ARG MISE_KEYID=24853EC9F655CE80B48E6C3A8B81C9D17413A06D
RUN curl -fSsL https://mise.jdx.dev/gpg-key.pub | gpg --batch --import && \
  curl -fsSL https://mise.jdx.dev/install.sh.sig | \
  gpg --decrypt --assert-signer ${MISE_KEYID} > /tmp/install.sh && \
  MISE_INSTALL_PATH=/usr/local/bin/mise sh /tmp/install.sh && \
  rm /tmp/install.sh

# create a user
ARG USERNAME=dev
ARG UID=1000
ARG GID=1000

RUN groupadd -g ${GID} ${USERNAME} \
    && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}
COPY bashrc .bashrc
COPY zshrc .zshrc

ENTRYPOINT ["/bin/bash"]
