#
# Copyright (C) 2023 muink
#
# This is free software, licensed under the Apache-2.0 license.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=go-stun
PKG_VERSION=0.1.4
PKG_RELEASE:=5

PKG_MAINTAINER:=muink <hukk1996@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ccding/go-stun.git
PKG_SOURCE_VERSION:=44e89cab780543bf92f93273eeeadb6869c485a6

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/ccding/go-stun

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A GO implementation of the STUN client
  URL:=https://github.com/ccding/go-stun
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/$(PKG_NAME)/description
  go-stun is a STUN (RFC 3489, 5389) client implementation in golang (a.k.a. UDP hole punching).
  RFC 3489: STUN - Simple Traversal of User Datagram Protocol (UDP) Through Network Address Translators (NATs)
  RFC 5389: Session Traversal Utilities for NAT (STUN)
endef

define Package/$(PKG_NAME)/conffiles
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
uci show luci | grep "name='go-stun NAT Type Test'" >/dev/null
if [ "$$?" == "1" ]; then
	section=$$(uci add luci command)
	uci -q batch <<-EOF >/dev/null
		set luci.$$section.name='go-stun NAT Type Test'
		set luci.$$section.command='go-stun -s stun.syncthing.net:3478'
		commit luci
	EOF
fi
uci show luci | grep "name='go-stun NAT Behavior Test'" >/dev/null
if [ "$$?" == "1" ]; then
	section=$$(uci add luci command)
	uci -q batch <<-EOF >/dev/null
		set luci.$$section.name='go-stun NAT Behavior Test'
		set luci.$$section.command='go-stun -b -s stun.syncthing.net:3478'
		commit luci
	EOF
fi
endef

define Package/$(PKG_NAME)/prerm
endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

$(eval $(call GoBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
