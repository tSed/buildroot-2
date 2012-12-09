################################################################################
#
# canfestival
#
################################################################################

# Revision 789:
CANFESTIVAL_VERSION = a82d867e7850
CANFESTIVAL_SOURCE = $(CANFESTIVAL_VERSION).tar.bz2
CANFESTIVAL_SITE = http://dev.automforge.net/CanFestival-3/archive
# Runtime code is licensed LGPLv2, whereas accompanying developer tools and few
# drivers (virtual_kernel, lincan and copcican_linux) are licensed GPLv2.
CANFESTIVAL_LICENSE = LGPLv2.1, GPLv2
CANFESTIVAL_LICENSE_FILES = COPYING, LICENCE
CANFESTIVAL_INSTALL_STAGING = YES
CANFESTIVAL_TO_BE_INSTALLED = src drivers \
	$(if $(BR2_PACKAGE_CANFESTIVAL_INSTALL_EXAMPLES),examples)

define CANFESTIVAL_CONFIGURE_CMDS
	cd $(@D) && \
		$(TARGET_CONFIGURE_OPTS) ./configure \
		--binutils=$(TARGET_CROSS) --cc="$(TARGET_CC)" \
		--cxx="$(TARGET_CC)" --ld="$(TARGET_CC)" \
		--can=$(BR2_PACKAGE_CANFESTIVAL_DRIVER) \
		--MAX_CAN_BUS_ID=$(BR2_PACKAGE_CANFESTIVAL_NBMMAXCAN)
endef

define CANFESTIVAL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) all
endef

define CANFESTIVAL_INSTALL_TARGET_CMDS
	for d in $(CANFESTIVAL_TO_BE_INSTALLED) ; do \
		$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/$$d install DESTDIR=$(TARGET_DIR) ; \
	done
endef

define CANFESTIVAL_INSTALL_STAGING_CMDS
	for d in $(CANFESTIVAL_TO_BE_INSTALLED) ; do \
		$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/$$d install DESTDIR=$(STAGING_DIR) ; \
	done
endef

$(eval $(generic-package))
