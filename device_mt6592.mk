$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# The gps config appropriate for this device
$(call inherit-product, device/common/gps/gps_us_supl.mk)

$(call inherit-product-if-exists, vendor/mediatek/mt6592/mt6592-vendor.mk)

DEVICE_PACKAGE_OVERLAYS += device/mediatek/mt6592/overlay

LOCAL_PATH := device/mediatek/mt6592
ifeq ($(TARGET_PREBUILT_KERNEL),)
	LOCAL_KERNEL := $(LOCAL_PATH)/kernel
else
	LOCAL_KERNEL := $(TARGET_PREBUILT_KERNEL)
endif

PRODUCT_COPY_FILES += \
    device/mediatek/mt6592/fstab.mt6592:root/fstab.mt6592 \
    device/mediatek/mt6592/init.mt6592.rc:root/init.mt6592.rc \
    $(LOCAL_KERNEL):kernel

$(call inherit-product, build/target/product/full.mk)

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0
PRODUCT_NAME := full_mt6592
PRODUCT_DEVICE := mt6592

