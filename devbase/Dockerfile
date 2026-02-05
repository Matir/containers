FROM docker.io/library/debian:trixie-slim

LABEL maintainer="Matir <matir@@users.noreply.github.com>"

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  zsh git vim build-essential procps lldb gdb python3 net-tools strace \
  jq curl ripgrep && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]
