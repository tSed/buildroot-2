################################################################################
#
# canfestival
#
################################################################################

# Revision 791:
CANFESTIVAL_VERSION = 7740ac6fdedc
CANFESTIVAL_SOURCE = $(CANFESTIVAL_VERSION).tar.bz2
CANFESTIVAL_SITE = http://dev.automforge.net/CanFestival-3/archive
# Runtime code is licensed LGPLv2, whereas accompanying developer tools and few
# drivers (virtual_kernel, lincan and copcican_linux) are licensed GPLv2.
CANFESTIVAL_LICENSE = LGPLv2.1+, GPLv2 for the virtual_kernel, lincan and copcican_linux drivers
CANFESTIVAL_LICENSE_FILES = COPYING LICENCE
CANFESTIVAL_INSTALL_STAGING = YES
CANFESTIVAL_INSTALLED-y = src drivers
CANFESTIVAL_INSTALLED-$(BR2_PACKAGE_CANFESTIVAL_INSTALL_EXAMPLES) += examples

ifeq ($(BR2_PACKAGE_CANFESTIVAL_VIRTUAL_KERNEL)$(BR2_PACKAGE_CANFESTIVAL_COPCICAN_COMEDI),y)
CANFESTIVAL_DEPENDENCIES += linux
CANFESTIVAL_CONF_OPT += --kerneldir=$(LINUX_DIR)
CANFESTIVAL_MAKE_OPT += $(LINUX_MAKE_FLAGS)
endif

# canfestival uses its own hand-written build-system. Though there is configure
# script, it does not use the autotools at all.
# So, we use the generic-package infrastructure.
define CANFESTIVAL_CONFIGURE_CMDS
	cd $(@D) && \
		$(TARGET_CONFIGURE_OPTS) ./configure \
		--target=unix \
		--arch=$(BR2_ARCH) \
		--timers=unix \
		--binutils=$(TARGET_CROSS) \
		--cc="$(TARGET_CC)" \
		--cxx="$(TARGET_CC)" \
		--ld="$(TARGET_CC)" \
		--prefix=/usr \
		--can=$(BR2_PACKAGE_CANFESTIVAL_DRIVER) \
		$(CANFESTIVAL_CONF_OPT) \
		$(call qstrip,$(BR2_PACKAGE_CANFESTIVAL_ADDITIONAL_OPTIONS))
endef

define CANFESTIVAL_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(CANFESTIVAL_MAKE_OPT) all
endef

define CANFESTIVAL_INSTALL_TARGET_CMDS
	for d in $(CANFESTIVAL_INSTALLED-y) ; do \
		$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/$$d install \
			$(CANFESTIVAL_MAKE_OPT) DESTDIR=$(TARGET_DIR) || exit 1 ; \
	done
endef

define CANFESTIVAL_INSTALL_STAGING_CMDS
	for d in $(CANFESTIVAL_INSTALLED-y) ; do \
		$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/$$d install \
			$(CANFESTIVAL_MAKE_OPT) DESTDIR=$(STAGING_DIR) || exit 1 ; \
	done
endef

$(eval $(generic-package))
