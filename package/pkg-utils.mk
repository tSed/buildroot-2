############################################################################
#
# This file contains various utility functions used by the package
# infrastructure, or by the packages themselves.
#
############################################################################

# UPPERCASE Macro -- transform its argument to uppercase and replace dots and
# hyphens to underscores

# Heavily inspired by the up macro from gmsl (http://gmsl.sf.net)
# This is approx 5 times faster than forking a shell and tr, and
# as this macro is used a lot it matters
# This works by creating translation character pairs (E.G. a:A b:B)
# and then looping though all of them running $(subst from,to,text)
[FROM] := a b c d e f g h i j k l m n o p q r s t u v w x y z . -
[TO]   := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z _ _

UPPERCASE = $(strip $(eval __tmp := $1) \
	$(foreach c, $(join $(addsuffix :,$([FROM])),$([TO])), \
		$(eval __tmp :=	\
		$(subst $(word 1,$(subst :, ,$c)),$(word 2,$(subst :, ,$c)),\
	$(__tmp)))) \
	$(__tmp))

#
# Manipulation of .config files based on the Kconfig
# infrastructure. Used by the Busybox package, the Linux kernel
# package, and more.
#

define KCONFIG_ENABLE_OPT
	$(SED) "/\\<$(1)\\>/d" $(2)
	echo "$(1)=y" >> $(2)
endef

define KCONFIG_SET_OPT
	$(SED) "/\\<$(1)\\>/d" $(3)
	echo "$(1)=$(2)" >> $(3)
endef

define KCONFIG_DISABLE_OPT
	$(SED) "/\\<$(1)\\>/d" $(2)
	echo "# $(1) is not set" >> $(2)
endef

# Helper functions to determine the name of a package and its
# directory from its makefile directory, using the $(MAKEFILE_LIST)
# variable provided by make. This is used by the *TARGETS macros to
# automagically find where the package is located. Note that the
# pkgdir macro is carefully written to handle the case of the Linux
# package, for which the package directory is an empty string.
define pkgdir
	$(dir $(lastword $(MAKEFILE_LIST)))
endef

define pkgname
	$(lastword $(subst /, ,$(call pkgdir)))
endef

define pkgparentdir
	$(patsubst %$(call pkgname)/,%,$(call pkgdir))
endef

# Define extractors for different archive suffixes
INFLATE.bz2  = $(BZCAT)
INFLATE.gz   = $(ZCAT)
INFLATE.tbz  = $(BZCAT)
INFLATE.tbz2 = $(BZCAT)
INFLATE.tgz  = $(ZCAT)
INFLATE.xz   = $(XZCAT)
INFLATE.tar  = cat

# MESSAGE Macro -- display a message in bold type
MESSAGE     = echo "$(TERM_BOLD)>>> $($(PKG)_NAME) $($(PKG)_VERSION) $(1)$(TERM_RESET)"
TERM_BOLD  := $(shell tput smso)
TERM_RESET := $(shell tput rmso)

# Utility functions for 'find'
# findfileclauses(filelist) => -name 'X' -o -name 'Y'
findfileclauses = $(call notfirstword,$(patsubst %,-o -name '%',$(1)))
# finddirclauses(base, dirlist) => -path 'base/dirX' -o -path 'base/dirY'
finddirclauses  = $(call notfirstword,$(patsubst %,-o -path '$(1)/%',$(2)))

# Miscellaneous utility functions
# notfirstword(wordlist): returns all but the first word in wordlist
notfirstword = $(wordlist 2,$(words $(1)),$(1))

# Needed for the foreach loops to loop over the list of hooks, so that
# each hook call is properly separated by a newline.
define sep


endef

#
# RPATH utility
#

# ADJUST_RPATH_DIR_FILTER contains path patterns, for which any matching
# location should be skip from search.
# This is useful to prevent changing rpath from any 3rd party software,
# e.g. an external cross-toolchain.
ADJUST_RPATH_DIR_FILTER  =
ifneq ($(TOOLCHAIN_EXTERNAL_SUBDIR),)
ADJUST_RPATH_DIR_FILTER += $(TOOLCHAIN_EXTERNAL_SUBDIR)
endif

# ADJUST_RPATH -- Fix RPATH in binary files
#
#  argument 1 root location of the search
#             default: $(HOST_DIR)
#  argument 2 wrong rpath prefix to match allowing the rpath substitution
#             default: $(HOST_RPATH_PREFIX_DEFAULT)
#
#  Note: Any path matching $(ADJUST_RPATH_DIR_FILTER) is skip from search.
ADJUST_RPATH_FIND_DIR_FILTER = \
	$(foreach dir,$(ADJUST_RPATH_DIR_FILTER), -o -path $(dir))
define ADJUST_RPATH
	@$(call MESSAGE,"Adjusting rpath")
	test -x $(CHRPATH)
	test x$(1) != x && \
		export _search_root=$(1) || \
		export _search_root=$(HOST_DIR) ; \
	test x$(2) != x && \
		export _rpath_prefix=$(2) || \
		export _rpath_prefix=$(HOST_RPATH_PREFIX_DEFAULT) ; \
	find $${_search_root} \
		-type f \
		-a '!' '(' -path '*/$(STAGING_SUBDIR)/*' \
			$(foreach dir,$(ADJUST_RPATH_DIR_FILTER), -o -path $(dir)) ')' \
		-exec sh -c \
			'file "{}" | \
			grep -qE ": ELF.*?, dynamically linked" && \
			readelf -d "{}" | \
			grep -qE "rpath.*?$${_rpath_prefix}ORIGIN" && \
			$(CHRPATH) -r "\$$ORIGIN/../lib" "{}"' ';'
endef
