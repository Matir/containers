FROM ubuntu:24.04

# Consolidated system dependencies, JDK 17, and latest Node.js 24
RUN apt-get update && \
    apt-get -yy install --no-install-recommends \
    git git-lfs python3 sudo build-essential \
    golang curl ca-certificates openjdk-17-jdk-headless unzip \
    && curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s 24 \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=node
RUN groupadd --gid 1001 ${USERNAME} \
    && useradd --uid 1001 --gid ${USERNAME} --shell /bin/bash --create-home ${USERNAME} \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Environment variables for Android and NPM
ARG ANDROID_HOME=/usr/local/lib/android/sdk
ARG NPM_GLOBAL=/usr/local/share/npm-global
ARG NDK_VERSION=26.1.10909125

# Set JAVA_HOME dynamically to support multiple architectures
RUN ln -s $(find /usr/lib/jvm -maxdepth 1 -name "java-17-openjdk-*" -type d | head -n 1) /usr/lib/jvm/java-17
ENV JAVA_HOME=/usr/lib/jvm/java-17 \
    ANDROID_HOME=${ANDROID_HOME} \
    ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/${NDK_VERSION} \
    GOPATH=/home/${USERNAME}/go

ENV PATH=${NPM_GLOBAL}/bin:${GOPATH}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/build-tools/34.0.0:${PATH}

# Install Android SDK
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && curl -fL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o /tmp/cmdline-tools.zip \
    && unzip /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip \
    && yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "ndk;${NDK_VERSION}" \
    && chown -R ${USERNAME}: ${ANDROID_HOME}

# Optimized NPM Configuration and Global Installs
RUN groupadd -r npm && usermod -a -G npm ${USERNAME} \
    && mkdir -p ${NPM_GLOBAL} \
    && chown ${USERNAME}:npm ${NPM_GLOBAL} \
    && chmod g+s ${NPM_GLOBAL} \
    && su ${USERNAME} -c "npm config set prefix ${NPM_GLOBAL} && \
       umask 0002 && \
       npm install -g eslint typescript tslint-to-eslint-config && \
       npm cache clean --force"

# Go tooling - Using absolute path for gomobile init to ensure it is found
RUN su ${USERNAME} -c "go install golang.org/x/mobile/cmd/gomobile@latest && \
    ${GOPATH}/bin/gomobile init"

WORKDIR /workspace
USER ${USERNAME}
