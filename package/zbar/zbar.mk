################################################################################
#
# zbar
#
################################################################################

ZBAR_VERSION = 0.10
ZBAR_SOURCE = zbar-$(ZBAR_VERSION).tar.bz2
ZBAR_SITE = http://sourceforge.net/projects/zbar/files/zbar/$(ZBAR_VERSION)
ZBAR_LICENSE = LGPLv2.1+
ZBAR_LICENSE_FILES = LICENSE
ZBAR_INSTALL_STAGING = YES
ZBAR_AUTORECONF = YES

ZBAR_DEPENDENCIES =
ZBAR_CONF_OPT = \
  --without-x       \
  --without-xshm    \
  --without-xv      \
  --without-npapi   \
  --without-gtk     \
  --without-python  \
  --without-qt      \
  $(if $(BR2_TOOLCHAIN_HAS_THREADS),--enable-pthread,--disable-pthread) \
  --disable-video   \
  --disable-assert

define ZBAR_FIX_CONFIGURE_AC
	$(SED) '/AM_INIT_AUTOMAKE/s:-Werror ::' $(@D)/configure.ac
endef

ZBAR_PRE_CONFIGURE_HOOKS += ZBAR_FIX_CONFIGURE_AC

ifeq ($(BR2_PACKAGE_IMAGEMAGICK),y)
ZBAR_DEPENDENCIES += imagemagick
ZBAR_CONF_OPT += --with-imagemagick
else
ZBAR_CONF_OPT += --without-imagemagick
endif

ifeq ($(BR2_PACKAGE_JPEG),y)
ZBAR_DEPENDENCIES += jpeg
ZBAR_CONF_OPT += --with-jpeg
else
ZBAR_CONF_OPT += --without-jpeg
endif

$(eval $(autotools-package))
