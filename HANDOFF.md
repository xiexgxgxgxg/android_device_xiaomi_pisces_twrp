# Xiaomi Mi 3 TD (pisces) TWRP / Kernel 交接文档

日期：2026-11-02
设备：Xiaomi Mi 3 TD（codename pisces，NVIDIA Tegra 4 / T114，32-bit Cortex-A15）
内核：3.4.35（NVIDIA/Xiaomi 原厂，ARM32）
Recovery 分区：16 MiB

## 1. 目标与路线图

- 先做出可用的 TWRP；
- 之后逐步把 Android 用户空间抬到更高版本：A9 → A11 → A13 …… 理想 A17；
- 后期涉及 system 分区合并 / 扩容。
- 当前阶段：TWRP 3.0.2 已可用；TWRP 3.7.0_9（Android 9）已能进 UI、adb 能连，shell 权限已修（待真机验证），MTP 待加回。

## 2. 当前可用产物

| 文件 | 说明 | SHA256 |
|---|---|---|
| recovery60-fstab.img | TWRP 3.0.2（Android 6.0 基底），adb root + MTP + 挂载正常 | 见 images.sha256 |
| recovery9-perm2.img | TWRP 3.7.0_9（Android 9 基底），adb 用 3.0 的 adbd，/sbin 权限已修 | 见 images.sha256 |
| twrp-3.0.2-pisces-working.img | 与 recovery60-fstab 相同，桌面留存版 | 066E6A66…10CB5 |

原厂 recovery：pisces_images_V9.2.3.0.KXCCNEK_20171229.0000.00_4.4_cn/images/recovery.img

## 3. 目录结构（WSL 中的工作区）

/home/xie/twrp-pisces/
  source/          TWRP 12.1（Android 12，失败，保留参考）
  source-9.0/      TWRP 9.0（Android 9，TWRP 3.7.0_9）
  source-7.1/      TWRP 7.1（未继续）
  source-6.0/      TWRP 6.0（Android 6，TWRP 3.0.2，可用）
  kernel/          pisces 3.4.35 内核源码
  kernel-out/      内核编译输出
  toolchain/       jdk8、python2.7、arm-linux-androideabi-4.9 引用
  handoff/         本交接包
  logs/            构建日志

## 4. 源码获取（实体 Linux 上重做）

TWRP 使用 minimal-manifest-twrp / Omni manifest：

- TWRP 6.0: repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-6.0
- TWRP 7.1: 同上 -b twrp-7.1
- TWRP 9.0: 同上 -b twrp-9.0
- TWRP 12.1: platform_manifest_twrp_aosp -b twrp-12.1

注意：twrp-9.0/6.0 manifest 里 bootable/recovery 默认可能指到 android-9.0；
需要手动切换：
  git -C bootable/recovery fetch TeamWin android-6.0 && checkout FETCH_HEAD  # 3.0.2
  git -C bootable/recovery fetch TeamWin android-9.0 && checkout FETCH_HEAD  # 3.7.0

设备树：https://github.com/xiexgxgxgxg/android_device_xiaomi_pisces_twrp
分支：twrp3.0.2 / twrp.3.7.0

## 5. 构建环境（Ubuntu 24.04）

必需：
- openjdk-8（Android 9 需要 tools.jar；Android 6 也可用）
- python2.7（Android 6/9 构建脚本大量 python2；Ubuntu 24.04 无包，需源码编译）
- flex、bison、gcc、g++、make、rsync、cpio、zip、unzip、bc、libssl-dev
- arm-linux-androideabi-4.9（可来自源码 prebuilts）
- 建议 32GB+ RAM，-j24

本机特殊处理：
1. Python2.7 源码编译到 toolchain/python2，构建时 PATH 前置其 bin。
2. prebuilts/misc/linux-x86/flex/flex-2.5.39 在现代 glibc 会 abort，
   替换为脚本：#!/bin/sh exec /usr/bin/flex "$@"
3. TWRP 9.0 的 dumpkey 源码在 bootable/recovery/tools/dumpkey，
   但构建系统找 build/tools/dumpkey，需要软链：
   ln -s ../../bootable/recovery/tools/dumpkey build/tools/dumpkey
4. build/make 的 python 脚本（check_radio_versions.py、post_process_props.py）
   需要 python2（或打完 3.7.0 补丁后用 python3 也可，但建议直接用 python2）。
5. ccache 在 WSL 只读文件系统会失败，建议 USE_CCACHE=0。

## 6. 设备树分支说明

### twrp3.0.2（可用）
- omni_pisces.mk：继承 embedded.mk + vendor/omni/config/common.mk
- BoardConfig.mk：TARGET_PREBUILT_KERNEL、16MiB recovery、TW_THEME=portrait_hdpi
- recovery/twrp.fstab：mmcblk 直连（SOS/LNX/APP/UDA/CAC/PST/MDA/USP 的编号）
  recovery=p21, boot=p19, system=p24, cache=p26, data=p27, persist=p23, misc=p14, staging=p9
- recovery/root/init.recovery.pisces.rc：USB/adbd 早期配置
- kernel：twrp2/CM12 内核（无 VT，adb/MTP 可用）
- 补丁：patches/3.0.2/system_core.patch（init 跳过 SELinux policy）
- bootable/recovery 的 init.recovery.usb.rc 修复 enable ${service.adb.root} 空值

### twrp.3.7.0（进行中）
- 设备树同上思路，fstab 用 mmcblk 直连
- kernel：原厂 MIUI 内核（6,726,552 字节）
- adbd：替换为 TWRP 3.0 的静态 adbd（Android 9 自带 adbd 在该内核上 offline）
- 补丁：patches/3.7.0/ 下 bionic / system_core / build_make / bootable_recovery
- 已知问题：adb shell 需要 /sbin 0755（recovery9-perm2.img 已修，待验证）；MTP 待加回

## 7. TWRP 3.7 的关键补丁（Android 9 on 3.4 kernel）

逐个文件：
- system/core/init/selinux.cpp：跳过 SELinux policy 加载（内核只支持 policy 15-26，A9 是 30）
- bionic/libc/bionic/system_property_api.cpp：忽略 security.selinux xattr 失败
- system/core/init/property_service.cpp：无 policy 时 CheckMacPerms 放行
- system/core/init/init.cpp：getenv(INIT_STARTED_AT/INIT_SELINUX_TOOK) 判空；signal handler 记录 init_crash
- system/core/init/security.cpp：无 mmap_rnd_bits 时跳过 SetMmapRndBits
- system/core/init/log.cpp：/sys/fs/selinux/null 打不开时回退 /dev/null
- system/core/init/service.cpp：无 SELinux 时跳过 seclabel / ComputeContextFromExecutable
- system/core/init/subcontext.cpp：无 SELinux 时不建 vendor_init 子上下文
- bootable/recovery/etc/init.rc：adbd 去掉 --root_seclabel/seclabel；删掉 service.adb.root 的 restart 动作
- bootable/recovery/etc/init.recovery.usb.rc：修 enable 空值；USB 改为先起 adbd 再延迟 enable
- build/make/core/Makefile：16MiB 裁剪（python、ubsan、多语言只留 en）
- 注意：为了过 16MiB，砍掉了 twres 语言包（只留 en.xml）、python、ubsan；MTP 暂关。

## 8. 构建命令

3.0.2：
  source env.sh
  export TWRP_SOURCE=/home/xie/twrp-pisces/source-6.0
  export JAVA_HOME=/home/xie/twrp-pisces/toolchain/jdk8
  export PATH=/home/xie/twrp-pisces/toolchain/python2/bin:$JAVA_HOME/bin:$PATH
  cd $TWRP_SOURCE
  source build/envsetup.sh
  lunch omni_pisces-eng
  mka recoveryimage -j24

3.7.0：同上，TWRP_SOURCE=source-9.0

产物：out/target/product/pisces/recovery.img，需 < 16,777,216 字节。

## 9. 内核 3.4.35 已知坑

- 无 devtmpfs：Android init 早期挂载 /dev 失败 → CONFIG_DEVTMPFS=y
- 无 64-bit binder：ARM32 用 32-bit binder（TARGET_USES_64_BIT_BINDER 不要开）
- SELinux policy 版本只到 26，A9 的 30 加载失败 → 跳过 policy
- 无 mmap_rnd_bits（4.x 才有）→ 跳过
- 无 hw_random 可用（可忽略）
- VT/fbcon 的 con_insert_unipair 有 bug：开 CONFIG_VT + console=tty0 会 Oops
  → 调试内核不要开 VT；需要串口日志时另想办法
- Android 9 adbd 在 3.4 上 offline；TWRP 3.0 的静态 adbd 可用
- adbd root 模式（service.adb.root=1）会触发 init.rc 的 restart 循环，已移除该动作

## 10. 真机测试协议（重要）

- 永远先 fastboot boot，不 fastboot flash recovery：
  fastboot boot D:\android\pisces-twrp\recovery60-fstab.img
- 失败黑屏时，长按电源 30s；因为 recovery 分区未写，系统还能起。
- 一旦 flash 了坏 recovery，BCB 会反复进 recovery，fastboot 可能进不去，只能 APX。
- APX 会清 RAM，last_kmsg 丢失；所以日志要在此之前抓。
- 当前设备状态：进 fastboot；用 fastboot boot 恢复即可。

## 11. 迁移到实体 Linux

1. 安装 Ubuntu 24.04，装第 5 节依赖；
2. 把本 handoff 包放到 /home/xie/twrp-pisces/；
3. 按第 4 节 repo init/sync（源码树太大，不随包备份）；
4. 把 device/pisces-3.0.2 或 pisces-3.7.0 复制到 source 的 device/xiaomi/pisces；
5. 应用 patches/ 下对应补丁（git apply），并做 flex/dumpkey 处理；
6. 按第 8 节编译；
7. 真机按第 10 节测试。

## 12. 未完成 / 下一步

- 验证 recovery9-perm2.img 的 adb shell（/sbin 0755 修复）；
- 加回 MTP（需挂载 /dev/usb-ffs/mtp，functions mtp,adb，并确认 3.4 内核 f_mtp）；
- 3.7 版本固化、去掉调试脚本（copy9log/ffsenable 可按需保留）；
- 再往上 A11/A13 时，优先解决 kernel backport（seccomp filter、getrandom、memfd 等）。

## 13. 备注

- 3.7.0 的 init 补丁里删掉了 root adb 的 restart；所以 3.7 的 adb 是 shell 权限，不是 root。
  需要 root 日志时用 TWRP 3.0，或另做 root 变体。
- 所有补丁都在 patches/ 下，可直接 git apply；设备树分支也包含同样内容。
