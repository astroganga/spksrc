PKG_NAME = aMule
PKG_VERS = 2.3.1
PKG_EXT = tar.xz
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = http://sourceforge.net/projects/amule/files/$(PKG_NAME)/$(PKG_VERS)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = cross/zlib cross/wxwidgets cross/libpng cross/cryptopp cross/binutils

HOMEPAGE = http://www.amule.org
COMMENT  = The all-platform eMule-like P2P client
LICENSE  =

GNU_CONFIGURE = 1
CONFIGURE_ARGS = --disable-monolithic --with-toolkit=base --enable-amule-daemon --enable-amulecmd --enable-webserver --with-wx-prefix=$(STAGING_INSTALL_PREFIX) --with-libpng-config=$(STAGING_INSTALL_PREFIX)/bin/libpng-config --with-crypto-prefix=$(STAGING_INSTALL_PREFIX)
#CONFIGURE_ARGS = --disable-monolithic --with-toolkit=base --enable-amule-daemon --enable-amulecmd --enable-webserver --with-wx-prefix=$(STAGING_INSTALL_PREFIX) --with-libpng-config=$(STAGING_INSTALL_PREFIX)/bin/libpng-config --with-crypto-prefix=$(STAGING_INSTALL_PREFIX) --with-libupnp-prefix=$(STAGING_INSTALL_PREFIX)

POST_INSTALL_TARGET = myPostInstall

include ../../mk/spksrc.cross-cc.mk

.PHONY: myPostInstall
myPostInstall: 
	ln -s amuled $(STAGING_INSTALL_PREFIX)/bin/amule-daemon
