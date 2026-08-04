#!/bin/bash

# Get UID/GID from environment variables or fallback to the /workspace owner
# This handles the "portability" requirement perfectly.
WORKSPACE_UID=$(stat -c %u /workspace 2>/dev/null || echo 1000)
WORKSPACE_GID=$(stat -c %g /workspace 2>/dev/null || echo 1000)

# If /workspace is owned by root, fall back to the default 1000:1000 instead
# of running as root, and reclaim /workspace for the newly created user below.
CHOWN_WORKSPACE=0
if [ "$WORKSPACE_UID" = "0" ] && [ "$WORKSPACE_GID" = "0" ]; then
    WORKSPACE_UID=1000
    WORKSPACE_GID=1000
    CHOWN_WORKSPACE=1
fi

USER_ID=${HOST_UID:-$WORKSPACE_UID}
GROUP_ID=${HOST_GID:-$WORKSPACE_GID}

# Use the USER_NAME environment variable passed from the Dockerfile (defaults to matir)
USER_NAME=${USER_NAME:-matir}

# Warn if the GID is already in use by a different group name
EXISTING_GROUP=$(getent group "$GROUP_ID" | cut -d: -f1)
if [ -n "$EXISTING_GROUP" ] && [ "$EXISTING_GROUP" != "$USER_NAME" ]; then
    echo "ERROR: GID $GROUP_ID is already in use by group '$EXISTING_GROUP' (expected '$USER_NAME')" >&2
fi

# Create the group if it doesn't exist
if ! getent group "$GROUP_ID" >/dev/null; then
    groupadd -g "$GROUP_ID" "$USER_NAME"
fi

# Warn if the UID is already in use by a different username
EXISTING_USER=$(getent passwd "$USER_ID" | cut -d: -f1)
if [ -n "$EXISTING_USER" ] && [ "$EXISTING_USER" != "$USER_NAME" ]; then
    echo "ERROR: UID $USER_ID is already in use by user '$EXISTING_USER' (expected '$USER_NAME')" >&2
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

# Reclaim /workspace from root now that it belongs to the mapped user
if [ "$CHOWN_WORKSPACE" = "1" ]; then
    chown -R "$USER_ID:$GROUP_ID" /workspace 2>/dev/null
fi

# Execute the passed command (e.g., zsh) as the mapped user
export HOME="/home/$USER_NAME"
exec gosu "$USER_NAME" "$@"
