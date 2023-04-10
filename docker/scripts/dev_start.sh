#!/usr/bin/env bash

CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${CURR_DIR}/docker_base.sh"

DEV_IMAGE="${PROJECT_NAME}_IMAGE:20230425"

CACHE_ROOT_DIR="${ROOT_DIR}/.cache"

DOCKER_REPO="apolloauto/apollo"
DEV_CONTAINER="${PROJECT_NAME}_CONTAINER_${USER}"
DEV_INSIDE="in-dev-docker"

SUPPORTED_ARCHS=(x86_64 aarch64)
TARGET_ARCH="$(uname -m)"

VERSION_X86_64="dev-x86_64-18.04-20221124_1708"
TESTING_VERSION_X86_64="dev-x86_64-18.04-testing-20210112_0008"

VERSION_AARCH64="dev-aarch64-18.04-20201218_0030"
USER_VERSION_OPT=

FAST_MODE="no"

CUSTOM_DIST=

VOLUME_VERSION="latest"
SHM_SIZE="2G"
USER_SPECIFIED_MAPS=
MAP_VOLUMES_CONF=
OTHER_VOLUMES_CONF=

LOCAL_VOLUMES=

function show_usage() {
    cat <<EOF
Usage: $0 [options] ...
OPTIONS:
    -h, --help             Display this help and exit.
    -f, --fast             Fast mode without pulling all map volumes.
    -l, --local            Use local docker image.
    -t, --tag <TAG>        Specify docker image with tag <TAG> to start.
    -d, --dist             Specify Apollo distribution(stable/testing)
    --shm-size <bytes>     Size of /dev/shm . Passed directly to "docker run"
    stop                   Stop all running Apollo containers.
EOF
}

function parse_arguments() {
    local custom_version=""
    local custom_dist=""
    local shm_size=""

    while [ $# -gt 0 ]; do
        local opt="$1"
        shift
        case "${opt}" in

        -d | --dist)
            custom_dist="$1"
            shift
            optarg_check_for_opt "${opt}" "${custom_dist}"
            ;;

        -h | --help)
            show_usage
            exit 1
            ;;

        -f | --fast)
            FAST_MODE="yes"
            ;;

        --shm-size)
            shm_size="$1"
            shift
            optarg_check_for_opt "${opt}" "${shm_size}"
            ;;

        --map)
            map_name="$1"
            shift
            USER_SPECIFIED_MAPS="${USER_SPECIFIED_MAPS} ${map_name}"
            ;;
        stop)
            info "Now, stop all Apollo containers created by ${USER} ..."
            stop_all_apollo_containers "-f"
            exit 0
            ;;
        *)
            warning "Unknown option: ${opt}"
            exit 2
            ;;
        esac
    done # End while loop

    [[ -n "${custom_version}" ]] && USER_VERSION_OPT="${custom_version}"
    [[ -n "${custom_dist}" ]] && CUSTOM_DIST="${custom_dist}"
    [[ -n "${shm_size}" ]] && SHM_SIZE="${shm_size}"
}

function setup_devices_and_mount_local_volumes() {

    [ -d "${CACHE_ROOT_DIR}" ] || mkdir -p "${CACHE_ROOT_DIR}"
    LOCAL_VOLUMES="${LOCAL_VOLUMES} -v $ROOT_DIR:/${PROJECT_NAME}"
}

function docker_restart_volume() {
    local volume="$1"
    local image="$2"
    local path="$3"
    info "Create volume ${volume} from image: ${image}"
    docker_pull "${image}"
    docker volume rm "${volume}" >/dev/null 2>&1
    docker run -v "${volume}":"${path}" --rm "${image}" true
}

function main() {

    parse_arguments "$@"

    info "Start docker container based on local image : ${DEV_IMAGE}"
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "${DEV_IMAGE}"; then
        info "Local image ${DEV_IMAGE} found and will be used."
    else
        error "Local image ${DEV_IMAGE} NOT found and will stop ..."

    fi

    info "Remove existing Apollo Development container ..."
    remove_container_if_exists "${DEV_CONTAINER}"

    setup_devices_and_mount_local_volumes

    info "Starting Docker container \"${DEV_CONTAINER}\" ..."

    local local_host="$(hostname)"
    local display="${DISPLAY:-:0}"
    local user="${USER}"
    local uid="$(id -u)"
    local group="$(id -g -n)"
    local gid="$(id -g)"

    set -x

    docker run -itd \
        --name "${DEV_CONTAINER}" \
        -e DISPLAY="${display}" \
        -e DOCKER_USER="${user}" \
        -e USER="${user}" \
        -e DOCKER_USER_ID="${uid}" \
        -e DOCKER_GRP="${group}" \
        -e DOCKER_GRP_ID="${gid}" \
        -e DOCKER_IMG="${DEV_IMAGE}" \
        "${LOCAL_VOLUMES}" \
        --net host \
        -w "/${PROJECT_NAME}" \
        --add-host "${DEV_INSIDE}:127.0.0.1" \
        --add-host "${local_host}:127.0.0.1" \
        --hostname "${DEV_INSIDE}" \
        --shm-size "${SHM_SIZE}" \
        --pid=host \
        "${DEV_IMAGE}" \
        /bin/bash

    if [ $? -ne 0 ]; then
        error "Failed to start docker container \"${DEV_CONTAINER}\" based on image: ${DEV_IMAGE}"
        exit 1
    fi
    set +x

    postrun_start_user "${DEV_CONTAINER}"

    ok "Congratulations! You have successfully finished setting up Docker Dev Environment."
    ok "To login into the newly created ${DEV_CONTAINER} container, please run the following command:"
    ok "  bash docker/scripts/dev_into.sh"
    ok "Enjoy!"
}

main "$@"
