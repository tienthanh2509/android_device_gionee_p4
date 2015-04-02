## Specify phone tech before including full_phone
$(call inherit-product, vendor/cm/config/gsm.mk)

# Release name
PRODUCT_RELEASE_NAME := rainbow

# Inherit some common CM stuff.
$(call inherit-product, vendor/cm/config/common_full_phone.mk)

# Inherit device configuration
$(call inherit-product, device/wiko/rainbow/device_rainbow.mk)

# Boot animation
TARGET_SCREEN_HEIGHT := 1280
TARGET_SCREEN_WIDTH := 720

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := rainbow
PRODUCT_NAME := cm_rainbow
PRODUCT_BRAND := wiko
PRODUCT_MODEL := rainbow
PRODUCT_MANUFACTURER := wiko
