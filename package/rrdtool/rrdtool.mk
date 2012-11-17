################################################################################
#
# rrdtool
#
################################################################################

RRDTOOL_VERSION = 1.2.30
RRDTOOL_SITE = http://oss.oetiker.ch/rrdtool/pub
RRDTOOL_LICENSE = GPLv2+ with FLOSS license exceptions as explained in COPYRIGHT
RRDTOOL_LICENSE_FILES = COPYING COPYRIGHT

RRDTOOL_DEPENDENCIES = host-pkgconf freetype libart libpng zlib
RRDTOOL_AUTORECONF = YES
RRDTOOL_INSTALL_STAGING = YES
RRDTOOL_CONF_ENV = rd_cv_ieee_works=yes rd_cv_null_realloc=nope \
			ac_cv_func_mmap_fixed_mapped=yes

RRDTOOL_CONF_OPT = --program-transform-name='' \
			--disable-perl \
			--disable-ruby \
			--disable-tcl \
			$(if $(BR2_TOOLCHAIN_HAS_THREADS),,--disable-pthread)

ifneq ($(BR2_PACKAGE_RRDTOOL_PYTHON),)
RRDTOOL_CONF_OPT += --enable-python
RRDTOOL_CONF_ENV += \
	am_cv_pathless_PYTHON=python \
	ac_cv_path_PYTHON=$(HOST_DIR)/usr/bin/python \
	am_cv_python_platform=linux2 \
	am_cv_python_includes=$(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_MAJOR)
RRDTOOL_DEPENDENCIES += python
else
RRDTOOL_CONF_OPT += --disable-python
endif

RRDTOOL_MAKE = $(MAKE1)

define RRDTOOL_REMOVE_EXAMPLES
	rm -rf $(TARGET_DIR)/usr/share/rrdtool/examples
endef

RRDTOOL_POST_INSTALL_TARGET_HOOKS += RRDTOOL_REMOVE_EXAMPLES

$(eval $(autotools-package))
