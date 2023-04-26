# ----------------- BEGIN MIX-IN DEFINITIONS -----------------
# Mix-In definitions are auto-generated by mixin-update
##############################################################
# Source: device/intel/mixins/groups/boot-arch/project-celadon/product.mk
##############################################################

TARGET_UEFI_ARCH := x86_64

# Android Kernelflinger uses the OpenSSL library to support the
# bootloader policy
KERNELFLINGER_SSL_LIBRARY := boringssl


PRODUCT_COPY_FILES += $(LOCAL_PATH)/extra_files/boot-arch/set_soc_prop.sh:vendor/bin/set_soc_prop.sh
##############################################################
# Source: device/intel/mixins/groups/audio/aic/product.mk
##############################################################
PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-service \
    android.hardware.audio@2.0-impl \
    android.hardware.audio.effect@2.0-impl \
    android.hardware.broadcastradio@1.0-impl \
    android.hardware.soundtrigger@2.0-impl \

PRODUCT_COPY_FILES += \
    frameworks/av/media/libeffects/data/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(LOCAL_PATH)/audiopolicy/config/audio_policy_configuration_generic.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/primary_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/primary_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration_re.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes_re.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables_re.xml \
    frameworks/av/services/audiopolicy/config/surround_sound_configuration_5_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/surround_sound_configuration_5_0.xml \
##############################################################
# Source: device/intel/mixins/groups/device-specific/cic/product.mk
##############################################################
PRODUCT_HOST_PACKAGES += \
    docker \
    cpio \
    aic-build \

PRODUCT_PACKAGES += \
    sh_vendor \
    vintf \
    toybox_vendor \
    sdcard-fuse \

PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service \
    android.hardware.keymaster@4.0-strongbox-service \

##############################################################
# Source: device/intel/mixins/groups/graphics/aic_mdc/product.mk
##############################################################
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:system/vendor/etc/permissions/android.hardware.opengles.aep.xml \

PRODUCT_PACKAGES += \
    egl.cfg \
    lib_renderControl_enc \
    libGLESv2_enc \
    libOpenglSystemCommon \
    libGLESv1_enc \
    android.hardware.graphics.composer@2.1-impl \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.mapper@2.0-impl \
    hwcomposer.goldfish \
    hwcomposer.ranchu \
    android.hardware.drm@1.0-service \
    android.hardware.drm@1.0-impl \

ifeq ($(TARGET_USE_GRALLOC_VHAL), true)
PRODUCT_COPY_FILES += \
    $(INTEL_PATH_VENDOR_CIC_GRAPHIC)/nuc/system/vendor/bin/gralloc1_test:system/vendor/bin/gralloc1_test \
    $(INTEL_PATH_VENDOR_CIC_GRAPHIC)/nuc/system/vendor/bin/test_lxc_server:system/vendor/bin/test_lxc_server \
    $(INTEL_PATH_VENDOR_CIC_GRAPHIC)/nuc/system/vendor/bin/test_lxc_client:system/vendor/bin/test_lxc_client \
    $(INTEL_PATH_VENDOR_CIC_GRAPHIC)/nuc/system/vendor/lib/hw/gralloc.intel.so:system/vendor/lib/hw/gralloc.intel.so \
    $(INTEL_PATH_VENDOR_CIC_GRAPHIC)/nuc/system/vendor/lib64/hw/gralloc.intel.so:system/vendor/lib64/hw/gralloc.intel.so \
    $(INTEL_PATH_VENDOR_CIC_GRAPHIC)/nuc/system/vendor/lib/liblxc_util.so:system/vendor/lib/liblxc_util.so \
    $(INTEL_PATH_VENDOR_CIC_GRAPHIC)/nuc/system/vendor/lib64/liblxc_util.so:system/vendor/lib64/liblxc_util.so
endif

PRODUCT_PACKAGES += \
    libGLES_mesa \
    libdrm \
    libdrm_intel \
    libsync \
    Browser2

ifeq ($(TARGET_USE_GRALLOC_VHAL), true)
PRODUCT_PACKAGES += gralloc_imp.intel
else
PRODUCT_PACKAGES += gralloc.intel
endif

ifeq ($(TARGET_USE_HWCOMPOSER_VHAL), true)
PRODUCT_PACKAGES += hwcomposer_imp.intel
else
PRODUCT_PACKAGES += hwcomposer.intel
endif


PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.hwcomposer=intel \
    ro.hardware.gralloc=intel \
    ro.hardware.gralloc_imp=intel \
    ro.hardware.hwcomposer_imp=intel \
    ro.opengles.version=196610 \
##############################################################
# Source: device/intel/mixins/groups/usb/acc/product.mk
##############################################################
PRODUCT_COPY_FILES += frameworks/native/data/etc/android.hardware.usb.accessory.xml:vendor/etc/permissions/android.hardware.usb.accessory.xml

# usb accessory
PRODUCT_PACKAGES += \
    com.android.future.usb.accessory

##############################################################
# Source: device/intel/mixins/groups/wlan/mac80211_hwsim/product.mk
##############################################################
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service \
	wpa_supplicant \
	hostapd \

PRODUCT_COPY_FILES += \
    $(INTEL_PATH_VENDOR_CIC_HAL)/wifi/wpa_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf \
    $(INTEL_PATH_VENDOR_CIC_HAL)/wifi/WifiConfigStore.xml:data/misc/wifi/WifiConfigStore.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml
##############################################################
# Source: device/intel/mixins/groups/trusty/default/product.mk
##############################################################
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-service.software \
    android.hardware.security.keymint-service
##############################################################
# Source: device/intel/mixins/groups/bluetooth/default/product.mk
##############################################################
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_bluetooth=true
##############################################################
# Source: device/intel/mixins/groups/ipp/default/product.mk
##############################################################
PRODUCT_PACKAGES += libippcustom \
                    libippcustom_vendor
# ------------------ END MIX-IN DEFINITIONS ------------------
