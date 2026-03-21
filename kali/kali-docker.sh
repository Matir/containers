#!/bin/bash

# Configuration
IMAGE_NAME="ghcr.io/matir/containers/kali:latest"
CONTAINER_NAME="kali-workspace"
NETWORK_MODE="bridge"
DAEMONIZE=false
WORKSPACE_DIR="$(pwd)"
COMMAND=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host-network)
            NETWORK_MODE="host"
            shift
            ;;
        -d)
            DAEMONIZE=true
            shift
            ;;
        --workspace)
            WORKSPACE_DIR="$(realpath "$2")"
            shift 2
            ;;
        --) # End of options
            shift
            COMMAND+=("$@")
            break
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            COMMAND+=("$1")
            shift
            ;;
    esac
done

# Check if the container is already running
if [ "$(docker inspect -f '{{.State.Running}}' ${CONTAINER_NAME} 2>/dev/null)" == "true" ]; then
    echo "Container '${CONTAINER_NAME}' is already running."
    if [ ${#COMMAND[@]} -eq 0 ]; then
        COMMAND=("zsh")
    fi
    echo "Executing: ${COMMAND[*]}"
    docker exec -it -e TERM="$TERM" "${CONTAINER_NAME}" "${COMMAND[@]}"
else
    # Remove the container if it exists but is not running (to apply new mounts/configs)
    if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
        docker rm "${CONTAINER_NAME}" > /dev/null
    fi

    echo "Starting a new Kali container..."
    echo "Mounting: ${WORKSPACE_DIR} -> /workspace"
    echo "Network: ${NETWORK_MODE}"

    DOCKER_OPTS=("-it")
    if [ ${#COMMAND[@]} -eq 0 ]; then
        if [ "$DAEMONIZE" = true ]; then
            COMMAND=("sleep" "infinity")
        else
            COMMAND=("zsh")
        fi
    fi

    if [ "$DAEMONIZE" = true ]; then
        DOCKER_OPTS=("-d")
        echo "Mode: Daemonized"
    fi

    echo "Command: ${COMMAND[*]}"

    # Use a named volume for the home directory to persist state (history, tools, etc.)
    # We default to 'matir' to match the Dockerfile/entrypoint defaults
    VOLUME_NAME="kali-home-persistence"

    docker run "${DOCKER_OPTS[@]}" \
        --name "${CONTAINER_NAME}" \
        --network "${NETWORK_MODE}" \
        -e HOST_UID="$(id -u)" \
        -e HOST_GID="$(id -g)" \
        -e TERM="$TERM" \
        -v "${VOLUME_NAME}:/home/matir" \
        -v "${WORKSPACE_DIR}:/workspace" \
        -w /workspace \
        "${IMAGE_NAME}" \
        "${COMMAND[@]}"
fi
