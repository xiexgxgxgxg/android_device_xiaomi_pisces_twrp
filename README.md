# android_device_xiaomi_pisces_twrp

Xiaomi Mi 3 TD（codename **pisces**）的 TWRP 设备树。

## 设备信息

| 项目 | 值 |
|---|---|
| SoC | NVIDIA Tegra 4（T114），32-bit Cortex-A15 |
| 内核 | 3.4.35（Xiaomi MIUI / CM12，ARM32） |
| Recovery 分区 | 16 MiB |
| 分区节点 | 直连 `mmcblk0p*`（by-name 为 SOS/LNX/APP/UDA/CAC/PST/MDA/USP） |
| 屏幕 | 1080x1920 |

## 分支

| 分支 | TWRP | Android 基底 | 状态 |
|---|---|---|---|
| twrp.3.7.0（默认） | 3.7.0_9 | 9 | 可用：UI、root adb、adb push、Format Data、MTP（legacy） |
| **twrp3.0.2**（本分支） | 3.0.2 | 6.0 | 可用：root adb + MTP + 挂载正常，作为基线保留 |

本分支是最早跑通的版本，稳定性最好；3.7.0_9 的调试以其行为作为对照。

## 已验证（twrp3.0.2）

- 开机进入 TWRP UI
- `adb shell` 为 root（`service.adb.root=1`）
- MTP 可用（`functions=mtp,ffs`，`/dev/mtp_usb`）
- `/system` `/data` `/cache` `/persist` 等分区挂载正常
- USB 存储 / adb 侧载可用

## 编译

源码树使用 TWRP minimal manifest（Android 6.0）：

```bash
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-6.0
repo sync -c -j8 --no-tags
```

把本设备树放到 `device/xiaomi/pisces`，应用 `patches/` 下补丁，然后：

```bash
source build/envsetup.sh
lunch omni_pisces-eng
mka recoveryimage -j24
```

产物：`out/target/product/pisces/recovery.img`，必须 **< 16,777,216 字节**。

> Android 6 构建脚本依赖 python2.7；现代发行版需自行编译或解包 python2，
> 详见 `HANDOFF.md`。

## 目录

```
recovery/             recovery 资源、fstab、root（init rc）
patches/              针对源码树的补丁
patch/                设备树自身历史补丁
audio/ gps/ ...       其他 blobs 配置
kernel                TWRP 使用的预编译内核（3.4.35）
```

## 测试协议（重要）

**永远先 `fastboot boot`，不要直接 `fastboot flash recovery`**：

```bash
fastboot boot recovery.img
```

失败黑屏时长按电源键 30s 重启即可，recovery 分区未被写入，系统仍可启动。

## 后续计划

- [x] TWRP 3.0.2 基线可用
- [x] TWRP 3.7.0_9 可用（见 twrp.3.7.0 分支）
- [ ] 内核 3.4.35 → 3.4.113 稳定版合并
- [ ] Android 用户空间继续上探（A11/A13）
- [ ] system 分区合并 / 扩容
