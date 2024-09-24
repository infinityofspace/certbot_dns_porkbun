VERSION       = 0.8
RELEASE       = 1

# system paths
RESULT_PATH   = target
RPMBUILD_PATH = ~/rpmbuild

all: help

help:
	@printf '\nusuage make ...\n'
	@printf '  clean        -> remove results\n'
	@printf '  package      -> package archive for deploy .tar.xz\n'
	@printf '  build-spec   -> build python3-certbot-dns-porkbun.spec\n'
	@printf '  build-srpm   -> build python3-certbot-dns-porkbun-'${VERSION}-${RELEASE}'.src.rpm\n'
	@printf '  build-rpm    -> build python3-certbot-dns-porkbun-'${VERSION}-${RELEASE}'.noarch.rpm\n'

# helper commands

clean:
	@printf '[INFO] removing '${RESULT_PATH}/'\n'
	@rm -rf python3-certbot-dns-porkbun.spec ${RESULT_PATH}/

package: ${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}.tar.xz

build-spec: python3-certbot-dns-porkbun.spec

build-srpm: ${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.src.rpm

build-rpm: ${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.noarch.rpm

# file generators

python3-certbot-dns-porkbun.spec:
	@mkdir -p ${RESULT_PATH}/
	@printf '[INFO] generating python3-certbot-dns-porkbun.spec\n' | tee -a ${RESULT_PATH}/build.log
	@printf '%%global modname certbot_dns_porkbun\n\n'                         >  python3-certbot-dns-porkbun.spec
	@printf 'Name:           python3-certbot-dns-porkbun\n'                    >> python3-certbot-dns-porkbun.spec
	@printf 'Version:        '${VERSION}'\n'                                   >> python3-certbot-dns-porkbun.spec
	@printf 'Release:        '${RELEASE}'\n'                                   >> python3-certbot-dns-porkbun.spec
	@printf 'Obsoletes:      %%{name} <= %%{version}\n'                        >> python3-certbot-dns-porkbun.spec
	@printf 'Summary:        Certbot DNS Porkbun Plugin\n\n'                   >> python3-certbot-dns-porkbun.spec
	@printf 'License:        MIT License\n'                                    >> python3-certbot-dns-porkbun.spec
	@printf 'URL:            https://github.com/infinityofspace/certbot_dns_porkbun/\n' >> python3-certbot-dns-porkbun.spec
	@printf 'Source0:        %%{name}-%%{version}.tar.xz\n\n'                  >> python3-certbot-dns-porkbun.spec
	@printf 'Requires:       python3-dns >= 2.0.0, python3-dns < 3.0\n'        >> python3-certbot-dns-porkbun.spec
	@printf 'Requires:       python3-pkb-client >= 1.1, python3-pkb-client < 2.0\n\n' >> python3-certbot-dns-porkbun.spec
	@printf 'BuildArch:      noarch\n'                                         >> python3-certbot-dns-porkbun.spec
	@printf 'BuildRequires:  python3-setuptools\n'                             >> python3-certbot-dns-porkbun.spec
	@printf 'BuildRequires:  python3-rpm-macros\n'                             >> python3-certbot-dns-porkbun.spec
	@printf 'BuildRequires:  python3-py\n\n'                                   >> python3-certbot-dns-porkbun.spec
	@printf '%%?python_enable_dependency_generator\n\n'                        >> python3-certbot-dns-porkbun.spec
	@printf '%%description\n'                                                  >> python3-certbot-dns-porkbun.spec
	@printf 'Plugin for certbot to obtain certificates using a DNS TXT record for Porkbun domains\n\n' >> python3-certbot-dns-porkbun.spec
	@printf '%%prep\n'                                                         >> python3-certbot-dns-porkbun.spec
	@printf '%%autosetup -n %%{modname}_v%%{version}\n\n'                      >> python3-certbot-dns-porkbun.spec
	@printf '%%build\n'                                                        >> python3-certbot-dns-porkbun.spec
	@printf '%%py3_build\n\n'                                                  >> python3-certbot-dns-porkbun.spec
	@printf '%%install\n'                                                      >> python3-certbot-dns-porkbun.spec
	@printf '%%py3_install\n\n'                                                >> python3-certbot-dns-porkbun.spec
	@printf '%%files\n'                                                        >> python3-certbot-dns-porkbun.spec
	@printf '%%doc Readme.md\n'                                                >> python3-certbot-dns-porkbun.spec
	@printf '%%license License\n'                                              >> python3-certbot-dns-porkbun.spec
	@printf '%%{python3_sitelib}/%%{modname}/\n'                               >> python3-certbot-dns-porkbun.spec
	@printf '%%{python3_sitelib}/%%{modname}-%%{version}*\n\n'                 >> python3-certbot-dns-porkbun.spec
	@printf '%%changelog\n'                                                    >> python3-certbot-dns-porkbun.spec
	@printf '...\n'                                                            >> python3-certbot-dns-porkbun.spec
	@printf '\n'                                                               >> python3-certbot-dns-porkbun.spec

${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}.tar.xz:
	@mkdir -p ${RESULT_PATH}/
	@printf '[INFO] packing python3-certbot-dns-porkbun-'${VERSION}'.tar.xz\n' | tee -a ${RESULT_PATH}/build.log
	@mkdir -p ${RESULT_PATH}/certbot_dns_porkbun_v${VERSION}
	@cp -r certbot_dns_porkbun requirements.txt setup.py License Readme.md \
		${RESULT_PATH}/certbot_dns_porkbun_v${VERSION}/
	@cd ${RESULT_PATH}; tar -I "pxz -9" -cf python3-certbot-dns-porkbun-${VERSION}.tar.xz certbot_dns_porkbun_v${VERSION}

${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.src.rpm: ${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}.tar.xz python3-certbot-dns-porkbun.spec
	@printf '[INFO] building python3-certbot-dns-porkbun-'${VERSION}-${RELEASE}'.src.rpm\n' | tee -a ${RESULT_PATH}/build.log
	@mkdir -p ${RPMBUILD_PATH}/SOURCES/
	@cp ${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}.tar.xz ${RPMBUILD_PATH}/SOURCES/
	@rpmbuild -bs python3-certbot-dns-porkbun.spec &>> ${RESULT_PATH}/build.log
	@mv ${RPMBUILD_PATH}/SRPMS/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.src.rpm ${RESULT_PATH}/

${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.noarch.rpm: ${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.src.rpm
	@printf '[INFO] building python3-certbot-dns-porkbun-'${VERSION}-${RELEASE}'.noarch.rpm\n' | tee -a ${RESULT_PATH}/build.log
	@mkdir -p ${RPMBUILD_PATH}/SRPMS/
	@cp ${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.src.rpm ${RPMBUILD_PATH}/SRPMS/
	@rpmbuild --rebuild ${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.src.rpm &>> ${RESULT_PATH}/build.log
	@mv ${RPMBUILD_PATH}/RPMS/noarch/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.noarch.rpm ${RESULT_PATH}/

