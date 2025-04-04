FROM ubuntu:latest

RUN apt-get update && \
  apt-get -yy install cargo nodejs git python3 sudo build-essential libbz2-dev \
  liblzma-dev npm golang

RUN /bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

RUN brew install watchman

ARG USERNAME=node
RUN groupadd --gid 1001 ${USERNAME} \
  && useradd --uid 1001 --gid ${USERNAME} --shell /bin/bash --create-home ${USERNAME}

ARG NPM_GLOBAL=/usr/local/share/npm-global

# Add NPM global to PATH.
ENV PATH=${NPM_GLOBAL}/bin:${PATH}

RUN \
    # Configure global npm install location, use group to adapt to UID/GID changes
    if ! cat /etc/group | grep -e "^npm:" > /dev/null 2>&1; then groupadd -r npm; fi \
    && usermod -a -G npm ${USERNAME} \
    && umask 0002 \
    && mkdir -p ${NPM_GLOBAL} \
    && touch /etc/npmrc \
    && chown ${USERNAME}:npm ${NPM_GLOBAL} /etc/npmrc \
    && chmod g+s ${NPM_GLOBAL} \
    && npm config -g set prefix ${NPM_GLOBAL} \
    && echo "NPM global config done" \
    && su ${USERNAME} -c "npm config -g set prefix ${NPM_GLOBAL}" \
    # Install eslint
    && su ${USERNAME} -c "umask 0002 && npm install -g eslint" \
    && npm cache clean --force > /dev/null 2>&1

ARG NODE_MODULES="tslint-to-eslint-config typescript"
RUN su ${USERNAME} -c "umask 0002 && npm install -g ${NODE_MODULES}" \
    && npm cache clean --force > /dev/null 2>&1

RUN su ${USERNAME} -c "go install golang.org/x/mobile/cmd/gomobile@latest"
