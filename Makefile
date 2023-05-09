REGGAE_PATH = /usr/local/share/reggae
USE = letsencrypt nginx
SERVICES += icinga https://github.com/mekanix/jail-icinga

.include <${REGGAE_PATH}/mk/use.mk>

BACKEND != reggae get-config BACKEND
CBSD_WORKDIR != sysrc -s cbsd -n cbsd_workdir 2>/dev/null || true

post_setup:
.for service url in ${ALL_SERVICES}
	@echo "FQDN = ${FQDN}" >>services/${service}/project.mk
	@echo "DHCP ?= ${DHCP}" >>services/${service}/project.mk
.if defined(VERSION)
	@echo "VERSION = ${VERSION}" >>services/${service}/project.mk
.endif
.if ${BACKEND} == base
	@echo "\$${base}/letsencrypt/usr/local/etc/dehydrated/certs \$${path}/etc/certs nullfs ro 0 0" >services/nginx/templates/fstab
	@echo "\$${base}/icinga/usr/local/www/icingaweb2 \$${path}/usr/local/www/icingaweb2 nullfs ro 0 0" >>services/nginx/templates/fstab
.elif ${BACKEND} == cbsd
	@echo "${CBSD_WORKDIR}/jails-data/letsencrypt-data/usr/local/etc/dehydrated/certs /etc/certs nullfs ro 0 0" >services/nginx/templates/fstab
	@echo "${CBSD_WORKDIR}/jails-data/letsencrypt-data/usr/local/www/icingaweb2 /usr/local/www/icingaweb2 nullfs ro 0 0" >>services/nginx/templates/fstab
.endif
.endfor

.include <${REGGAE_PATH}/mk/project.mk>
