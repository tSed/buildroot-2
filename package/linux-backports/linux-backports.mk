################################################################################
#
# linux-backports
#
################################################################################

LINUX_BACKPORTS_VERSION_MAJOR = 3.15-rc1
LINUX_BACKPORTS_VERSION = $(LINUX_BACKPORTS_VERSION_MAJOR)-1
LINUX_BACKPORTS_SOURCE = backports-$(LINUX_BACKPORTS_VERSION).tar.xz
LINUX_BACKPORTS_SITE = $(BR2_KERNEL_MIRROR)/linux/kernel/projects/backports/stable/v$(LINUX_BACKPORTS_VERSION_MAJOR)
LINUX_BACKPORTS_LICENSE = GPLv2
LINUX_BACKPORTS_LICENSE_FILES = COPYING
LINUX_BACKPORTS_DEPENDENCIES = linux

LINUX_BACKPORTS_MAKE_FLAGS = \
	$(LINUX_MAKE_FLAGS) \
	KLIB_BUILD=$(LINUX_DIR) \
	KROOT=$(TARGET_DIR)

ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_USE_DEFCONFIG),y)
LINUX_BACKPORTS_SOURCE_CONFIG = $(LINUX_BACKPORTS_DIR)/defconfigs/$(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_DEFCONFIG))
else ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_USE_CUSTOM_CONFIG),y)
LINUX_BACKPORTS_SOURCE_CONFIG = $(BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_CONFIG_FILE)
endif

define LINUX_BACKPORTS_CONFIGURE_CMDS
	cp $(LINUX_BACKPORTS_SOURCE_CONFIG) \
		$(@D)/defconfigs/buildroot
	$(TARGET_MAKE_ENV) $(MAKE1) $(LINUX_BACKPORTS_MAKE_FLAGS) \
		-C $(@D) defconfig-buildroot
	rm $(@D)/defconfigs/buildroot
	yes '' | $(TARGET_MAKE_ENV) $(MAKE1) $(LINUX_BACKPORTS_MAKE_FLAGS) \
		-C $(@D) oldconfig
endef

define LINUX_BACKPORTS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(LINUX_BACKPORTS_MAKE_FLAGS) -C $(@D)
	@if grep -q "=m" $(@D)/.config; then 	\
		$(TARGET_MAKE_ENV) $(MAKE) $(LINUX_BACKPORTS_MAKE_FLAGS) \
			-C $(@D) modules ;	\
	fi
endef

define LINUX_BACKPORTS_INSTALL_TARGET_CMDS
	# Install modules and remove symbolic links pointing to build
	# directories, not relevant on the target
	$(TARGET_MAKE_ENV) $(MAKE1) $(LINUX_BACKPORTS_MAKE_FLAGS) \
		-C $(@D) install
	@if grep -q "=m" $(@D)/.config; then 	\
		$(TARGET_MAKE_ENV) $(MAKE1) $(LINUX_BACKPORTS_MAKE_FLAGS) \
		-C $(@D) modules_install; \
	fi
endef

$(eval $(generic-package))

ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS),y)
linux-backports-menuconfig linux-backports-xconfig linux-backports-gconfig linux-backports-nconfig: dirs linux-backports-configure
	$(MAKE) $(LINUX_BACKPORTS_MAKE_FLAGS) \
		-C $(LINUX_BACKPORTS_DIR) $(subst linux-backports-,,$@)
	rm -f $(LINUX_BACKPORTS_DIR)/.stamp_{built,target_installed,images_installed}

linux-backports-savedefconfig: dirs linux-backports-configure
	$(MAKE) $(LINUX_BACKPORTS_MAKE_FLAGS) \
		-C $(LINUX_BACKPORTS_DIR) $(subst linux-backports-,,$@)

ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_USE_CUSTOM_CONFIG),y)
# linux-backports does not support savedefconfig command
linux-backports-update-config: linux-backports-configure $(LINUX_BACKPORTS_DIR)/.config
	cp -f $(LINUX_BACKPORTS_DIR)/.config \
		$(BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_CONFIG_FILE)
else
linux-backports-update-config: ;
endif
endif

# Checks to give errors that the user can understand
ifeq ($(filter source,$(MAKECMDGOALS)),)

ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_USE_DEFCONFIG),y)
ifeq ($(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_DEFCONFIG)),)
$(error No linux-backports defconfig name specified, check your BR2_PACKAGE_LINUX_BACKPORTS_DEFCONFIG setting)
endif
endif

ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_USE_CUSTOM_CONFIG),y)
ifeq ($(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_CONFIG_FILE)),)
$(error No linux-backports configuration file specified, check your BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_CONFIG_FILE setting)
endif
endif

endif
