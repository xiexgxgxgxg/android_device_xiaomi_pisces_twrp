#!/usr/bin/env bash
# Isolated build environment for the pisces TWRP project.
# This tree must never share OUT_DIR / CCACHE_DIR / source with LineageOS 24.0
# (/home/xie/android). Source it before any repo/lunch/mka command.
export TWRP_ROOT=/home/xie/twrp-pisces
export TWRP_SOURCE=$TWRP_ROOT/source
export TWRP_DEVICE=$TWRP_SOURCE/device/xiaomi/pisces
export TWRP_KERNEL=$TWRP_ROOT/kernel
export TWRP_OUT=$TWRP_ROOT/out
export DIST_DIR=$TWRP_ROOT/dist
export CCACHE_DIR=$TWRP_ROOT/ccache
export USE_CCACHE=0
unset CCACHE_EXEC
export JAVA_HOME=$TWRP_ROOT/toolchain/jdk11
export PATH=$JAVA_HOME/bin:$PATH

# never inherit a LineageOS/other lunch environment
unset TARGET_PRODUCT TARGET_BUILD_VARIANT TARGET_DEVICE TARGET_PRODUCT_DEVICE
unset ANDROID_BUILD_TOP ANDROID_PRODUCT_OUT ANDROID_HOST_OUT ANDROID_SOONG_HOST_OUT
unset OUT_DIR COMMON_OUT_DIR

guard_twrp() {
    case "$PWD" in
        $TWRP_ROOT/*) ;;
        *) echo "refusing to build outside $TWRP_ROOT (cwd=$PWD)" >&2; return 1;;
    esac
}
export ALLOW_MISSING_DEPENDENCIES=true
