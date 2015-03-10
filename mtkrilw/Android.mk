# Copyright 2006 The Android Open Source Project

# XXX using libutils for simulator build only...
#
LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
    mtkrilw.c

LOCAL_SHARED_LIBRARIES := \
    liblog libcutils libutils libril librilutils

# for asprinf
LOCAL_CFLAGS := -D_GNU_SOURCE

LOCAL_C_INCLUDES := $(KERNEL_HEADERS)

#USE HCRADIO
ifeq ($(BOARD_USES_HC_RADIO),true) 
LOCAL_CFLAGS += -DHCRADIO
endif

ifeq ($(TARGET_DEVICE),sooner)
  LOCAL_CFLAGS += -DOMAP_CSMI_POWER_CONTROL -DUSE_TI_COMMANDS
endif

ifeq ($(TARGET_DEVICE),surf)
  LOCAL_CFLAGS += -DPOLL_CALL_STATE -DUSE_QMI
endif

ifeq ($(TARGET_DEVICE),dream)
  LOCAL_CFLAGS += -DPOLL_CALL_STATE -DUSE_QMI
endif

LOCAL_SHARED_LIBRARIES += \
    libcutils libutils \
    libdl

LOCAL_LDLIBS += -lpthread
LOCAL_CFLAGS += -DRIL_SHLIB
LOCAL_MODULE := libmtkrilw

include $(BUILD_SHARED_LIBRARY)

