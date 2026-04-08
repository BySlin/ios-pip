#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/install_ios_python_package.sh \
#     /path/to/ios-python-package-cp314-arm64-iphoneos.tar.gz \
#     /path/to/YourApp.app
#
# This script installs:
# - app_packages/*
# into an iOS app bundle.

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <ios-python-package.tar.gz> <YourApp.app>"
  exit 1
fi

PKG_TAR="$1"
APP_BUNDLE="$2"

if [[ ! -f "${PKG_TAR}" ]]; then
  echo "Package not found: ${PKG_TAR}"
  exit 1
fi

if [[ ! -d "${APP_BUNDLE}" ]]; then
  echo "App bundle not found: ${APP_BUNDLE}"
  exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

tar -xzf "${PKG_TAR}" -C "${WORKDIR}"

PKG_ROOT="${WORKDIR}/ios-python-package"
APP_PACKAGES_DIR="${APP_BUNDLE}/app_packages"
FRAMEWORKS_DIR="${APP_BUNDLE}/Frameworks"

if [[ ! -d "${PKG_ROOT}/app_packages" ]]; then
  echo "Invalid package: missing app_packages"
  exit 1
fi

mkdir -p "${APP_PACKAGES_DIR}"

cp -R "${PKG_ROOT}/app_packages/." "${APP_PACKAGES_DIR}/"
echo "Installed app packages to: ${APP_PACKAGES_DIR}"

if [[ -d "${PKG_ROOT}/Frameworks" ]]; then
  mkdir -p "${FRAMEWORKS_DIR}"
  cp -R "${PKG_ROOT}/Frameworks/." "${FRAMEWORKS_DIR}/"
  echo "Installed frameworks to: ${FRAMEWORKS_DIR}"
fi
