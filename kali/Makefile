# Image configuration
IMAGE_NAME := ghcr.io/matir/containers/kali
PLATFORMS := linux/amd64,linux/arm64
TIMESTAMP := $(shell date +%Y%m%d-%H%M)

# Tags
TAG_LATEST := $(IMAGE_NAME):latest
TAG_TS := $(IMAGE_NAME):$(TIMESTAMP)

.PHONY: all build build-multi local push clean help

all: local

# Build for the local platform and load into Docker
local:
	@echo "Building and loading for local platform..."
	docker buildx build --load \
		-t $(TAG_LATEST) \
		-t $(TAG_TS) \
		.

# Build for both amd64 and arm64 (requires a builder with multi-platform support)
# Note: Multi-platform images cannot be loaded directly into the standard Docker image store.
# They are typically pushed to a registry or stored in the buildx cache.
build-multi:
	@echo "Building for $(PLATFORMS)..."
	docker buildx build --platform $(PLATFORMS) \
		-t $(TAG_LATEST) \
		-t $(TAG_TS) \
		.

# Build and push to GHCR
push:
	@echo "Building and pushing $(PLATFORMS) to GHCR..."
	docker buildx build --platform $(PLATFORMS) \
		-t $(TAG_LATEST) \
		-t $(TAG_TS) \
		--push \
		.

# Initialize buildx if needed
setup:
	docker buildx create --use --name multi-arch-builder || docker buildx use multi-arch-builder

help:
	@echo "Available targets:"
	@echo "  local       - Build and load the image into local Docker (native arch)"
	@echo "  build-multi - Build for both amd64 and arm64"
	@echo "  push        - Build for both platforms and push to GHCR"
	@echo "  setup       - Set up a buildx builder for multi-platform builds"
