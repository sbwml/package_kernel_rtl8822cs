include $(TOPDIR)/rules.mk

PKG_NAME:=rtl8822cs
PKG_RELEASE=1

PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=

PKG_SOURCE_URL:=https://github.com/jethome-ru/rtl88x2cs.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2025-05-15
PKG_SOURCE_VERSION:=d019d700aaceb74559be2809dd015ce7e6957fb5
PKG_MIRROR_HASH:=94db8accce4d392669e778037613e10487b852b94d7ec057bbc9cff7de073cc8

PKG_MAINTAINER:=Lenar Mahmutov <lenz1986@gmail.com>
PKG_BUILD_PARALLEL:=1

STAMP_CONFIGURED_DEPENDS := $(STAGING_DIR)/usr/include/mac80211-backport/backport/autoconf.h

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/rtl8822cs
  SUBMENU:=Wireless Drivers
  TITLE:=Realtek RTL8822CS SDIO WiFi-BT support (out-of-tree)
  DEPENDS:=+kmod-cfg80211 +@DRIVER_11N_SUPPORT +@DRIVER_11AC_SUPPORT
  FILES:=\
	$(PKG_BUILD_DIR)/rtl8822cs.ko
  AUTOLOAD:=$(call AutoProbe,rtl8822cs)
  PROVIDES:=kmod-rtl8822cs
endef

NOSTDINC_FLAGS := \
	$(KERNEL_NOSTDINC_FLAGS) \
	-I$(PKG_BUILD_DIR) \
	-I$(PKG_BUILD_DIR)/include \
	-I$(STAGING_DIR)/usr/include/mac80211-backport \
	-I$(STAGING_DIR)/usr/include/mac80211-backport/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-include backport/backport.h

NOSTDINC_FLAGS += -DCONFIG_IOCTL_CFG80211 -DRTW_USE_CFG80211_STA_EVENT -DBUILD_OPENWRT

define Build/Compile
	rm -f $(PKG_BUILD_DIR)/include/linux/wireless.h
	+$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) \
		M="$(PKG_BUILD_DIR)" \
		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
		CONFIG_RTL8822CS=m \
		USER_MODULE_NAME=rtl8822cs \
		modules
endef

$(eval $(call KernelPackage,rtl8822cs))
