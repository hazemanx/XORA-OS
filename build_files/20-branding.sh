#!/bin/bash
# XORA naming. ID stays "fedora" so the ISO builder and package tools
# still recognize the base.

set -ouex pipefail

sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="XORA OS (preview)"/' /usr/lib/os-release
sed -i 's/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME="xora"/' /usr/lib/os-release
grep -q '^DEFAULT_HOSTNAME=' /usr/lib/os-release || echo 'DEFAULT_HOSTNAME="xora"' >> /usr/lib/os-release
