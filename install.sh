#!/bin/bash

# egl
FILES="lib/egl/libEGL_mali.so lib/egl/libGLESv1_CM_mali.so lib/egl/libGLESv2_mali.so lib/libMali.so lib/libdpframework.so \
       lib/libm4u.so lib/libion.so lib/hw/hwcomposer.mt6592.so lib/hw/gralloc.mt6592.so"

# wifi
#FILES=$FILES" /bin/wpa_supplicant /bin/wpa_cli /lib/libwapi.so /bin/mtkbt"

# factory
#FILES=$FILES" /bin/factory /lib/libnvram.so /lib/libcustom_nvram.so /lib/libnvram_sec.so /lib/libnvram_platform.so /lib/libhwm.so \
#              /lib/libfile_op.so /lib/libaudiocustparam.so /lib/libaudio.primary.default.so /lib/libblisrc.so /lib/libmtk_drvb.so \
#              /lib/libspeech_enh_lib.so /lib/libaudiosetting.so /lib/libaudiocompensationfilter.so /lib/libbessound_mtk.so \
#              /lib/libcvsd_mtk.so /lib/libmsbc_mtk.so /lib/libaudiocomponentengine.so /lib/libblisrc32.so /lib/libbessound_hd_mtk.so \
#              /lib/libmtklimiter.so /lib/libmtkshifter.so /lib/libaudiodcrflt.so /lib/libaed.so /lib/libbluetoothdrv.so \
#              "

#FILES=$FILES" /lib/libbtsession.so /lib/libextsys.so /lib/libpalsecurity.so /lib/libpalwlan_mtk.so /lib/libbtcust.so \
#            /lib/libbtcusttable.so"

FILES=$FILES" /bin/wmt_loader /bin/6620_launcher /bin/6620_wmt_concurrency /bin/6620_wmt_lpbk"

adb shell mount -o remount,rw /system

for i in $FILES; do
  adb push ./$i /system/$i || exit 1
done

#adb shell chmod 0777 /system/bin/wlan_loader
#adb shell chmod 0777 /system/bin/wpa*
#adb shell chmod 0777 /system/bin/factory
#adb shell chmod 0777 /system/bin/mtkbt
adb shell chmod 0777 /system/bin/wmt_loader
adb shell chmod 0777 /system/bin/6620_*

adb push ./etc/firmware/ /etc/firmware/
adb push ./etc/wifi/ /etc/wifi/

