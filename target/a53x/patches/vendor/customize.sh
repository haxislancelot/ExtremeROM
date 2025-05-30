SKIPUNZIP=1
TARGET_FIRMWARE_PATH="$FW_DIR/$(echo -n "$TARGET_FIRMWARE" | sed 's./._.g' | rev | cut -d "_" -f2- | rev)"
A536B_VERSION="$(cat $TARGET_FIRMWARE_PATH/.extracted | cut -d'/' -f1 )"
OLD_TEE_DIR="$SRC_DIR/target/$TARGET_CODENAME/patches/vendor/old_tee"
MODEL=$(echo "$TARGET_FIRMWARE" | sed -E 's/^SM-([A-Z0-9]+)[A-Z].*/\1/')

# Prepare
[ -f "$WORK_DIR/vendor/etc/init/old_tee_support.rc" ] && rm -f "$WORK_DIR/vendor/etc/init/old_tee_support.rc" 
if ! grep -q "old_tee_support" "$WORK_DIR/configs/file_context-vendor"; then
    echo "/vendor/etc/init/old_tee_support\.rc u:object_r:vendor_configs_file:s0" >> "$WORK_DIR/configs/file_context-vendor"
fi

if ! grep -q "old_tee_support" "$WORK_DIR/configs/fs_config-vendor"; then
    echo "vendor/etc/init/old_tee_support.rc 0 0 644 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-vendor"
fi

{
  echo "on early-fs && property:ro.boot.em.model=SM-A536B && property:ro.boot.bootloader=$A536B_VERSION"
  echo "mount none /vendor/tee_eur /vendor/tee bind"
} >> "$WORK_DIR/vendor/etc/init/old_tee_support.rc"

# Sepolicy
if ! grep -q "tee_file (dir (mounton" "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"; then
    echo "(allow init_31_0 tee_file (dir (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow priv_app_31_0 tee_file (dir (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
fi

# Old fw/tee support
mapfile -t OLD_BLOBS < <(
    find "$OLD_TEE_DIR" -maxdepth 1 -type d -name "${MODEL}*" -printf '%f\n'
)

for t in "${OLD_BLOBS[@]}"; do
    VARIANT=$(echo "$t" | sed -E 's/^([A-Z0-9]{5}).*/\1/')
    SUPPORTED_VARIANTS="A536B A536E"

    if ! echo "$SUPPORTED_VARIANTS" | grep -q -w "$VARIANT"; then
        LOGW "! You can add tee blobs only from $SUPPORTED_VARIANTS. Skipping adding tee blobs for SM-$VARIANT" 
    fi

    [ -d "$WORK_DIR/vendor/old_tee_$t" ] && rm -rf "$WORK_DIR/vendor/old_tee_$t"
    cp -rfa --preserve=all "$SRC_DIR/target/$TARGET_CODENAME/patches/vendor/old_tee/$t" "$WORK_DIR/vendor/old_tee_$t"

    if ! grep -q "vendor/old_tee_$t" "$WORK_DIR/configs/file_context-vendor"; then
        {
          echo "/vendor/old_tee_$t u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-000000010081 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-000000020081 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-000000534b4d u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-000048444350 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-0000534b504d u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-0050524f4341 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-0053545354ab u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-00575644524d u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-42494f535542 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-46494e474502 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-4662436b6d52 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-474154454b45 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-4b45594d5354 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-4d5053545549 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-4d704e434954 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-4d70536b566e u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-4d7073617574 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-505256544545 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-5345435f4652 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-54412d48444d u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-54496473706c u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-544974684c6c u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-564c544b5052 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-656e676d6f64 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-657365636f6d u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-6b6e78677564 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-6d706f667376 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/00000000-0000-0000-0000-6d73745f5441 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/driver u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/driver/00000000-0000-0000-0000-494363447256 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/driver/00000000-0000-0000-0000-4d53546d7374 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/driver/00000000-0000-0000-0000-53626f786476 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/driver/00000000-0000-0000-0000-564c544b4456 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/ffffffff-0000-0000-0000-000000000030 u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/tui u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/tui/resolution_common u:object_r:tee_file:s0"
          echo "/vendor/old_tee_$t/tui/resolution_common/ID00000100 u:object_r:tee_file:s0"
        } >> "$WORK_DIR/configs/file_context-vendor"
    fi

    if [ "$VARIANT" = "A536B" ]; then
        if ! grep -q "vendor/old_tee_$t/00000000-0000-0000-0000-53454d655345" "$WORK_DIR/configs/file_context-vendor"; then
            echo "/vendor/old_tee_$t/00000000-0000-0000-0000-53454d655345 u:object_r:tee_file:s0" >> "$WORK_DIR/configs/file_context-vendor"
        fi
    elif [ "$VARIANT" = "A536E" ]; then
        if ! grep -q "vendor/old_tee_$t/00000000-0000-0000-0000-544545535355" "$WORK_DIR/configs/file_context-vendor"; then
            echo "/vendor/old_tee_$t/00000000-0000-0000-0000-544545535355 u:object_r:tee_file:s0" >> "$WORK_DIR/configs/file_context-vendor"
        fi
    fi

    if ! grep -q "vendor/old_tee_$t" "$WORK_DIR/configs/fs_config-vendor"; then
      {
        echo "vendor/old_tee_$t 0 2000 755 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-000000010081 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-000000020081 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-000000534b4d 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-000048444350 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-0000534b504d 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-0050524f4341 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-0053545354ab 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-00575644524d 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-42494f535542 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-46494e474502 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-4662436b6d52 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-474154454b45 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-4b45594d5354 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-4d5053545549 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-4d704e434954 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-4d70536b566e 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-4d7073617574 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-505256544545 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-5345435f4652 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-54412d48444d 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-54496473706c 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-544974684c6c 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-564c544b5052 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-656e676d6f64 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-657365636f6d 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-6b6e78677564 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-6d706f667376 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/00000000-0000-0000-0000-6d73745f5441 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/driver 0 2000 755 capabilities=0x0"
        echo "vendor/old_tee_$t/driver/00000000-0000-0000-0000-494363447256 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/driver/00000000-0000-0000-0000-4d53546d7374 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/driver/00000000-0000-0000-0000-53626f786476 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/driver/00000000-0000-0000-0000-564c544b4456 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/ffffffff-0000-0000-0000-000000000030 0 0 644 capabilities=0x0"
        echo "vendor/old_tee_$t/tui 0 2000 755 capabilities=0x0"
        echo "vendor/old_tee_$t/tui/resolution_common 0 2000 755 capabilities=0x0"
        echo "vendor/old_tee_$t/tui/resolution_common/ID00000100 0 0 644 capabilities=0x0"
      } >> "$WORK_DIR/configs/fs_config-vendor"
    fi

    if [ "$VARIANT" = "A536B" ]; then
        if ! grep -q "vendor/old_tee_$t/00000000-0000-0000-0000-53454d655345" "$WORK_DIR/configs/fs_config-vendor"; then
            echo "vendor/old_tee_$t/00000000-0000-0000-0000-53454d655345 0 0 644 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-vendor"
        fi
    elif [ "$VARIANT" = "A536E" ]; then
        if ! grep -q "vendor/old_tee_$t/00000000-0000-0000-0000-544545535355" "$WORK_DIR/configs/fs_config-vendor"; then
            echo "vendor/old_tee_$t/00000000-0000-0000-0000-544545535355 0 0 644 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-vendor"
        fi 
    fi

    {
      echo "on early-fs && property:ro.boot.em.model=SM-$VARIANT && property:ro.boot.bootloader=$t"
      echo "mount none /vendor/old_tee_$t /vendor/tee bind"
    } >> "$WORK_DIR/vendor/etc/init/old_tee_support.rc"
done
