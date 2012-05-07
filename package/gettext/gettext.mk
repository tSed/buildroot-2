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
	--disable-openmp

$(eval $(call AUTOTARGETS))
