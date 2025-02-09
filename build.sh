#!/bin/bash

CMD=$1
TARGET=$2
MODE=$3

ARCH=arm
CROSS_COMPILE=arm-none-linux-gnueabihf-
BUILD_DIR=build
INSTALL_DIR=/home/jiamuyu/workspace/images

function show_help()
{
    echo "./build.sh cmd(build | clean) target(stm32mp1 | ...) mode(debug | release...)"
}

function clean()
{
    make distclean
}

function build_stm32mp1()
{

    if [[ $MODE == "debug" ]]; then
        echo "build target for stm32mp157 debug version..."
        make stm32mp157_debug_defconfig ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} O=${BUILD_DIR}
    else
        echo "build target for stm32mp157 release version..."
        make stm32mp157_defconfig ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} O=${BUILD_DIR}
    fi

    make DEVICE_TREE=stm32mp157d-atk all ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} O=${BUILD_DIR} -j${nproc}
    ${CROSS_COMPILE}objdump -xdts ${BUILD_DIR}/u-boot -xdts > ${BUILD_DIR}/u-boot.dis
    # cp ${BUILD_DIR}/u-boot.stm32 ${INSTALL_DIR}
}


if [[ "${CMD}" != "build" && "${CMD}" != "clean" ]]; then
    echo "Error build cmd"
    show_help
    exit 1
fi

if [[ "${TARGET}" != "stm32mp1" && "${CMD}" == "build" ]]; then
    echo "Error target"
    show_help
    exit 1
fi

if [[ "${CMD}" == "build" ]]; then
    if [[ "${TARGET}" == "stm32mp1" ]]; then
        build_stm32mp1
        if [[ $? == 0 ]]; then
            echo "Build success!"
        else
            echo "Build failed!"
            exit 1
        fi
    else
        show_help
        exit 1
    fi
fi

if [[ "${CMD}" == "clean" ]]; then
    echo "Clean build system"
    clean
fi
