# pisces → LineageOS 16.0 迁移清单

底座：本仓库 `twrp3.0.2` 分支的 CM12（Android 5.1）设备树。
目标：LineageOS 16.0（Android 9）+ 3.4.113 内核（`android_kernel_xiaomi_pisces` 的 `lineage-16.0-113` 分支）。

## 已完成
- [x] 新分支 `lineage-16.0`，`lineage_pisces.mk` / `AndroidProducts.mk`
- [x] 内核：3.4.35 + 3.4.113 通用子系统合并，真机（TWRP）验证可启动

## 待做（按依赖顺序）

### 1. 构建系统
- [ ] `BoardConfig.mk`：`BOARD_SEPOLICY_DIRS`、`TARGET_USES_MKE2FS`、`TARGET_USES_HWC2`/HWC2On1Adapter 选择
- [ ] `device.mk`：A9 必需的 HIDL 服务包（light/vibrator/health/power/memtrack 等）
- [ ] `fstab.pisces`：A9 格式（vold 管理项、`/vendor` 不存在时的兼容写法）
- [ ] `init.pisces.rc` / `ueventd.pisces.rc`：A9 init 语法（旧 `write /proc/...`、`on fs` 写法需要重写）

### 2. HAL（A9 强制 HIDL）
- [ ] gralloc / HWC：Tegra 4 是 HWC1，需要 HWC2On1Adapter 或重写 HWC2
- [ ] audio：legacy `audio.primary.tegra.so` + `audio@2.0` shim
- [ ] sensors / gnss / camera：legacy HAL + HIDL 包装服务
- [ ] lights / vibrator / health / power / memtrack：HIDL 1.0/2.0
- [ ] keymaster：Tegra 4 无 Trusty，走软件 keymaster

### 3. sepolicy
- [ ] 基于 A9 policy 重写 device sepolicy（CM12 的 5.1 规则不能直接用）
- [ ] 先 permissive 起步，再逐条收紧

### 4. blobs
- [ ] 用 `extract-files.sh` 从 MIUI 4.4 提取；A9 需要把部分 blob 放到 `/vendor`（无 vendor 分区时用 `/system/vendor`）
- [ ] `proprietary-files.txt` 按 A9 需求补全（graphics/audio/camera/wifi/bt/nfc/gps）

### 5. 内核
- [ ] backport：`getrandom`、`memfd_create`、seccomp filter、`mmap_rnd_bits`（已有 patch 思路）
- [ ] 逐步把 crypto/thermal/sched 等厂家子系统迁到 3.4.113 API

## 里程碑
1. `brunch pisces` 能编出 zip
2. 能进 bootanimation（抓 log）
3. 进桌面（图形/输入/存储）
4. 电话/WiFi/蓝牙/相机
