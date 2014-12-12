    # repo init -u git://github.com/CyanogenMod/android.git -b cm-11.0
    
    # repo sync
    
    # source build/envsetup.sh
    
    # lunch cm_mtk6592-eng

# recoveries
. build/tools/device/makerecoveries.sh cm_mt6592-eng

mka bootimage

# full build
brunch cm_mtk6592-eng
