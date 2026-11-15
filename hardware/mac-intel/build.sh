#!/bin/bash
# XORA for Intel Mac 2013-2017.
#
# Wi-Fi: Broadcom "wl" driver. Covers the Early 2013 Retina MacBook Pro
# (BCM4331) and the Late 2013 and later models (BCM4360).
#
# Camera: Early 2013 models have a USB camera that works without a driver.
# Late 2013 and later use the FaceTime HD camera, which needs a separate
# driver and Apple firmware. TODO: not added yet.

set -ouex pipefail

KERNEL="$(rpm -q kernel-core --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}\n' | head -n 1)"
echo "Image kernel: ${KERNEL}"

mapfile -t WL_RPMS < <(find /akmods -name 'kmod-wl-*.rpm' | sort)
mapfile -t ADDON_RPMS < <(find /akmods -name 'ublue-os-akmods-addons*.rpm' | sort)

if [[ "${#WL_RPMS[@]}" -eq 0 ]]; then
    echo "No Broadcom wl driver found in the akmods image. It contains:"
    find /akmods -name '*.rpm' | sort
    exit 1
fi
echo "Driver packages: ${WL_RPMS[*]} ${ADDON_RPMS[*]}"

# The driver is built for one exact kernel. If this install fails on a kernel
# dependency, the base image and the akmods image are out of step.
if ! dnf5 install -y "${ADDON_RPMS[@]}" "${WL_RPMS[@]}"; then
    echo "Retrying with the RPM Fusion repos enabled"
    dnf5 install -y --enablerepo='*rpmfusion*' "${ADDON_RPMS[@]}" "${WL_RPMS[@]}"
fi
