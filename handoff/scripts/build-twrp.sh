#!/usr/bin/env bash
# Build TWRP for Xiaomi Mi 3 TD (pisces) in the isolated tree.
# CPU budget: -j8 (yuechu/LineageOS build gets the rest).
set -euo pipefail

source /home/xie/twrp-pisces/env.sh
cd "$TWRP_SOURCE"
guard_twrp

LOG="$TWRP_ROOT/logs/build-$(date +%Y%m%d-%H%M%S).log"
echo "log: $LOG"

{
  echo "=== env ==="
  echo "TWRP_ROOT=$TWRP_ROOT"
  echo "OUT_DIR=$OUT_DIR"
  echo "CCACHE_DIR=$CCACHE_DIR"
  echo "JAVA_HOME=$JAVA_HOME"
  free -g
  echo "=== lunch ==="
  source build/envsetup.sh
  lunch twrp_pisces-eng
  echo "=== build recovery -j8 ==="
  mka recovery -j8
  echo "BUILD_RC=$?"
} 2>&1 | tee "$LOG"

# copy artifact
if [ -f "$OUT_DIR/target/product/pisces/recovery.img" ]; then
  mkdir -p "$DIST_DIR"
  cp -f "$OUT_DIR/target/product/pisces/recovery.img" \
        "$DIST_DIR/recovery-pisces-$(date +%Y%m%d-%H%M).img"
  ls -l "$DIST_DIR"
fi
