################################################################################
#
# libnice
#
################################################################################

LIBNICE_VERSION = 0.1.4
LIBNICE_SITE = http://nice.freedesktop.org/releases/
LIBNICE_LICENSE = LGPLv2.1+, Mozilla Public License v1.1
LIBNICE_LICENSE_FILES = COPYING.LGPL COPYING.MPL
LIBNICE_INSTALL_STAGING = YES
LIBNICE_DEPENDENCIES = libglib2 host-pkgconf
LIBNICE_CONF_OPT = \
	--without-gstreamer \
	--without-gstreamer-0.10 \
	--disable-gupnp

$(eval $(autotools-package))
