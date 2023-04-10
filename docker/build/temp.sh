#!/usr/bin/env bash

function _local_cached() {
    local temp="${1}"
    IMAGE_OUT="hell"
}
TEST="..."
CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
cd ${CURR_DIR}
source ./temp1.sh

echo ${TEST}

export TEST="haha"
