#!/bin/bash
cd /home/xie/twrp-pisces/source-9.0 || exit 1
export GIT_CONFIG_GLOBAL=/home/xie/twrp-pisces/gitconfig
export HTTPS_PROXY=http://127.0.0.1:17890
echo "=== start $(date) ==="
repo sync -c -j12 --force-sync --no-clone-bundle --no-tags
echo "SYNC9_RC=$?"
