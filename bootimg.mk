LOCAL_PATH := $(call my-dir)

$(recovery_ramdisk): $(MKBOOTFS) \
	$(recovery_uncompressed_ramdisk)
	@echo -e ${CL_CYN}"----- Making recovery mtk ramdisk ------"${CL_RST}
	$(MINIGZIP) < $(recovery_uncompressed_ramdisk) > $@
#	$(MINIGZIP) < /home/axet/Desktop/ccc > $@
	$(hide) device/mediatek/mt6592/pack.pl $@

$(INSTALLED_RAMDISK_TARGET): $(MKBOOTFS) $(INTERNAL_RAMDISK_FILES) | $(MINIGZIP)
	$(call pretty,"Target mtk ram disk: $@")
	$(hide) $(MKBOOTFS) $(TARGET_ROOT_OUT) | $(MINIGZIP) > $@
	$(hide) device/mediatek/mt6592/pack.pl $@

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) \
		$(recovery_ramdisk) \
		$(recovery_kernel)
	@echo -e ${CL_CYN}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made recovery image: $@"${CL_RST}

