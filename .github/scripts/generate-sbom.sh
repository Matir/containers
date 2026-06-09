#!/bin/bash
set -e

IMAGE=$1
if [ -z "$IMAGE" ]; then
  echo "Usage: $0 <image-tag>"
  exit 1
fi

echo "Processing image: ${IMAGE}"

# Determine if image is local or remote
if docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  echo "Image ${IMAGE} found locally."
  IS_LOCAL=true
  SYFT_IMAGE="docker:${IMAGE}"
  LABELS=$(docker inspect "${IMAGE}" | jq -r '.[0].Config.Labels // {}')
else
  echo "Image ${IMAGE} not found locally, checking remote registry..."
  IS_LOCAL=false
  SYFT_IMAGE="registry:${IMAGE}"
  # Try to get labels using buildx imagetools
  LABELS=$(docker buildx imagetools inspect "${IMAGE}" --format '{{json .Image.Config.Labels}}' 2>/dev/null || echo "{}")
fi

echo "Labels detected:"
echo "${LABELS}" | jq .

# Generate SBOM for built image
echo "Generating SBOM for ${IMAGE}..."
# We print the table format to stdout for readability
syft "${SYFT_IMAGE}" -o table

# Also save as JSON for comparison
syft "${SYFT_IMAGE}" -o json > built_sbom.json

# Check for base image label
BASE_IMAGE=$(echo "${LABELS}" | jq -r '."org.opencontainers.image.base.name" // empty')

if [ -n "$BASE_IMAGE" ]; then
  echo "Base image detected: ${BASE_IMAGE}"
  
  # Determine if base image is local or remote (likely remote)
  if docker image inspect "${BASE_IMAGE}" >/dev/null 2>&1; then
    SYFT_BASE_IMAGE="docker:${BASE_IMAGE}"
  else
    SYFT_BASE_IMAGE="registry:${BASE_IMAGE}"
  fi

  echo "Generating SBOM for base image ${BASE_IMAGE}..."
  syft "${SYFT_BASE_IMAGE}" -o json > base_sbom.json

  echo "Comparing SBOMs..."
  $(dirname "$0")/compare_sboms.py base_sbom.json built_sbom.json
else
  echo "No base image label (org.opencontainers.image.base.name) detected."
fi
