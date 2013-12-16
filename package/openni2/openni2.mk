################################################################################
#
# openni2
#
################################################################################

# The official OpenNI2 uses a handwritten build-system,
# so use the Aldebaran fork converted to qiBuild/CMake.
OPENNI2_VERSION = c5037a90889c10bc7e6dacd8afdb74007d8a8e6e
OPENNI2_SITE = $(call github,aldebaran,openni2,$(OPENNI2_VERSION))
OPENNI2_LICENSE = Apache-2.0
OPENNI2_LICENSE_FILES = LICENSE
OPENNI2_INSTALL_STAGING = YES
OPENNI2_DEPENDENCIES = libusb jpeg udev host-qibuild

$(eval $(cmake-package))
