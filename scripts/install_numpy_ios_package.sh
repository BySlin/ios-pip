#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/install_numpy_ios_package.sh \
#     /path/to/numpy-ios-cp314-arm64-iphoneos-python-package.tar.gz \
#     /path/to/YourApp.app
#
# This script installs:
# - app_packages/numpy/*
# - Frameworks/*
# into an iOS app bundle.

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <numpy-ios-python-package.tar.gz> <YourApp.app>"
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

PKG_ROOT="${WORKDIR}/numpy-ios-python-package"
APP_PACKAGES_DIR="${APP_BUNDLE}/app_packages"
FRAMEWORKS_DIR="${APP_BUNDLE}/Frameworks"

if [[ ! -d "${PKG_ROOT}/app_packages/numpy" ]]; then
  echo "Invalid package: missing app_packages/numpy"
  exit 1
fi

if [[ ! -d "${PKG_ROOT}/Frameworks" ]]; then
  echo "Invalid package: missing Frameworks"
  exit 1
fi

mkdir -p "${APP_PACKAGES_DIR}"
mkdir -p "${FRAMEWORKS_DIR}"

rm -rf "${APP_PACKAGES_DIR}/numpy"
cp -R "${PKG_ROOT}/app_packages/numpy" "${APP_PACKAGES_DIR}/"
cp -R "${PKG_ROOT}/Frameworks/." "${FRAMEWORKS_DIR}/"

echo "Installed numpy package to: ${APP_PACKAGES_DIR}/numpy"
echo "Installed frameworks to: ${FRAMEWORKS_DIR}"
