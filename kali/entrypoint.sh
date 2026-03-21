#!/bin/bash

# Get UID/GID from environment variables or fallback to the /workspace owner
# This handles the "portability" requirement perfectly.
USER_ID=${HOST_UID:-$(stat -c %u /workspace 2>/dev/null || echo 1000)}
GROUP_ID=${HOST_GID:-$(stat -c %g /workspace 2>/dev/null || echo 1000)}

# Use the USER_NAME environment variable passed from the Dockerfile (defaults to matir)
USER_NAME=${USER_NAME:-matir}

# Create the group if it doesn't exist
if ! getent group "$GROUP_ID" >/dev/null; then
    groupadd -g "$GROUP_ID" "$USER_NAME"
fi

# Create the user if it doesn't exist
if ! getent passwd "$USER_ID" >/dev/null; then
    useradd -u "$USER_ID" -g "$GROUP_ID" -m -s /bin/zsh "$USER_NAME"
    # Allow passwordless sudo for the dev environment
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Sync the home directory if it's new (copies .zshrc from /etc/skel)
cp -n /etc/skel/.zshrc "/home/$USER_NAME/.zshrc" 2>/dev/null

chown -R "$USER_ID:$GROUP_ID" "/home/$USER_NAME" 2>/dev/null

# Execute the passed command (e.g., zsh) as the mapped user
export HOME="/home/$USER_NAME"
exec gosu "$USER_NAME" "$@"
