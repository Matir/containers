#!/bin/bash
set -e

TARGET_USER="${USERNAME:-matir}"

# If /workspace is mounted and owned by a non-root UID that differs from the
# container user, remap the container user's UID/GID to match so that bind
# mounts from any host user just work.
if [ -d /workspace ]; then
    WS_UID=$(stat -c '%u' /workspace)
    WS_GID=$(stat -c '%g' /workspace)
    CUR_UID=$(id -u "$TARGET_USER")
    CUR_GID=$(id -g "$TARGET_USER")

    if [ "$WS_UID" != "0" ] && [ "$WS_UID" != "$CUR_UID" ]; then
        if [ "$WS_GID" != "$CUR_GID" ]; then
            groupmod -g "$WS_GID" "$TARGET_USER"
        fi
        usermod -u "$WS_UID" "$TARGET_USER"
        # Re-own home dir to the new UID/GID
        chown -R "$WS_UID:$WS_GID" "/home/$TARGET_USER"
    fi
fi

SKEL_SCRIPT="/home/$TARGET_USER/.skel/install.sh"
if [ -f "$SKEL_SCRIPT" ]; then
    gosu "$TARGET_USER" bash "$SKEL_SCRIPT"
fi

exec gosu "$TARGET_USER" "$@"
