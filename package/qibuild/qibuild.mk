################################################################################
#
# qibuild
#
################################################################################

QIBUILD_VERSION = v3.2.1
QIBUILD_SITE = $(call github,aldebaran,qibuild,$(QIBUILD_VERSION))
HOST_QIBUILD_DEPENDENCIES = host-python host-cmake

define HOST_QIBUILD_INSTALL_CMDS
	$(INSTALL) -m755 -d $(HOST_DIR)/usr/share/cmake
	rsync -ar $(@D)/cmake/qibuild $(HOST_DIR)/usr/share/cmake
	$(INSTALL) -m755 -d $(STAGING_DIR)/usr/share/cmake
	ln -sfv $(HOST_DIR)/usr/share/cmake/qibuild $(STAGING_DIR)/usr/share/cmake
endef

$(eval $(host-generic-package))
