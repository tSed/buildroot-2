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

# disable the tests and the documentation
OCTOMAP_CONF_OPT += \
	-DBUILD_TESTING=OFF \
	-DDOXYGEN_EXECUTABLE=DOXYGEN_EXECUTABLE-NOTFOUND

ifeq ($(BR2_PACKAGE_OCTOMAP_INSTALL_PROGRAMS),)
define OCTOMAP_TARGET_INSTALL_REMOVE_PROGRAMS
	-rm -f $(addprefix $(TARGET_DIR)/usr/bin/,\
		graph2tree log2graph binvox2bt bt2vrml edit_octree \
		convert_octree eval_octree_accuracy compare_octrees)
endef

OCTOMAP_POST_INSTALL_TARGET_HOOKS += OCTOMAP_TARGET_INSTALL_REMOVE_PROGRAMS
endif

$(eval $(cmake-package))

#
# octomap source tree includes source code for 3 projects:
# - octomap, under the octomap subdirectory;
# - dynamic Euclidian distance, under the dynamicEDT3D subdirectory;
# - octovis, under the octovis subdirectory.
# Unfortunately, the last 2 sub-projects depend on octomap. This means that
# octomap needs to be installed prior to be able build them.
# So, add them as independent packages
#
# octovis is not added since it depends on packages not (yet) supported in
# Buildroot (qglviewer).
#

DYNAMICEDT3D_VERSION = $(OCTOMAP_VERSION)
DYNAMICEDT3D_LICENSE = $(OCTOMAP_LICENSE)
DYNAMICEDT3D_LICENSE_FILES = $(OCTOMAP_LICENSE_FILES)
DYNAMICEDT3D_SOURCE = $(OCTOMAP_SOURCE)
DYNAMICEDT3D_SITE = $(OCTOMAP_SITE)
DYNAMICEDT3D_INSTALL_STAGING = YES
DYNAMICEDT3D_SUBDIR = dynamicEDT3D
DYNAMICEDT3D_DEPENDENCIES = octomap
DYMANICEDT3D_CONF_OPT = $(OCTOMAP_CONF_OPT)

$(eval $(call inner-cmake-package,dynamicedt3d,DYNAMICEDT3D,DYNAMICEDT3D,target))
