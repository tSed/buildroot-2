################################################################################
#
# telepathy-farsight
#
################################################################################

TELEPATHY_FARSIGHT_VERSION = 0.0.19
TELEPATHY_FARSIGHT_SITE = http://telepathy.freedesktop.org/releases/telepathy-farsight
TELEPATHY_FARSIGHT_LICENSE = LGPLv2.1
TELEPATHY_FARSIGHT_LICENSE_FILES = COPYING
TELEPATHY_FARSIGHT_INSTALL_STAGING = YES
TELEPATHY_FARSIGHT_DEPENDENCIES = host-pkgconf \
	dbus dbus-glib \
	libglib2 \
	telepathy-glib \
	farsight2
TELEPATHY_FARSIGHT_CONF_OPT = \
	--disable-python

$(eval $(autotools-package))
