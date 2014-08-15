################################################################################
#
# cdrkit
#
################################################################################

CDRKIT_VERSION = 1.1.11
CDRKIT_SITE = http://www.cdrkit.org/releases
CDRKIT_DEPENDENCIES = libcap bzip2 zlib
CDRKIT_LICENSE = GPLv2
CDRKIT_LICENSE_FILES = COPYING

ifeq ($(BR2_ENDIAN),"BIG")
CMAKE_ENDIAN_OPT=-DBITFIELDS_HTOL=1
else
CMAKE_ENDIAN_OPT=-DBITFIELDS_HTOL=0
endif

CDRKIT_CONF_OPT += $(CMAKE_ENDIAN_OPT)

$(eval $(cmake-package))
$(eval $(host-cmake-package))
