$(call inherit-product, $(SRC_TARGET_DIR)/product/embedded.mk)
# TWRP 3.5.x / Android 9 product for Xiaomi Mi 3 TD (pisces)
$(call inherit-product, vendor/omni/config/common.mk)
$(call inherit-product, device/xiaomi/pisces/device.mk)

PRODUCT_NAME := omni_pisces
PRODUCT_DEVICE := pisces
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := MI 3
PRODUCT_MANUFACTURER := Xiaomi

TARGET_SCREEN_WIDTH := 1080
TARGET_SCREEN_HEIGHT := 1920
