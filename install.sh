#!/bin/bash

FILES="lib/egl/libEGL_mali.so lib/egl/libGLESv1_CM_mali.so lib/egl/libGLESv2_mali.so lib/libMali.so lib/libdpframework.so \
       lib/libm4u.so lib/libion.so lib/hw/hwcomposer.mt6592.so lib/hw/gralloc.mt6592.so \
       lib/hw/libaudio.usb.default.so lib/hw/libaudio.r_submix.default.so"

adb shell mount -o remount,rw /system

for i in $FILES; do
  adb push $i /system/$i || exit 1
done
