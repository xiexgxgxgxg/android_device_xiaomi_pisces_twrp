# TWRP product for Xiaomi Mi 3 TD (pisces)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, vendor/twrp/config/common.mk)

PRODUCT_NAME := twrp_pisces
PRODUCT_DEVICE := pisces
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := MI 3
PRODUCT_MANUFACTURER := Xiaomi

TARGET_SCREEN_WIDTH := 1080
TARGET_SCREEN_HEIGHT := 1920
