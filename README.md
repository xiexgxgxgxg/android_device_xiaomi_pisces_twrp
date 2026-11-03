# android_device_xiaomi_pisces_twrp

Xiaomi Mi 3 TD（codename **pisces**）的 TWRP 设备树。

## 设备信息

| 项目 | 值 |
|---|---|
| SoC | NVIDIA Tegra 4（T114），32-bit Cortex-A15 |
| 内核 | 3.4.35（Xiaomi MIUI 原厂，ARM32） |
| Recovery 分区 | 16 MiB |
| 分区节点 | 直连 `mmcblk0p*`（by-name 为 SOS/LNX/APP/UDA/CAC/PST/MDA/USP） |
| 分区尺寸 | system 4 GiB（已重分区）/ cache 384 MiB / userdata ~10 GiB |
| 屏幕 | 1080x1920 |

## 分支

| 分支 | TWRP | Android 基底 | 状态 |
|---|---|---|---|
| **twrp.3.7.0**（默认） | 3.7.0_9 | 9 | 可用：UI、root adb、adb push、Format Data、MTP（legacy，开机自动启用） |
| twrp3.0.2 | 3.0.2 | 6.0 | 可用：root adb + MTP，作为基线保留 |

## twrp.3.7.0 当前状态

已验证（真机 `fastboot boot`）：

- 开机进入 TWRP UI
- `adb shell` 为 **root**（`uid=0`），`adb root` 提示 already running as root
- `adb push` 到 `/sdcard`、`/data/local/tmp`
- `Format Data`（`twrp format data`）正常
- `dmesg` / `/tmp/recovery.log` 可读
- MTP：走 **legacy f_mtp**（`/dev/mtp_usb`），开机自动启用（`tw_mtp_enabled` 默认 1），
  USB 描述符为 `18d1:4ee2`（MTP + adb）

关键修复（相对最初交接版本）：

| 问题 | 修复 | 位置 |
|---|---|---|
| adb shell `Permission denied` | `sbin` / `sbin/*` 改为 `0755 root:root` | `patches/0003-system-core-sbin-world-exec.patch` |
| Android 版本显示 16.1.0 | `PLATFORM_VERSION` 改为 `9` | `patches/0004-build-make-platform-version-9.patch` |
| 没有 root | A9 adbd + `service.adb.root=1` + `sys.usb.ffs.aio_compat=1` | `recovery/root/init.recovery.pisces.rc` |
| Format Data 失败 | 去掉 `/data` 上错误的 `encryptable=` | `recovery/twrp.fstab` |
| A9 adbd 在 3.4 上 offline | 3.4 的 f_fs 无 AIO，A9 adbd 必须退回同步读写 | `sys.usb.ffs.aio_compat=1` |
| MTP 缺失 | `TW_MTP_LEGACY := true` + `functions mtp,ffs` | `BoardConfig.mk` / `init.recovery.usb.rc` |

## 编译

源码树使用 TWRP minimal manifest：

```bash
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0
repo sync -c -j8 --no-tags
```

把本设备树放到 `device/xiaomi/pisces`，应用 `patches/` 下补丁，然后：

```bash
source build/envsetup.sh
lunch omni_pisces-eng
mka recoveryimage -j16
```

产物：`out/target/product/pisces/recovery.img`，必须 **< 16,777,216 字节**。

> 现代发行版（Ubuntu 24.04/26.04）需要额外兼容处理（python2、prebuilts shebang、libtinfo5、locale、`LC_ALL=C`），
> 详见 `HANDOFF.md` 第 14 节。

## 目录

```
recovery/             recovery 资源、fstab、root（init rc、sbin）
patches/              针对源码树的补丁（build/make、system/core 等）
patch/                设备树自身历史补丁
audio/ gps/ ...       其他 blobs 配置（本阶段未使用）
kernel                TWRP 使用的预编译内核（3.4.35）
```

## 测试协议（重要）

**永远先 `fastboot boot`，不要直接 `fastboot flash recovery`**：

```bash
fastboot boot recovery.img
```

失败黑屏时长按电源键 30s 重启即可，recovery 分区未被写入，系统仍可启动。

## 分区（4GB system）

2026-11-03 已用 `repartition/pisces-4gb-repartition.zip` 将 system 扩容到 4 GiB：

| 分区 | 原厂 | 现在 |
|---|---|---|
| system (p24) | 640 MiB | 4096 MiB |
| AP1 (p25) | 640 MiB | 8 MiB 占位 |
| cache (p26) | 384 MiB | 384 MiB |
| userdata (p27) | 13044 MiB | 10220 MiB |

详见 `repartition/README.md`。

## 后续计划

- [x] TWRP 3.7.0_9 可用（root adb / push / Format Data / MTP）
- [ ] 内核 3.4.35 → 3.4.113 稳定版合并
- [ ] Android 用户空间继续上探（A11/A13），需内核 backport（SELinux policy、seccomp、getrandom、memfd）
- [ ] system 分区合并 / 扩容
