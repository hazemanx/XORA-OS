#!/bin/bash
# XORA OS image build. Runs inside the container build, once per product.
# HARDWARE picks the product folder in hardware/ (pc, mac-intel, ...).

set -ouex pipefail

HARDWARE="${HARDWARE:-pc}"

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Shared XORA layer: the same on every product.
for script in /ctx/[0-9][0-9]-*.sh; do
    echo "::group:: ${script}"
    bash "${script}"
    echo "::endgroup::"
done

# Hardware layer: only this product's folder is used.
if [[ ! -f "/ctx/hardware/${HARDWARE}/build.sh" ]]; then
    echo "Unknown hardware product: ${HARDWARE}"
    exit 1
fi
echo "::group:: hardware/${HARDWARE}"
HARDWARE="${HARDWARE}" bash "/ctx/hardware/${HARDWARE}/build.sh"
echo "::endgroup::"

# Record which product this image is, for the installer and Software Update.
mkdir -p /usr/share/xora
echo "${HARDWARE}" > /usr/share/xora/hardware
