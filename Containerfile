# Fedora release for the base image and its matching drivers. Keep the two in step.
ARG FEDORA_VERSION=44

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY hardware /hardware
COPY system_files /system_files

# Base Image
# Prebuilt kernel drivers from Universal Blue, matched to the same Fedora release.
# Only mounted during the build; a product's hardware script decides what to install.
FROM ghcr.io/ublue-os/akmods:main-${FEDORA_VERSION} AS akmods

# Fedora Atomic Kinoite (KDE Plasma) with Universal Blue's codec and hardware fixes.
FROM ghcr.io/ublue-os/kinoite-main:${FEDORA_VERSION}

# Which XORA product this image is for. One folder per product in hardware/.
# Set by the build workflow: pc, mac-intel (more to come).
ARG HARDWARE=pc

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=akmods,source=/,target=/akmods \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    HARDWARE=${HARDWARE} /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
