#############################################################
#
# gettext
#
#############################################################
GETTEXT_VERSION = 0.16.1
GETTEXT_SITE = $(BR2_GNU_MIRROR)/gettext
GETTEXT_INSTALL_STAGING = YES

GETTEXT_CONF_OPT += \
	--disable-libasprintf \
	--disable-openmp \

define GETTEXT_REMOVE_BINARIES
	rm -f $(TARGET_DIR)/usr/bin/gettext
	rm -f $(TARGET_DIR)/usr/bin/gettext.sh
	rm -f $(TARGET_DIR)/usr/bin/gettextize
endef

ifeq ($(BR2_PACKAGE_LIBINTL),y)
	GETTEXT_POST_INSTALL_TARGET_HOOKS += GETTEXT_REMOVE_BINARIES
endif

$(eval $(call AUTOTARGETS))
