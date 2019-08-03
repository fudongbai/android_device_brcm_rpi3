# Boot animation
TARGET_BOOTANIMATION_HALF_RES := true
TARGET_SCREEN_WIDTH := 1280
TARGET_SCREEN_HEIGHT := 720

# Inherit some common LineageOS stuff.
$(call inherit-product, vendor/lineage/config/common_full_tablet_wifionly.mk)

# Inherit device configuration
$(call inherit-product, device/brcm/rpi3/rpi3.mk)

# Su
WITH_SU := true

# Vendor security patch level
PRODUCT_PROPERTY_OVERRIDES += \
    ro.lineage.build.vendor_security_patch=2018-07-05

# Device identifier. This must come after all inclusions
PRODUCT_DEVICE := rpi3
PRODUCT_NAME := lineage_rpi3
PRODUCT_BRAND := Raspberry
PRODUCT_MODEL := Raspberry Pi 3
PRODUCT_MANUFACTURER := Raspberry
PRODUCT_RELEASE_NAME := Raspberry Pi 3
