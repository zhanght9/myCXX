#! /usr/bin/env bash

BASE_IMAGE="Ubuntu"
BASE_IMAGE_TAG="20.04"

CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
echo "${CURR_DIR}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
source "${CURR_DIR}/docker_base.sh"
echo "${CURR_DIR}"
DOCKERFILE="${ROOT_DIR}/docker/build/Dockerfile"

USE_CACHE=1
DRY_RUN_ONLY=0

function cpu_arch_support_check() {
    local arch="$1"
    for entry in "${SUPPORTED_ARCHS[@]}"; do
        if [[ "${entry}" == "${arch}" ]]; then
            return
        fi
    done
    echo "Unsupported CPU architecture: ${arch}. Exiting..."
    exit 1
}

function build_stage_check() {
    local stage="$1"
    for entry in "${SUPPORTED_STAGES[@]}"; do
        if [[ "${entry}" == "${stage}" ]]; then
            return
        fi
    done
    echo "Unsupported build stage: ${stage}. Exiting..."
    exit 1
}

IMAGE_IN="${BASE_IMAGE}":"${BASE_IMAGE_TAG}"
IMAGE_OUT="${PROJECT_NAME}_IMAGE:$(date +%Y%m%d)"

function print_usage() {
    local prog
    prog="$(basename "$0")"
    echo "Usage:"
    echo "${TAB}${prog} -f <Dockerfile> [Options]"
    # echo "Available options:"
    # echo "${TAB}-c,--clean      Use \"--no-cache=true\" for docker build"
    # echo "${TAB}-m,--mode       \"build\" for build everything from source if possible, \"download\" for using prebuilt ones"
    # echo "${TAB}-g,--geo        Enable geo-specific mirrors to speed up build. Currently \"cn\" and \"us\" are supported."
    # echo "${TAB}-d,--dist       Whether to build stable(\"stable\") or experimental(\"testing\") Docker images"
    # echo "${TAB}-t,--timestamp  Specify image timestamp for previous stage to build image upon. Format: yyyymmdd_hhmm (e.g 20210205_1520)"
    # echo "${TAB}--dry           Dry run (for testing purpose)"
    echo "${TAB}-h,--help       Show this message and exit"
}

function check_opt_arg() {
    local opt="$1"
    local arg="$2"
    if [[ -z "${arg}" || "${arg}" =~ ^-.* ]]; then
        echo "Argument missing for option ${opt}. Exiting..."
        exit 1
    fi
}

function parse_arguments() {
    while [[ $# -gt 0 ]]; do
        local opt="$1"
        shift
        case $opt in
        -f | --dockerfile)
            check_opt_arg "${opt}" "$1"
            DOCKERFILE="$1"
            shift
            ;;
        -h | --help)
            print_usage
            exit 0
            ;;
        -c | --clean)
            USE_CACHE=0
            ;;
        *)
            echo "Unknown option: ${opt}"
            print_usage
            exit 1
            ;;
        esac
    done
}

function docker_build_preview() {
    echo "=====.=====.=====   Docker Build Preview  =====.=====.=====.=====.=====.====="
    echo "|  Generated image: ${IMAGE_OUT}"
    echo "|  FROM image: ${IMAGE_IN}"
    echo "|  Dockerfile: ${DOCKERFILE}"
    echo "=====.=====.=====.=====.=====.=====.=====.=====.=====.=====.=====.=====.====="
}

function docker_build_run() {
    local extra_args="--squash"
    if [[ "${USE_CACHE}" -eq 0 ]]; then
        extra_args="${extra_args} --no-cache=true"
    fi
    local context
    context="$(dirname "${BASH_SOURCE[0]}")/../build"

    local build_args="--build-arg BASE_IMAGE=${IMAGE_IN}"

    set -x
    docker build --network=host ${extra_args} -t "${IMAGE_OUT}" \
        "${build_args}" \
        -f "${DOCKERFILE}" \
        "${context}"
    set +x
}

function main() {
    parse_arguments "$@"

    docker_build_preview

    docker_build_run
}

main "$@"
