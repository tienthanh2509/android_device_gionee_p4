$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# The gps config appropriate for this device
$(call inherit-product, device/common/gps/gps_us_supl.mk)

$(call inherit-product-if-exists, vendor/mediatek/mt6592/mt6592-vendor.mk)

PRODUCT_CHARACTERISTICS := nosdcard

DEVICE_PACKAGE_OVERLAYS += device/mediatek/mt6592/overlay

LOCAL_PATH := device/mediatek/mt6592
ifeq ($(TARGET_PREBUILT_KERNEL),)
	LOCAL_KERNEL := $(LOCAL_PATH)/kernel
else
	LOCAL_KERNEL := $(TARGET_PREBUILT_KERNEL)
endif

PRODUCT_PACKAGES += \
    libxlog

PRODUCT_PACKAGES += \
    lights.mt6592

PRODUCT_PACKAGES += \
    libmtkrilw

PRODUCT_PACKAGES += \
    audio.r_submix.default

PRODUCT_PACKAGES += \
    audio.primary.mt6592

PRODUCT_PACKAGES += \
    audio_policy.default

PRODUCT_PACKAGES += \
    lib_driver_cmd_mt66xx

PRODUCT_COPY_FILES += \
    device/mediatek/mt6592/mtk-kpd.kl:system/usr/keylayout/mtk-kpd.kl

PRODUCT_COPY_FILES += \
    device/mediatek/mt6592/init.recovery.mt6592.rc:root/init.recovery.mt6592.rc

PRODUCT_COPY_FILES += \
    device/mediatek/mt6592/audio/audio_policy.conf:system/etc/audio_policy.conf

PRODUCT_COPY_FILES += \
    device/mediatek/mt6592/fstab.mt6592:root/fstab.mt6592 \
    device/mediatek/mt6592/init.mt6592.rc:root/init.mt6592.rc \
    $(LOCAL_KERNEL):kernel

$(call inherit-product, build/target/product/full.mk)

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0
PRODUCT_NAME := full_mt6592
PRODUCT_DEVICE := mt6592

$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)
