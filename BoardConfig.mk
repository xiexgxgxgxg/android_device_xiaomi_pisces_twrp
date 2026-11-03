# TWRP board configuration for Xiaomi Mi 3 TD (pisces, NVIDIA Tegra 4 / T114)
-include vendor/xiaomi/pisces/BoardConfigVendor.mk

LOCAL_PATH := device/xiaomi/pisces

TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
TARGET_TEGRA_VERSION := t114
TARGET_TEGRA_FAMILY := t11x
TARGET_BOARD_PLATFORM := tegra
TARGET_BOOTLOADER_BOARD_NAME := pisces
TARGET_OTA_ASSERT_DEVICE := pisces

# Architecture (32-bit ARM, Cortex-A15)
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_SMP := true
# 32-bit kernel, but Android 12 userspace must match the 64-bit binder ABI in the
# arm32 version script; recovery does not use binder at runtime.

TARGET_CPU_VARIANT := cortex-a15
TARGET_ARCH_VARIANT_CPU := cortex-a15

# Boot image layout (same as stock / CM-12.1 tree)
BOARD_KERNEL_CMDLINE := androidboot.hardware=pisces androidboot.selinux=permissive loglevel=8 ignore_loglevel keep_bootcon
BOARD_KERNEL_BASE := 0x10000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01000000 --tags_offset 0x00000100

# Filesystems
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := false

# Partition sizes
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x01000000
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x01000000
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 671088640
BOARD_USERDATAIMAGE_PARTITION_SIZE := 3758096384
BOARD_CACHEIMAGE_PARTITION_SIZE := 402653184
BOARD_PERSISTIMAGE_PARTITION_SIZE := 16777216
BOARD_FLASH_BLOCK_SIZE := 131072

# Kernel: prebuilt, replaced with debug build when needed
TARGET_PREBUILT_KERNEL := $(LOCAL_PATH)/kernel

# Recovery
TARGET_RECOVERY_FSTAB := $(LOCAL_PATH)/recovery/twrp.fstab
RECOVERY_FSTAB_VERSION := 2
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
RECOVERY_GRAPHICS_USE_LINELENGTH := true

# TWRP
TW_THEME := portrait_hdpi
TW_DEVICE_VERSION := 1
TW_CUSTOM_BATTERY_PATH := /sys/devices/platform/tegra11-i2c.0/i2c-0/0-0036/power_supply/max170xx_battery/
TW_BRIGHTNESS_PATH := /sys/class/backlight/lm3533-backlight0/brightness
TW_SECONDARY_BRIGHTNESS_PATH := /sys/class/backlight/lm3533-backlight1/brightness
TW_MAX_BRIGHTNESS := 255
TW_NO_SCREEN_BLANK := true
TW_NO_SCREEN_TIMEOUT := true
TW_EXCLUDE_SUPERSU := true

# Graphics
BOARD_EGL_CFG := $(LOCAL_PATH)/egl.cfg
USE_OPENGL_RENDERER := true
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3

# Keep the recovery image inside the 16 MiB partition
TW_EXCLUDE_BASH := true
TW_EXCLUDE_NANO := true
TW_EXCLUDE_TZDATA := true
TW_EXCLUDE_ZIP := true
TW_EXCLUDE_LPDUMP := true
TW_EXCLUDE_LPTOOLS := true
TW_EXCLUDE_APEX := true
# MTP: 3.4 kernel has f_mtp only, use the legacy implementation
TW_MTP_LEGACY := true
