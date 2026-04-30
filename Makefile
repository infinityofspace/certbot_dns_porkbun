VERSION       = 0.11.0
RELEASE       = 1

# system paths
RESULT_PATH   = ${PWD}/target

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

BuildArch:      noarch
BuildRequires:  python3-devel

%description
Plugin for certbot to obtain certificates using a DNS TXT record for Porkbun domains

%prep
%autosetup -n %{modname}_v%{version}

%generate_buildrequires
%pyproject_buildrequires

%build
%pyproject_wheel

%install
%pyproject_install

%files
%doc Readme.md
%license License
%{python3_sitelib}/%{modname}/
%{python3_sitelib}/%{modname}-*.dist-info/

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
	@cp -r certbot_dns_porkbun requirements.txt setup.py License Readme.md \
		${RESULT_PATH}/certbot_dns_porkbun_v${VERSION}/
	@cd ${RESULT_PATH}; tar -I "pxz -9" -cf python3-certbot-dns-porkbun-${VERSION}.tar.xz certbot_dns_porkbun_v${VERSION}

${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.src.rpm: ${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}.tar.xz python3-certbot-dns-porkbun.spec
	@printf '[INFO] building python3-certbot-dns-porkbun-'${VERSION}-${RELEASE}'.src.rpm\n' | tee -a ${RESULT_PATH}/build.log
	@rpmbuild -D "_topdir ${RESULT_PATH}" -D "_sourcedir %{_topdir}" -bs python3-certbot-dns-porkbun.spec &>> ${RESULT_PATH}/build.log
	@mv ${RESULT_PATH}/SRPMS/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.src.rpm ${RESULT_PATH}/

${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.noarch.rpm: ${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.src.rpm
	@printf '[INFO] building python3-certbot-dns-porkbun-'${VERSION}-${RELEASE}'.noarch.rpm\n' | tee -a ${RESULT_PATH}/build.log
	@mkdir -p ${RESULT_PATH}/SRPMS/
	@cp ${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.src.rpm ${RESULT_PATH}/SRPMS/
	@rpmbuild -D "_topdir ${RESULT_PATH}" --rebuild ${RESULT_PATH}/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.src.rpm &>> ${RESULT_PATH}/build.log
	@mv ${RESULT_PATH}/RPMS/noarch/python3-certbot-dns-porkbun-${VERSION}-${RELEASE}.noarch.rpm ${RESULT_PATH}/

