################################################################################
#
# libsoundtouch
#
################################################################################

LIBSOUNDTOUCH_VERSION = 1.7.1
LIBSOUNDTOUCH_SOURCE = soundtouch-$(LIBSOUNDTOUCH_VERSION).tar.gz
LIBSOUNDTOUCH_SITE = http://www.surina.net/soundtouch
LIBSOUNDTOUCH_LICENSE = LGPLv2.1
LIBSOUNDTOUCH_LICENSE_FILES = COPYING.TXT
LIBSOUNDTOUCH_INSTALL_STAGING = YES
LIBSOUNDTOUCH_AUTORECONF = YES

LIBSOUNDTOUCH_DEPENDENCIES = pkgconf
LIBSOUNDTOUCH_CONF_OPT = \
	$(if $(BR2_PACKAGE_LIBSOUNDTOUCH_INTEGER_SAMPLES),--enable-integer-samples)

ifeq ($(BR2_X86_CPU_HAS_SSE3),y)
LIBSOUNDTOUCH_CONF_OPT += --enable-x86-optimizations=sse3
else
ifeq ($(BR2_X86_CPU_HAS_SSE2),y)
LIBSOUNDTOUCH_CONF_OPT += --enable-x86-optimizations=sse2
else
ifeq ($(BR2_X86_CPU_HAS_SSE),y)
LIBSOUNDTOUCH_CONF_OPT += --enable-x86-optimizations=sse
else
ifeq ($(BR2_X86_CPU_HAS_MMX),y)
LIBSOUNDTOUCH_CONF_OPT += --enable-x86-optimizations=mmx
else
LIBSOUNDTOUCH_CONF_OPT += --disable-x86-optimizations
endif
endif
endif
endif

$(eval $(autotools-package))
