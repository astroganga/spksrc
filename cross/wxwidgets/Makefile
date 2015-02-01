PKG_NAME = wxWidgets
PKG_VERS = 2.8.12
PKG_EXT = tar.gz
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = http://sourceforge.net/projects/wxwindows/files/$(PKG_VERS)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = cross/zlib

HOMEPAGE = http://www.wxwidgets.org/
COMMENT  = Cross-Platform GUI Library - base classes
LICENSE  = wxWindows Library Licence (LGPL derived)

GNU_CONFIGURE = 1
CONFIGURE_ARGS = --disable-gui --enable-unicode --without-subdirs --without-expat

include ../../mk/spksrc.cross-cc.mk



