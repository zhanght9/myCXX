#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"
source ./installer_base.sh

VERSION="3.19.6"

function symlink_if_not_exist() {
    local dest="/usr/local/bin/cmake"
    if [[ ! -e "${dest}" ]]; then
        info "Created symlink ${dest} for convenience."
        ln -s ${SYSROOT_DIR}/bin/cmake /usr/local/bin/cmake
    fi
}

CMAKE_SH=
CHECKSUM=
if [[ "$(uname -m)" == "x86_64" ]]; then
    CMAKE_SH="cmake-${VERSION}-Linux-x86_64.sh"
    CHECKSUM="d94155cef56ff88977306653a33e50123bb49885cd085edd471d70dfdfc4f859"
fi

DOWNLOAD_LINK="https://github.com/Kitware/CMake/releases/download/v${VERSION}/${CMAKE_SH}"
download_if_not_cached "${CMAKE_SH}" "${CHECKSUM}" "${DOWNLOAD_LINK}"

chmod a+x ${CMAKE_SH}
./${CMAKE_SH} --skip-license --prefix="${SYSROOT_DIR}"
symlink_if_not_exist
rm -fr ${CMAKE_SH}
