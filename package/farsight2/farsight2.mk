################################################################################
#
# farsight2
#
################################################################################

FARSIGHT2_VERSION = 0.0.31
FARSIGHT2_SITE = http://www.freedesktop.org/software/farstream/releases/farsight2/
FARSIGHT2_LICENSE = LGPLv2.1+
FARSIGHT2_LICENSE_FILES = COPYING
FARSIGHT2_INSTALL_STAGING = YES
FARSIGHT2_DEPENDENCIES = \
	gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad \
	libglib2 libnice \
	host-pkgconf
FARSIGHT2_CONF_OPT = \
	--disable-python \
	--disable-gupnp \
	--with-plugins=fsrtpconference,funnel,rtcpfilter,videoanyrate

$(eval $(autotools-package))
