################################################################################
#
# nginx
#
################################################################################

NGINX_VERSION = 1.5.13
NGINX_SITE = http://nginx.org/download
NGINX_LICENSE = BSD-2c
NGINX_LICENSE_FILES = LICENSE

NGINX_CONF_OPT = \
	--crossbuild=Linux::$(BR2_ARCH) \
	--with-cc=$(TARGET_CC) \
	--with-cpp=$(TARGET_CC) \
	--with-cc-opt="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include" \
	--with-ld-opt="$(TARGET_LDFLAGS) -L$(STAGING_DIR)/usr/lib"

define LIBFOO_USERS
	http -1 http -1 * - - - nginx user
endef

NGINX_CONF_OPT += \
	--prefix=/etc/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--sbin-path=/usr/bin/nginx \
	--pid-path=/run/nginx.pid \
	--lock-path=/run/lock/nginx.lock \
	--user=http \
	--group=http \
	--error-log-path=stderr \
	--http-log-path=/var/log/nginx/access.log \
	--http-client-body-temp-path=/var/lib/nginx/client-body \
	--http-proxy-temp-path=/var/lib/nginx/proxy \
	--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
	--http-scgi-temp-path=/var/lib/nginx/scgi \
	--http-uwsgi-temp-path=/var/lib/nginx/uwsgi

NGINX_CONF_OPT += \
	$(if $(BR2_PACKAGE_NGINX_FILE_AIO),--with-file-aio) \
	$(if $(BR2_INET_IPV6),--with-ipv6)

ifeq ($(BR2_PACKAGE_PCRE),y)
NGINX_DEPENDENCIES += pcre
NGINX_CONF_OPT += --with-pcre
else
NGINX_CONF_OPT += --without-pcre
endif

# modules disabled or not activated because of missing dependencies:
# - google_perftools  (googleperftools)
# - http_geoip_module (geoip)
# - http_perl_module  (host-perl)
# - pcre-jit          (want to rebuild pcre)

# misc. modules
NGINX_CONF_OPT += \
	$(if $(BR2_PACKAGE_NGINX_rtsig_module),--with-rtsig_module) \
	$(if $(BR2_PACKAGE_NGINX_select_module),--with-select_module,--without-select_module) \
	$(if $(BR2_PACKAGE_NGINX_poll_module),--with-poll_module,--without-poll_module)

ifneq ($(BR2_PACKAGE_NGINX_add_modules),)
NGINX_CONF_OPT += \
	$(addprefix --add-module=,$(call qstrip,$(BR2_PACKAGE_NGINX_add_modules)))
endif

# http server modules
ifeq ($(BR2_PACKAGE_NGINX_HTTP),y)
ifeq ($BR2_PACKAGE_NGINX_http_cache),y)
NGINX_DEPENDENCIES += openssl
else
NGINX_CONF_OPT += --without-http-cache
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
NGINX_DEPENDENCIES += openssl
NGINX_CONF_OPT += --with-http_ssl_module
endif

ifeq ($(BR2_PACKAGE_NGINX_http_xslt_module),y)
NGINX_DEPENDENCIES += libxml2 libxslt
NGINX_CONF_OPT += --with-http_xslt_module
endif

ifeq ($(BR2_PACKAGE_NGINX_http_image_filter_module),y)
NGINX_DEPENDENCIES += gd jpeg libpng
NGINX_CONF_OPT += --with-http_image_filter_module
endif

ifeq ($(BR2_PACKAGE_NGINX_http_gunzip_module),y)
NGINX_DEPENDENCIES += zlib
NGINX_CONF_OPT += --with-http_gunzip_module
endif

ifeq ($(BR2_PACKAGE_NGINX_http_gzip_static_module),y)
NGINX_DEPENDENCIES += zlib
NGINX_CONF_OPT += --with-http_gzip_static_module
endif

ifeq ($(BR2_PACKAGE_NGINX_http_secure_link_module),y)
NGINX_DEPENDENCIES += openssl
NGINX_CONF_OPT += --with-http_secure_link_module
endif

ifeq ($(BR2_PACKAGE_NGINX_http_gzip_module),y)
NGINX_DEPENDENCIES += zlib
else
NGINX_CONF_OPT += --without-http_gzip_module
endif

ifeq ($(BR2_PACKAGE_NGINX_http_rewrite_module),y)
NGINX_DEPENDENCIES += pcre
else
NGINX_CONF_OPT += --without-http_rewrite_module
endif

NGINX_CONF_OPT += \
	$(if $(BR2_PACKAGE_NGINX_http_spdy_module),--with-http_spdy_module) \
	$(if $(BR2_PACKAGE_NGINX_http_realip_module),--with-http_realip_module) \
	$(if $(BR2_PACKAGE_NGINX_http_addition_module),--with-http_addition_module) \
	$(if $(BR2_PACKAGE_NGINX_http_sub_module),--with-http_sub_module) \
	$(if $(BR2_PACKAGE_NGINX_http_dav_module),--with-http_dav_module) \
	$(if $(BR2_PACKAGE_NGINX_http_flv_module),--with-http_flv_module) \
	$(if $(BR2_PACKAGE_NGINX_http_mp4_module),--with-http_mp4_module) \
	$(if $(BR2_PACKAGE_NGINX_http_auth_request_module),--with-http_auth_request_module) \
	$(if $(BR2_PACKAGE_NGINX_http_random_index_module),--with-http_random_index_module) \
	$(if $(BR2_PACKAGE_NGINX_http_degradation_module),--with-http_degradation_module) \
	$(if $(BR2_PACKAGE_NGINX_http_stub_status_module),--with-http_stub_status_module) \
	$(if $(BR2_PACKAGE_NGINX_http_charset_module),,--without-http_charset_module) \
	$(if $(BR2_PACKAGE_NGINX_http_ssi_module),,--without-http_ssi_module) \
	$(if $(BR2_PACKAGE_NGINX_http_userid_module),,--without-http_userid_module) \
	$(if $(BR2_PACKAGE_NGINX_http_access_module),,--without-http_access_module) \
	$(if $(BR2_PACKAGE_NGINX_http_auth_basic_module),,--without-http_auth_basic_module) \
	$(if $(BR2_PACKAGE_NGINX_http_autoindex_module),,--without-http_autoindex_module) \
	$(if $(BR2_PACKAGE_NGINX_http_geo_module),,--without-http_geo_module) \
	$(if $(BR2_PACKAGE_NGINX_http_map_module),,--without-http_map_module) \
	$(if $(BR2_PACKAGE_NGINX_http_split_clients_module),,--without-http_split_clients_module) \
	$(if $(BR2_PACKAGE_NGINX_http_referer_module),,--without-http_referer_module) \
	$(if $(BR2_PACKAGE_NGINX_http_proxy_module),,--without-http_proxy_module) \
	$(if $(BR2_PACKAGE_NGINX_http_fastcgi_module),,--without-http_fastcgi_module) \
	$(if $(BR2_PACKAGE_NGINX_http_uwsgi_module),,--without-http_uwsgi_module) \
	$(if $(BR2_PACKAGE_NGINX_http_scgi_module),,--without-http_scgi_module) \
	$(if $(BR2_PACKAGE_NGINX_http_memcached_module),,--without-http_memcached_module) \
	$(if $(BR2_PACKAGE_NGINX_http_limit_conn_module),,--without-http_limit_conn_module) \
	$(if $(BR2_PACKAGE_NGINX_http_limit_req_module),,--without-http_limit_req_module) \
	$(if $(BR2_PACKAGE_NGINX_http_empty_gif_module),,--without-http_empty_gif_module) \
	$(if $(BR2_PACKAGE_NGINX_http_browser_module),,--without-http_browser_module) \
	$(if $(BR2_PACKAGE_NGINX_http_upstream_ip_hash_module),,--without-http_upstream_ip_hash_module) \
	$(if $(BR2_PACKAGE_NGINX_http_upstream_least_conn_module),,--without-http_upstream_least_conn_module) \
	$(if $(BR2_PACKAGE_NGINX_http_upstream_keepalive_module),,--without-http_upstream_keepalive_module)

else # !BR2_PACKAGE_NGINX_HTTP
NGINX_CONF_OPT += --without-http
endif # BR2_PACKAGE_NGINX_HTTP

# mail modules
ifeq ($BR2_PACKAGE_NGINX_MAIL),y)

ifeq ($(BR2_PACKAGE_OPENSSL),y)
NGINX_DEPENDENCIES += openssl
NGINX_CONF_OPT += --with-mail_ssl_module
endif

NGINX_CONF_OPT += \
	$(if $(BR2_PACKAGE_NGINX_mail_pop3_module),,--without-mail_pop3_module) \
	$(if $(BR2_PACKAGE_NGINX_mail_imap_module),,--without-mail_imap_module) \
	$(if $(BR2_PACKAGE_NGINX_mail_smtp_module),,--without-mail_smtp_module)

endif # BR2_PACKAGE_NGINX_MAIL
define NGINX_DISABLE_WERROR
	$(SED) 's/-Werror//g' -i $(@D)/auto/cc/*
endef

NGINX_PRE_CONFIGURE_HOOKS += NGINX_DISABLE_WERROR

define NGINX_CONFIGURE_CMDS
	cd $(@D) ; ./configure $(NGINX_CONF_OPT)
endef

define NGINX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define NGINX_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
	-$(RM) $(TARGET_DIR)/usr/bin/nginx.old
	$(INSTALL) -D -m 0664 package/nginx/nginx.logrotate \
		$(TARGET_DIR)/etc/logrotate.d/nginx
endef

define NGINX_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 package/nginx/nginx.service \
		$(TARGET_DIR)/usr/lib/systemd/system/nginx.service
endef

define NGINX_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/nginx/S50nginx \
		$(TARGET_DIR)/etc/init.d/S50nginx
endef

$(eval $(generic-package))
