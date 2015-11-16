SPK_NAME = amule
SPK_VERS = 2.3.1
SPK_REV = 1
SPK_ICON = src/amule.png
DSM_UI_DIR = app

DEPENDS = cross/busybox cross/$(SPK_NAME)
#DEPENDS += cross/openssl

MAINTAINER = SynoCommunity
DESCRIPTION = aMule is a peer-to-peer client for the eD2k network, commonly known as eDonkey network. This is the Daemon version and you can control it remotely with its web interface or dedicated application aMuleGUI.
DESCRIPTION_ITA = aMule è un client peer-to-peer per reti eD2k, comunemente conosciute come reti eDonkey. Questa è la versione demone che può essere controllata con la sua interfaccia web o con l\\\'applicazione dedicata aMuleGUI.
ADMIN_PORT = 4711
RELOAD_UI = yes
DISPLAY_NAME = aMule Daemon
CHANGELOG = 

HOMEPAGE = http://www.amule.org/
LICENSE  = GPL

WIZARDS_DIR = src/wizard/

INSTALLER_SCRIPT = src/installer.sh
SSS_SCRIPT       = src/dsm-control.sh
FWPORTS          = src/${SPK_NAME}.sc

INSTALL_PREFIX = /usr/local/$(SPK_NAME)

POST_STRIP_TARGET = amule_extra_install

BUSYBOX_CONFIG = usrmng
ENV += BUSYBOX_CONFIG="$(BUSYBOX_CONFIG)"

include ../../mk/spksrc.spk.mk

.PHONY: amule_extra_install
amule_extra_install:
#    wget -nv -P synoTMP/ http://www.emule-mods.it/download/server.met 2>/dev/null;if [ $? -eq 0 -a -f synoTMP/server.met.1 ]; then rm synoTMP/server.met;mv synoTMP/server.met.1 synoTMP/server.met;echo Updated;else echo Dowloaded;fi
	install -m 755 -d $(STAGING_DIR)/var
	install -m 644 src/server.met $(STAGING_DIR)/var/server.met
	install -m 644 src/ipfilter.zip $(STAGING_DIR)/var/ipfilter.zip
	install -m 755 -d $(STAGING_DIR)/app
	install -m 644 src/app/config $(STAGING_DIR)/app/config
	install -m 755 -d $(STAGING_DIR)/app/images
	for size in 16 24 32 48 72 ; \
	do \
	    convert $(SPK_ICON) -thumbnail $${size}x$${size} \
	            $(STAGING_DIR)/app/images/$(SPK_NAME)-$${size}.png ; \
	done

#.PHONY: transmission_extra_install
#transmission_extra_install:
#	install -m 755 -d $(STAGING_DIR)/var
#	install -m 644 src/settings.json $(STAGING_DIR)/var/settings.json
#	install -m 755 -d $(STAGING_DIR)/app
#	install -m 644 src/app/config $(STAGING_DIR)/app/config
#	install -m 755 -d $(STAGING_DIR)/app/images
#	for size in 16 24 32 48 72 ; \
#	do \
#	    convert $(SPK_ICON) -thumbnail $${size}x$${size} \
#	            $(STAGING_DIR)/app/images/$(SPK_NAME)-$${size}.png ; \
#	done
