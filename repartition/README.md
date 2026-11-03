# pisces 4GB system 重分区模块

适用于 Xiaomi Mi 3 TD（pisces，Tegra 4）。

## 结果

| 分区 | 原厂 | 新 |
|---|---|---|
| APP / system (p24) | 640 MiB | **4096 MiB** |
| AP1 (p25) | 640 MiB | 8 MiB（占位，保持 cache=26 / data=27 编号） |
| CAC / cache (p26) | 384 MiB | 384 MiB |
| UDA / userdata (p27) | 13044 MiB | 10220 MiB |

## 刷入方式（重要）

直接放在 /sdcard 上、在 TWRP 里 Install 刷即可（已在真机双向验证）。

脚本每次重读分区表前都会重新卸载 `/system /cache /data /sdcard`，
绕开 TWRP 持有 zip 句柄导致 `BLKRRPART` 失败的问题。

备选：`adb push pisces-xxx.zip /tmp/ && adb shell twrp install /tmp/pisces-xxx.zip`

## 一步到位版（推荐，无需确认文件）

- `pisces-4gb-all.zip`：直接刷 → 改成 4GB 分区 + 格式化 system/cache/userdata → 自动重启 recovery
- `pisces-stock-all.zip`：直接刷 → 还原原厂分区 + 格式化 system/cache/userdata → 自动重启 recovery

刷之前有 5 秒倒计时警告，**都会清空 userdata**，没有二次确认文件。

## 使用顺序（带确认文件的安全版）

1. `pisces-stock-gpt-restore.zip`：还原原厂分区表（640/640/384/13044 MiB）+ 格式化 system/cache
   （想回到原厂布局时才用；**会清空 userdata**）
2. `pisces-4gb-repartition.zip`：改 GPT + 格式化 system/cache（**会清空 userdata**）
3. 重启 recovery（TWRP 里 Reboot → Recovery）
4. `pisces-4gb-format.zip`：如果第 2 步格式化失败，用这个补格式化 system/cache
5. TWRP → Wipe → Format Data：格式化 userdata

## 安全措施

- 脚本会校验设备是 pisces、当前分区表是原厂布局（p24 起始 524288，p27 结束 30646271）
- 需要先创建确认文件，防止误刷：
  `adb shell touch /sdcard/pisces-repartition-ok`
- 会自动把原厂 GPT 备份到 `/tmp/pisces-gpt-stock.bin`（重启后丢失，需要的话刷之前 `adb pull`）
- 主机侧备份：`gpt-backup-stock/pisces-gpt-stock.bin`（`sgdisk --load-backup=` 可恢复）

## 回滚到原厂分区

1. 创建确认文件：`adb shell touch /sdcard/pisces-repartition-ok`
2. 刷 `pisces-stock-gpt-restore.zip`
3. 重启 recovery，格式化 data/system/cache

## 实现说明

原米板 1 模块用 `parted`，但本机 TWRP 只带 `sgdisk`（0.8.10.2，短选项被裁掉，只能用长选项），
所以全部改用 `sgdisk --delete/--new/--change-name/--typecode/--verify` 实现，分区类型保持 `0700`。
