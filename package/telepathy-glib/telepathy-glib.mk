################################################################################
#
# telepathy-glib
#
################################################################################

TELEPATHY_GLIB_VERSION = 0.23.0
TELEPATHY_GLIB_SITE = http://telepathy.freedesktop.org/releases/telepathy-glib
TELEPATHY_GLIB_LICENSE = LGPLv2.1+
TELEPATHY_GLIB_LICENSE_FILES = COPYING
TELEPATHY_GLIB_INSTALL_STAGING = YES
TELEPATHY_GLIB_DEPENDENCIES = host-pkgconf \
	libglib2 dbus libxslt
TELEPATHY_GLIB_CONF_OPT = \
	--disable-installed-tests \
	--disable-backtrace \
	--disable-debug-cache \
	--disable-introspection \
	--disable-vala-binding

$(eval $(autotools-package))
