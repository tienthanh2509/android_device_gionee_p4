$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# The gps config appropriate for this device
$(call inherit-product, device/common/gps/gps_us_supl.mk)

$(call inherit-product-if-exists, vendor/wiko/rainbow/rainbow-vendor.mk)

PRODUCT_CHARACTERISTICS := nosdcard

DEVICE_PACKAGE_OVERLAYS += device/wiko/rainbow/overlay

LOCAL_PATH := device/wiko/rainbow
ifeq ($(TARGET_PREBUILT_KERNEL),)
	LOCAL_KERNEL := $(LOCAL_PATH)/kernel
else
	LOCAL_KERNEL := $(TARGET_PREBUILT_KERNEL)
endif

PRODUCT_PACKAGES += \
    libxlog

PRODUCT_PACKAGES += \
    lights.mt6582

PRODUCT_PACKAGES += \
    libmtkrilw

PRODUCT_PACKAGES += \
    audio.r_submix.default

PRODUCT_PACKAGES += \
    audio.primary.mt6582

PRODUCT_PACKAGES += \
    audio_policy.default

PRODUCT_PACKAGES += \
    lib_driver_cmd_mt66xx

PRODUCT_COPY_FILES += \
    device/wiko/rainbow/mtk-kpd.kl:system/usr/keylayout/mtk-kpd.kl

PRODUCT_COPY_FILES += \
    device/wiko/rainbow/init.recovery.mt6582.rc:root/init.recovery.mt6582.rc

PRODUCT_COPY_FILES += \
    device/wiko/rainbow/audio/audio_policy.conf:system/etc/audio_policy.conf

PRODUCT_COPY_FILES += \
    device/wiko/rainbow/fstab.mt6582:root/fstab.mt6582 \
    device/wiko/rainbow/init.mt6582.rc:root/init.mt6582.rc \
    $(LOCAL_KERNEL):kernel

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml


$(call inherit-product, build/target/product/full.mk)

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0
PRODUCT_NAME := full_rainbow
PRODUCT_DEVICE := rainbow

$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)
