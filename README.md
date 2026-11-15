# XORA OS

A lightweight, Mac-like operating system for creating and producing, built on Linux.

This repo builds the XORA OS images and installer ISOs with GitHub Actions.

## Products

One shared XORA layer, plus a small hardware folder per product. Each product
builds its own image and its own ISO, so drivers never mix.

| Product | Image | Status |
|---|---|---|
| PC (AMD/Intel graphics) | `xora-os-pc` | Building |
| Intel Mac 2013-2017 | `xora-os-mac-intel` | Building, Wi-Fi driver added, FaceTime HD camera driver not added yet |
| Framework | `xora-os-framework` | Planned |
| PC (NVIDIA) | `xora-os-nvidia` | Planned |
| Intel Mac 2018-2020 (T2) | `xora-os-mac-t2` | Planned |
| Apple Silicon | `xora-os-asahi` | Planned |

## Layout

- `Containerfile`: base image, runs `build_files/build.sh`
- `build_files/`: the shared XORA layer, numbered scripts run in order
- `hardware/<product>/`: drivers and tuning for one product only
- `system_files/`: files copied into the image as-is
- `disk_config/`: installer ISO settings, one per product
- `.github/workflows/build.yml`: builds every product's image on each push
- `.github/workflows/build-disk.yml`: builds the ISOs after the images

## Getting an ISO

Open the Actions tab, pick the latest "Build disk images" run, and download
the artifact named after your product.

Built from the [Universal Blue image template](https://github.com/ublue-os/image-template).
