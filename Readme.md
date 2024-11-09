# Certbot DNS Porkbun Plugin

Plugin for certbot to obtain certificates using a DNS TXT record for Porkbun domains

---

![PyPI - Python Version](https://img.shields.io/pypi/pyversions/certbot_dns_porkbun?style=for-the-badge)
[![GitHub](https://img.shields.io/github/license/infinityofspace/certbot_dns_porkbun?style=for-the-badge)](https://github.com/infinityofspace/certbot_dns_porkbun/blob/master/License)

[![PyPI](https://img.shields.io/pypi/v/certbot_dns_porkbun?style=for-the-badge)](https://pypi.org/project/certbot-dns-porkbun/)
![PyPI - Downloads](https://img.shields.io/pypi/dm/certbot_dns_porkbun?style=for-the-badge)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/infinityofspace/certbot_dns_porkbun/pypi-build-test.yml?branch=main&style=for-the-badge)](https://github.com/infinityofspace/certbot_dns_porkbun/actions/workflows/pypi-build-test.yml)

[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/infinityofspace/certbot_dns_porkbun?style=for-the-badge&sort=semver&label=Docker)](https://hub.docker.com/r/infinityofspace/certbot_dns_porkbun)
![Docker Pulls](https://img.shields.io/docker/pulls/infinityofspace/certbot_dns_porkbun?style=for-the-badge)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/infinityofspace/certbot_dns_porkbun/latest?style=for-the-badge)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/infinityofspace/certbot_dns_porkbun/docker-publish-unstable.yml?branch=main&style=for-the-badge)](https://github.com/infinityofspace/certbot_dns_porkbun/actions/workflows/docker-publish-unstable.yml)

[![certbot-dns-porkbun](https://snapcraft.io/certbot-dns-porkbun/badge.svg)](https://snapcraft.io/certbot-dns-porkbun)

---

### Table of Contents

1. [About](#about)
2. [Installation](#installation)
   1. [Prerequirements](#prerequirements)
   2. [With pip (recommend)](#with-pip-recommend)
   3. [From source](#from-source)
   4. [Snap](#snap)
3. [Usage](#usage)
   1. [Local installation](#local-installation)
   2. [Credentials file or cli parameters](#credentials-file-or-cli-parameters)   
   3. [Docker](#docker)
4. [FAQ](#faq)
5. [Third party notices](#third-party-notices)
6. [License](#license)

---

### About

_certbot_dns_porkbun_ is a plugin for [_certbot_](https://github.com/certbot/certbot). It handles the TXT record for the
DNS-01 challenge for Porkbun domains. The plugin takes care of the creation and deletion of the TXT record using the
Porkbun API.

### Installation

#### Prerequirements

If you want to use the docker image, then you don't need any requirements other than a working docker installation and
can proceed directly with the [usage](#docker)

You need at least version `3.7` of Python installed. If you want to install the plugin with pip, then you must also have
pip installed beforehand.

If you already have _certbot_ installed, make sure you have at least version `1.18.0` installed. When you installed
*certbot* as snap then you have to use the [snap installation](#snap) of the plugin.

You can check what version of _certbot_ is installed with this command:

```commandline
certbot --version
```

If you don't have certbot installed yet, then the PyPI version of certbot will be installed automatically during the
installation.

**Note: If you want to run certbot with root privileges, then you need to install the plugin as root too. Otherwise,
certbot cannot find the plugin.**

#### With pip (recommend)

Use the following command to install _certbot_dns_porkbun_ with pip:

```commandline
pip3 install certbot_dns_porkbun
```

You can also very easily update to the newest version:

```commandline
pip3 install certbot_dns_porkbun -U
```

#### From source

If you prefer to install the plugin from the source code:

```commandline
git clone https://github.com/infinityofspace/certbot_dns_porkbun.git
cd certbot_dns_porkbun
pip3 install .
```

#### Snap

If you use the *certbot* as snap package then you have to install *certbot_dns_porkbun* as a snap too:

```commandline
snap install certbot-dns-porkbun
```

Now connect the *certbot* snap installation with the plugin snap installation:

```commandline
sudo snap connect certbot:plugin certbot-dns-porkbun
```

The following command should now list `dns-porkbun` as an installed plugin:

```commandline
certbot plugins
```

### Usage

**Note: By default, Porkbun domains cannot be controlled through the API. This will cause an error when you generate certificates. Ensure that you have enabled API Access in your domain's settings to avoid this. If you haven't already, be sure to also delete the (default) parked domain ALIAS records, as not doing so may cause errors.**

#### Local installation

To check if the plugin is installed and detected properly by certbot, you can use the following command:

```commandline
certbot plugins
```

The resulting list should include `dns-porkbun` if everything went fine.

#### Credentials file or cli parameters

You can either use cli parameters to pass authentication information to certbot:

```commandline
...
--dns-porkbun-key <your-porkbun-api-key> \
--dns-porkbun-secret <your-porkbun-api-secret>
```

Or to prevent your credentials from showing up in your bash history, you can also create a
credentials-file `porkbun.ini` (the name does not matter) with the following content:

```ini
dns_porkbun_key=<your-porkbun-api-key>
dns_porkbun_secret=<your-porkbun-api-secret>
```

And then instead of using the `--dns-porkbun-key` and `--dns-porkbun-secret` parameters above you can use

```commandline
...
--dns-porkbun-credentials </path/to/your/porkbun.ini>
```

You can also mix these usages, though the cli parameters always take precedence over the ini file.

#### Examples

Below are some examples of how to use the plugin.

---

Generate a certificate with a DNS-01 challenge for the domain `example.org`:

```commandline
certbot certonly \
  --non-interactive \
  --agree-tos \
  --email <your-email-address> \
  --preferred-challenges dns \
  --authenticator dns-porkbun \
  --dns-porkbun-key <your-porkbun-api-key> \
  --dns-porkbun-secret <your-porkbun-api-secret> \
  --dns-porkbun-propagation-seconds 60 \
  -d "example.com"
```

---

Generate a wildcard certificate with a DNS-01 challenge for all subdomains `*.example.com` (Note: the wildcard
certificate does not contain the root domain itself):

```commandline
certbot certonly \
  --non-interactive \
  --agree-tos \
  --email <your-email-address> \
  --preferred-challenges dns \
  --authenticator dns-porkbun \
  --dns-porkbun-key <your-porkbun-api-key> \
  --dns-porkbun-secret <your-porkbun-api-secret> \
  --dns-porkbun-propagation-seconds 60 \
  -d "*.example.com"
```

---

Generate a certificate with a DNS-01 challenge for the domain `example.org` using a credentials ini file:

```commandline
certbot certonly \
  --non-interactive \
  --agree-tos \
  --email <your-email-address> \
  --preferred-challenges dns \
  --authenticator dns-porkbun \
  --dns-porkbun-credentials </path/to/your/porkbun.ini> \
  --dns-porkbun-propagation-seconds 60 \
  -d "example.com"
```

---

Generate a certificate with a DNS-01 challenge for the domain `example.com` without an account (i.e. without an email
address):

```commandline
certbot certonly \
  --non-interactive \
  --agree-tos \
  --register-unsafely-without-email \
  --preferred-challenges dns \
  --authenticator dns-porkbun \
  --dns-porkbun-key <your-porkbun-api-key> \
  --dns-porkbun-secret <your-porkbun-api-secret> \
  --dns-porkbun-propagation-seconds 60 \
  -d "example.com"
```

---

Generate a staging certificate (i.e. temporary testing certificate) with a DNS-01 challenge for the
domain `example.com`:

```commandline
certbot certonly \
  --non-interactive \
  --agree-tos \
  --email <your-email-address> \
  --preferred-challenges dns \
  --authenticator dns-porkbun \
  --dns-porkbun-key <your-porkbun-api-key> \
  --dns-porkbun-secret <your-porkbun-api-secret> \
  --dns-porkbun-propagation-seconds 60 \
  -d "example.com" \
  --staging
```

---

The DNS-01 challenge specification allows to forward the challenge to another domain by CNAME entries and thus to 
perform the validation from another domain.

For example, we have the domain `example.com` and `mydomain.com`. The nameservers of `example.com` domain are the  
Porkbun nameserver and `mydomain.com` is somewhere else. 
In order to perform a DNS-01 challenge for the domain `mydomain.com`, we only need to add this 
`_acme-challenge.mydomain.com` to `_acme-challenge.example.com` CNAME entry in advance:

```commandline
_acme-challenge.mydomain.com. 600 IN CNAME _acme-challenge.example.com.
```

Then we can use our Porkbun domain for the actual DNS-01 challenge.
The procedure is identical as if we perform a DNS-01 challenge for a Porkbun domain, except that the domain name for 
which we perform the challenge is now `mydomain.com` instead of Porkbun's `example.com`.

```commandline
certbot certonly \
  --non-interactive \
  --agree-tos \
  --email <your-email-address> \
  --preferred-challenges dns \
  --authenticator dns-porkbun \
  --dns-porkbun-key <your-porkbun-api-key> \
  --dns-porkbun-secret <your-porkbun-api-secret> \
  --dns-porkbun-propagation-seconds 60 \
  -d "mydomain.com"
```

What happens in the background is that the CNAME entry is followed to the end and then a TXT entry is created with the 
form `_acme-challenge.example.com.` for the found `example.com` Prokbun domain.
Thus, during the challenge of this example, the DNS would look like this:

```commandline
_acme-challenge.mydomain.com. 600 IN CNAME _acme-challenge.example.com.
_acme-challenge.example.com. 60 TXT "a8sdhb09a7sbd08ashd90ashd90a8hsa9usd"
```

---

You can find al list of all available certbot cli options in
the [official documentation](https://certbot.eff.org/docs/using.html#certbot-command-line-options) of _certbot_.

#### Docker

You can simply start a new container and use the same certbot commands to obtain a new certificate:

```commandline
docker run -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/log/letsencrypt:/var/log/letsencrypt" infinityofspace/certbot_dns_porkbun:latest \
   certonly \
     --non-interactive \
     --agree-tos \
     --email <your-email-address> \
     --preferred-challenges dns \
     --authenticator dns-porkbun \
     --dns-porkbun-key <your-porkbun-api-key> \
     --dns-porkbun-secret <your-porkbun-api-secret> \
     --dns-porkbun-propagation-seconds 60 \
     -d "example.com"
```

Or you can use a credentials file:

```commandline
docker run -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/log/letsencrypt:/var/log/letsencrypt" -v "/absolute/path/to/your/porkbun.ini:/conf/porkbun.ini" infinityofspace/certbot_dns_porkbun:latest \
   certonly \
     --non-interactive \
     --agree-tos \
     --email <your-email-address> \
     --preferred-challenges dns \
     --authenticator dns-porkbun \
     --dns-porkbun-credentials /conf/porkbun.ini \
     --dns-porkbun-propagation-seconds 60 \
     -d "example.com"
```

### Development

#### Setup environment

First get the source code:

```commandline
git clone https://github.com/infinityofspace/certbot_dns_porkbun.git
cd certbot_dns_porkbun
```

Now create a virtual environment, activate it and install all dependencies with the following commands:

```commandline
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
```

Now you can start developing.

Feel free to contribute to this project by creating a pull request.
Before you create a pull request, make sure that you code meets the following requirements (you can use the specified
commands to check/fulfill the requirements):

- check unit tests: `python -m unittest tests/*.py`
- format the code: `ruff format`
- check linting errors: `ruff check`

#### Tests

You can run the tests with the following command:

```commandline
python -m unittest tests/*.py
```

### Third party notices

All modules used by this project are listed below:

|                            Name                             |                                                License                                                |
|:-----------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------:|
|        [certbot](https://github.com/certbot/certbot)        |          [Apache 2.0](https://raw.githubusercontent.com/certbot/certbot/master/LICENSE.txt)           |
|      [setuptools](https://github.com/pypa/setuptools)       |                 [MIT](https://raw.githubusercontent.com/pypa/setuptools/main/LICENSE)                 |
| [pkb_client](https://github.com/infinityofspace/pkb_client) |                [MIT](https://github.com/infinityofspace/pkb_client/blob/main/License)                 |
|     [dnspython](https://github.com/rthalley/dnspython)      |              [ISC](https://raw.githubusercontent.com/rthalley/dnspython/master/LICENSE)               |
| [tldextract](https://github.com/john-kurkowski/tldextract)  | [BSD 3-Clause](https://raw.githubusercontent.com/john-kurkowski/tldextract/refs/heads/master/LICENSE) |

Furthermore, this readme file contains embeddings of [Shields.io](https://github.com/badges/shields).

### License

[MIT](https://github.com/infinityofspace/certbot_dns_porkbun/blob/master/License) - Copyright (c) Marvin Heptner
