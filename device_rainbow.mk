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

PRODUCT_TAGS += dalvik.gc.type-precise

PRODUCT_PACKAGES += \
    libxlog

PRODUCT_PACKAGES += \
    lights.mt6582

PRODUCT_PACKAGES += \
    libmtkrilw

# audio
PRODUCT_PACKAGES += \
    audio.r_submix.default

PRODUCT_PACKAGES += \
    audio.primary.mt6582

PRODUCT_PACKAGES += \
    audio_policy.default

PRODUCT_PACKAGES += \
    lib_driver_cmd_mt66xx

PRODUCT_COPY_FILES += \
    device/wiko/rainbow/rootdir/configs/mtk-kpd.kl:system/usr/keylayout/mtk-kpd.kl

PRODUCT_COPY_FILES += \
    device/wiko/rainbow/rootdir/root/fstab.mt6582:root/fstab.mt6582 \
    device/wiko/rainbow/rootdir/root/init.rc:root/init.rc \
    device/wiko/rainbow/rootdir/root/init.mt6582.rc:root/init.mt6582.rc \
    device/wiko/rainbow/rootdir/root/init.project.rc:root/init.project.rc \
    device/wiko/rainbow/rootdir/root/init.usb.rc:root/init.usb.rc \
    device/wiko/rainbow/rootdir/root/factory_init.rc:root/factory_init.rc \
    device/wiko/rainbow/rootdir/root/init.fuse.rc:root/init.fuse.rc \
    device/wiko/rainbow/rootdir/root/init.modem.rc:root/init.modem.rc \
    device/wiko/rainbow/rootdir/root/init.xlog.rc:root/init.xlog.rc \
    device/wiko/rainbow/rootdir/root/ueventd.mt6582.rc:root/ueventd.mt6582.rc \
    device/wiko/rainbow/rootdir/root/init.mt6582.usb.rc:root/init.mt6582.usb.rc \
    $(LOCAL_KERNEL):kernel

PRODUCT_COPY_FILES += \
	device/wiko/rainbow/rootdir/configs/android.hardware.microphone.xml:system/etc/permissions/android.hardware.microphone.xml \
	device/wiko/rainbow/rootdir/configs/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
	frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml \
	frameworks/native/data/etc/android.hardware.bluetooth.xml:system/etc/permissions/android.hardware.bluetooth.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
	frameworks/native/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
	frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml

PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/rootdir/configs/media_codecs.xml:system/etc/media_codecs.xml \
	$(LOCAL_PATH)/rootdir/configs/media_profiles.xml:system/etc/media_profiles.xml

$(call inherit-product, build/target/product/full.mk)

PRODUCT_PROPERTY_OVERRIDES := \
	ro.mediatek.version.release=ALPS.W10.24.p0 \
	ro.mediatek.platform=MT6582 \
	ro.mediatek.chip_ver=S01 \
	ro.mediatek.version.branch=KK1.MP1 \
	ro.mediatek.version.sdk=2 \
	ro.telephony.sim.count=2 \
	persist.mtk.wcn.combo.chipid=-1

PRODUCT_NAME := full_rainbow
PRODUCT_DEVICE := rainbow

$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)
