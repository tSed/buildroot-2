################################################################################
#
# cwiid
#
################################################################################

CWIID_VERSION = c6583fd
#CWIID_VERSION = 0.6.00
#CWIID_SOURCE = cwiid-$(CWIID_VERSION).tgz
CWIID_SITE = $(call github,tsed,cwiid,$(CWIID_VERSION))
#CWIID_SITE = http://abstrakraft.org/cwiid/downloads
CWIID_LICENSE = GPLv2+
CWIID_LICENSE_FILES = COPYING

CWIID_AUTORECONF = YES
CWIID_INSTALL_STAGING = YES

CWIID_DEPENDENCIES = host-pkgconf host-bison host-flex bluez_utils

# Disable ldconfig
# Disable python support. This disables the 2 following things:
#   - wminput Python plugin support
#   - cwiid Python module
CWIID_CONF_OPT = --disable-ldconfig --without-python

ifeq ($(BR2_PACKAGE_CWIID_WMGUI),y)
CWIID_DEPENDENCIES += libgtk2 libglib2
CWIID_CONF_OPT += --enable-wmgui
else
CWIID_CONF_OPT += --disable-wmgui
endif

$(eval $(autotools-package))
