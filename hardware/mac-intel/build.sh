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

if [[ "${#WL_RPMS[@]}" -eq 0 ]]; then
    echo "No Broadcom wl driver found in the akmods image. It contains:"
    find /akmods -name '*.rpm' | sort
    exit 1
fi
echo "Driver packages: ${WL_RPMS[*]}"

# The kernel module needs its companion package (broadcom-wl, which provides
# wl-kmod-common). That lives in RPM Fusion, which the base image does not
# carry. Add the RPM Fusion repos for this one install, then remove them so
# they are not left enabled on the finished image.
FEDORA="$(rpm -E %fedora)"
dnf5 install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA}.noarch.rpm"

# The driver is built for one exact kernel. If this fails on a kernel
# dependency, the base image and the akmods image are out of step.
dnf5 install -y broadcom-wl "${WL_RPMS[@]}"

dnf5 remove -y rpmfusion-free-release rpmfusion-nonfree-release
