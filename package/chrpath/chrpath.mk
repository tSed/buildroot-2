#############################################################
#
# chrpath
#
#############################################################

CHRPATH_VERSION = 0.13
CHRPATH_SITE = http://ftp.tux.org/pub/X-Windows/ftp.hungry.com/chrpath/
CHRPATH_SOURCE = chrpath-$(CHRPATH_VERSION).tar.gz

define HOST_CHRPATH_POST_BUILD_FIX_RPATH
 cp -f $(HOST_CHRPATH_BUILDDIR)/chrpath{,.orig}
 $(HOST_CHRPATH_BUILDDIR)/chrpath.orig -r '$$ORIGIN/../lib' \
  $(HOST_CHRPATH_BUILDDIR)/chrpath
endef

HOST_CHRPATH_FIX_RPATH = NO
HOST_CHRPATH_POST_BUILD_HOOKS += HOST_CHRPATH_POST_BUILD_FIX_RPATH

$(eval $(call AUTOTARGETS,host))

CHRPATH =$(HOST_DIR)/usr/bin/chrpath
