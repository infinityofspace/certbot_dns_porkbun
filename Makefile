VERSION       = 0.10.0
RELEASE       = 1

# system paths
RESULT_PATH   = target
RPMBUILD_PATH = ~/rpmbuild

#------------------------------------------------------------------------------
# COMMANDS
#------------------------------------------------------------------------------

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


#------------------------------------------------------------------------------
# FILE GENERATORs
#------------------------------------------------------------------------------

define _spec_generator
cat << EOF
%global modname certbot_dns_porkbun

Name:           python3-certbot-dns-porkbun
Version:        ${VERSION}
Release:        ${RELEASE}
Obsoletes:      %{name} <= %{version}
Summary:        Certbot DNS Porkbun Plugin
License:        MIT License
URL:            https://github.com/infinityofspace/certbot_dns_porkbun/
Source0:        %{name}-%{version}.tar.xz

Requires:       python3-certbot >= 1.18.0, python3-certbot < 4.0
Requires:       python3-pkb-client >= 2, python3-pkb-client < 3.0
Requires:       python3-dns >= 2.0.0, python3-dns < 3.0
Requires:       python3-tldextract

BuildArch:      noarch
BuildRequires:  python3-setuptools
BuildRequires:  python3-rpm-macros
BuildRequires:  python3-py

%?python_enable_dependency_generator

%description
Plugin for certbot to obtain certificates using a DNS TXT record for Porkbun domains

%prep
%autosetup -n %{modname}_v%{version}

%build
%py3_build

%install
%py3_install

%files
%doc Readme.md
%license License
%{python3_sitelib}/%{modname}/
%{python3_sitelib}/%{modname}-%{version}*

%changelog
...

EOF
endef
export spec_generator = $(value _spec_generator)

python3-certbot-dns-porkbun.spec:
	@mkdir -p ${RESULT_PATH}/
	@printf '[INFO] generating python3-certbot-dns-porkbun.spec\n' | tee -a ${RESULT_PATH}/build.log
	@ VERSION=${VERSION} RELEASE=${RELEASE} eval "$$spec_generator" > python3-certbot-dns-porkbun.spec

${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}.tar.xz:
	@mkdir -p ${RESULT_PATH}/
	@printf '[INFO] packing python3-certbot-dns-porkbun-'${VERSION}'.tar.xz\n' | tee -a ${RESULT_PATH}/build.log
	@mkdir -p ${RESULT_PATH}/certbot_dns_porkbun_v${VERSION}
	@cp -r certbot_dns_porkbun pyproject.toml License Readme.md \
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

