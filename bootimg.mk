LOCAL_PATH := $(call my-dir)

$(recovery_uncompressed_ramdisk): $(MINIGZIP) \
	$(TARGET_RECOVERY_ROOT_TIMESTAMP)
	@echo -e ${CL_CYN}"----- Making uncompressed recovery ramdisk mtk ------"${CL_RST}
	$(MKBOOTFS) $(TARGET_RECOVERY_ROOT_OUT) > $@

$(recovery_ramdisk): $(MKBOOTFS) \
	$(recovery_uncompressed_ramdisk)
	@echo -e ${CL_CYN}"----- Making recovery mtk ramdisk ------"${CL_RST}
	$(MINIGZIP) < $(recovery_uncompressed_ramdisk) > $@
	device/mediatek/mt6592/pack.pl RECOVERY $@

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) \
		$(recovery_ramdisk) \
		$(recovery_kernel)
	@echo -e ${CL_CYN}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made recovery image: $@"${CL_RST}

$(INSTALLED_RAMDISK_TARGET): $(MKBOOTFS) $(INTERNAL_RAMDISK_FILES) | $(MINIGZIP)
	$(call pretty,"Target mtk ram disk: $@")
#	mkdir -p $(TARGET_ROOT_OUT)/system/bin
#	cp -r $(TARGET_ROOT_OUT)/../recovery/root/sbin/* $(TARGET_ROOT_OUT)/system/bin/
#	cd $(TARGET_ROOT_OUT) && find . | cpio -o -H newc | $(MINIGZIP) > $@
	$(hide) $(MKBOOTFS) $(TARGET_ROOT_OUT) | $(MINIGZIP) > $@
	$(hide) device/mediatek/mt6592/pack.pl ROOTFS $@

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES)
	$(call pretty,"Target boot mtk image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	truncate -s $(BOARD_BOOTIMAGE_PARTITION_SIZE) $@
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}

