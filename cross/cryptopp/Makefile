PKG_NAME = cryptopp
PKG_VERS = 562
PKG_EXT = zip
PKG_DIST_NAME = $(PKG_NAME)$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = http://www.cryptopp.com
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = 

HOMEPAGE = http://www.cryptopp.com/
COMMENT  = Crypto++ Library is a free C++ class library of cryptographic schemes
LICENSE  = http://cryptopp.com/License.txt

EXTRACT_PATH = $(WORK_DIR)/$(PKG_DIR)
CONFIGURE_TARGET = nop
COMPILE_TARGET = myCompile
INSTALL_TARGET = myInstall

include ../../mk/spksrc.cross-cc.mk

.PHONY: myCompile
myCompile:
	$(RUN) $(MAKE) all static dynamic CXXFLAGS+=-fPIC UNAME=Linux ISX86=0

.PHONY: myInstall
myInstall:
	$(RUN) $(MAKE) install PREFIX=$(STAGING_INSTALL_PREFIX)

