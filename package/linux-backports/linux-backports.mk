################################################################################
#
# linux-backports
#
################################################################################

LINUX_BACKPORTS_VERSION = $(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_VERSION))
LINUX_BACKPORTS_LICENSE = GPLv2
LINUX_BACKPORTS_LICENSE_FILES = COPYING

# Compute LINUX_BACKPORTS_SOURCE and LINUX_BACKPORTS_SITE from the configuration
ifeq ($(LINUX_BACKPORTS_VERSION),custom)
LINUX_BACKPORTS_TARBALL = $(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_TARBALL_LOCATION))
LINUX_BACKPORTS_SITE = $(patsubst %/,%,$(dir $(LINUX_BACKPORTS_TARBALL)))
LINUX_BACKPORTS_SOURCE = $(notdir $(LINUX_BACKPORTS_TARBALL))
else ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_GIT),y)
LINUX_BACKPORTS_SITE = $(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_REPO_URL))
LINUX_BACKPORTS_SITE_METHOD = git
else
ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_3_7_9)$(BR2_PACKAGE_LINUX_BACKPORTS_3_8_3),y)
LINUX_BACKPORTS_SOURCE_NAME = compat-drivers
else
LINUX_BACKPORTS_SOURCE_NAME = backports
endif
LINUX_BACKPORTS_SOURCE = $(LINUX_BACKPORTS_SOURCE_NAME)-$(LINUX_BACKPORTS_VERSION).tar.xz
LINUX_BACKPORTS_SITE = $(BR2_KERNEL_MIRROR)/linux/kernel/projects/backports/stable/v$(firstword $(subst -, ,$(LINUX_BACKPORTS_VERSION)))
endif

LINUX_BACKPORTS_PATCHES = $(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_PATCH))

LINUX_BACKPORTS_DEPENDENCIES = linux

define LINUX_BACKPORTS_DOWNLOAD_PATCHES
	$(if $(LINUX_BACKPORTS_PATCHES),
		@$(call MESSAGE,"Download additional patches"))
	$(foreach patch,$(filter ftp://% http://%,$(LINUX_BACKPORTS_PATCHES)),\
		$(call DOWNLOAD,$(patch))$(sep))
endef

LINUX_BACKPORTS_POST_DOWNLOAD_HOOKS += LINUX_BACKPORTS_DOWNLOAD_PATCHES

define LINUX_BACKPORTS_APPLY_PATCHES
	for p in $(LINUX_BACKPORTS_PATCHES) ; do \
		if echo $$p | grep -q -E "^ftp://|^http://" ; then \
			support/scripts/apply-patches.sh $(@D) $(DL_DIR) `basename $$p` ; \
		elif test -d $$p ; then \
			support/scripts/apply-patches.sh $(@D) $$p linux-backports*.patch ; \
		else \
			support/scripts/apply-patches.sh $(@D) `dirname $$p` `basename $$p` ; \
		fi \
	done
endef

LINUX_BACKPORTS_POST_PATCH_HOOKS += LINUX_BACKPORTS_APPLY_PATCHES

LINUX_BACKPORTS_MAKE_FLAGS = \
	$(LINUX_MAKE_FLAGS) \
	KLIB_BUILD=$(LINUX_DIR) \
	KLIB=$(TARGET_DIR)

ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_DONT_USE_DOT_CONFIG),y)

ifneq ($(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_CONFIG_MK_FILE)),)
define LINUX_BACKPORTS_CONFIGURE_CMDS
	cp $(BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_CONFIG_MK_FILE) \
		$(@D)/config.mk
endef
endif

else

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

endif

# Compilation. We make sure the kernel gets rebuilt when the
# configuration has changed.
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
ifneq ($(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_CONFIG_MK_FILE)),)
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
endif

# Checks to give errors that the user can understand
ifeq ($(filter source,$(MAKECMDGOALS)),)

ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_USE_DEFCONFIG),y)
ifeq ($(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_DEFCONFIG)),)
$(error No kernel defconfig name specified, check your BR2_PACKAGE_LINUX_BACKPORTS_DEFCONFIG setting)
endif
endif

ifeq ($(BR2_PACKAGE_LINUX_BACKPORTS_USE_CUSTOM_CONFIG),y)
ifeq ($(call qstrip,$(BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_CONFIG_FILE)),)
$(error No kernel configuration file specified, check your BR2_PACKAGE_LINUX_BACKPORTS_CUSTOM_CONFIG_FILE setting)
endif
endif

endif
