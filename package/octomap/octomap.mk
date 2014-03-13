################################################################################
#
# octomap
#
################################################################################

OCTOMAP_VERSION = v1.6.4
# Octomap is licensed under BSD-3c, except octovis which is under GPLv2.
# Since octovis is not built, do not mention its license in the legal infra.
OCTOMAP_LICENSE = BSD-3c
OCTOMAP_LICENSE_FILES = octomap/LICENSE.txt
OCTOMAP_SITE = $(call github,OctoMap,octomap,$(OCTOMAP_VERSION))
OCTOMAP_INSTALL_STAGING = YES
OCTOMAP_SUBDIR = octomap

# disable the documentation
OCTOMAP_CONF_OPT += \
	-DDOXYGEN_EXECUTABLE=DOXYGEN_EXECUTABLE-NOTFOUND \
	-DNO_ABSOLUTE_PATH_IN_MODULE=ON

ifeq ($(BR2_PACKAGE_OCTOMAP_INSTALL_PROGRAMS),)
define OCTOMAP_TARGET_INSTALL_REMOVE_PROGRAMS
	-rm -f $(addprefix $(TARGET_DIR)/usr/bin/,\
		graph2tree log2graph binvox2bt bt2vrml edit_octree \
		convert_octree eval_octree_accuracy compare_octrees)
endef

OCTOMAP_POST_INSTALL_TARGET_HOOKS += OCTOMAP_TARGET_INSTALL_REMOVE_PROGRAMS
endif

$(eval $(cmake-package))
