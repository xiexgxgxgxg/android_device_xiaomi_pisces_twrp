#!/bin/bash
cd /home/xie/twrp-pisces/source-7.1 || exit 1
export GIT_CONFIG_GLOBAL=/home/xie/twrp-pisces/gitconfig
export HTTPS_PROXY=http://127.0.0.1:17890
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-7.1 --depth=1
repo sync -c -j12 --force-sync --no-clone-bundle --no-tags
echo "SYNC71_RC=$?"
