PKG_NAME = aMule
PKG_VERS = 2.4.0
PKG_EXT = tar.gz
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)
PKG_DOWNLOAD_METHOD = svn
#PKG_SVN_REV = 10874
PKG_SVN_REV= HEAD
PKG_DIST_NAME = trunk
PKG_DIST_SITE = https://github.com/amule-project/amule
PKG_DIST_FILE = $(PKG_NAME)-r$(PKG_SVN_REV).$(PKG_EXT)
PKG_DIR = $(PKG_NAME)-r*

DEPENDS = cross/zlib cross/wxwidgets cross/libpng cross/cryptopp cross/boost-amule cross/binutils

HOMEPAGE = http://www.amule.org
COMMENT  = The all-platform eMule-like P2P client
LICENSE  =

PRE_CONFIGURE_TARGET = myPreConfigure
GNU_CONFIGURE = 1
CONFIGURE_ARGS = --disable-monolithic --with-toolkit=base --enable-amule-daemon --enable-amulecmd --enable-webserver --with-wx-prefix=$(STAGING_INSTALL_PREFIX) --with-libpng-config=$(STAGING_INSTALL_PREFIX)/bin/libpng-config --with-crypto-prefix=$(STAGING_INSTALL_PREFIX) --with-boost=$(STAGING_INSTALL_PREFIX)/share/boost --disable-debug
POST_INSTALL_TARGET = myPostInstall

include ../../mk/spksrc.cross-cc.mk

.PHONY: myPreConfigure
myPreConfigure:
	$(RUN) ./autogen.sh

.PHONY: myPostInstall
myPostInstall: 
	ln -s amuled $(STAGING_INSTALL_PREFIX)/bin/amule-daemon
