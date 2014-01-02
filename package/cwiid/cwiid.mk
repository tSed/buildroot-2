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

# cwiid provides a python module using distutils.
# Calls to the python build-system are made from a handwritten Makefile.in,
# which does not handle cross-compilation for the python module.
#
# So, always disable the python module build/install by the original
# build-system (i.e. autotools), and provide our own build and install commands
# freely inspired and adapted from the python-package infrastructure and the
# cwiid makefiles as post-build (respectively post-install) hooks.
#
CWIID_CONF_OPT += --without-python
ifeq ($(BR2_PACKAGE_CWIID_WMINPUT_PYTHON),y)
CWIID_DEPENDENCIES += $(call python-helper-dependencies,target,distutils)

# The cwiid setup.py script does not support:
#   - the --executable=... option (set by PKG_PYTHON_DISTUTILS_BUILD_OPT);
#   - the -I.. option combined with the 'build' command;
#
# So, we have to keep invoking the 'build_ext' command and get rid of
# PKG_PYTHON_DISTUTILS_BUILD_OPT.
define CWIID_PYTHON_MODULE_BUILD_CMDS
	( cd $(@D)/python ; \
		$(PKG_PYTHON_DISTUTILS_ENV) \
		$(HOST_DIR)/usr/bin/python setup.py build_ext \
		-I$(@D)/libcwiid -L$(@D)/libcwiid ; \
	)
endef

# The install target command is nothing more than the install command vampirized
# from the python-package infrastructure.
define CWIID_PYTHON_MODULE_INSTALL_TARGET_CMDS
	( cd $(@D)/python/ ; \
		$(PKG_PYTHON_DISTUTILS_ENV) \
		$(HOST_DIR)/usr/bin/python setup.py install \
		$(PKG_PYTHON_DISTUTILS_INSTALL_OPT) \
	)
endef

CWIID_POST_BUILD_HOOKS += CWIID_PYTHON_MODULE_BUILD_CMDS
CWIID_POST_INSTALL_TARGET_HOOKS += CWIID_PYTHON_MODULE_INSTALL_TARGET_CMDS

# Since python support is disabled, we have to set a couple of variable
CWIID_CONF_ENV += \
	am_cv_python_version=$(PYTHON_VERSION) \
	am_cv_python_includes=$(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_MAJOR)
endif

$(eval $(autotools-package))
