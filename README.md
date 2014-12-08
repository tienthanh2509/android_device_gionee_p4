./build/tools/device/mkvendor.sh mediatek mtk6592 /media/sf_Desktop/boot.img

lunch cm_mtk6592-eng

. build/tools/device/makerecoveries.sh cm_mtk6592-eng

rm -rf ~/source/cm-11.0/out/target/product/mt6592/{ram*.img,boot.img,root} && mka bootimage && cp ~/source/cm-11.0/out/target/product/mt6592/boot.img /media/sf_Desktop/ && sync

brunch cm_mtk6592-eng
