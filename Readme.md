# Certbot DNS Porkbun Plugin

Plugin for certbot to obtain certificates using a DNS TXT record for Porkbun domains

---

[![PyPI](https://img.shields.io/pypi/v/certbot_dns_porkbun)](https://pypi.org/project/certbot-dns-porkbun/) ![PyPI - Python Version](https://img.shields.io/pypi/pyversions/certbot_dns_porkbun) [![GitHub](https://img.shields.io/github/license/infinityofspace/certbot_dns_porkbun)](https://github.com/infinityofspace/certbot_dns_porkbun/blob/master/License) [![Downloads](https://static.pepy.tech/personalized-badge/certbot-dns-porkbun?period=total&units=international_system&left_color=grey&right_color=orange&left_text=Total%20Downloads)](https://pepy.tech/project/certbot-dns-porkbun) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/infinityofspace/certbot_dns_porkbun/Publish%20release%20distribution%20to%20PyPI)

---

### Table of Contents

1. [About](#about)
2. [Installation](#installation)
   1. [Prerequirements](#prerequirements)
   2. [With pip (recommend)](#with-pip-recommend)
   3. [From source](#from-source)
3. [Usage](#usage)
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

You need at least version `3.6` of Python installed. If you want to install the plugin with pip, then you must also have
pip installed beforehand.

If you already have _certbot_ installed, make sure you have at least version `1.1.0` installed.

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

### Usage

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

Or to prevent your credentials from showing up in your bash history, you can also create a credentials-file `porkbun.ini` (the name does not matter) with the following content:

```ini
dns_porkbun_key=<your-porkbun-api-key>
dns_porkbun_secret=<your-porkbun-api-secret>
```

And then instead of using the `--dns-porkbun-key` parameter above you can use

```commandline
...
--dns-porkbun-credentials </path/to/your/porkbun.ini>
```

You can also mix these usages, though the cli parameters always take precedence over the ini file.

#### Examples

Below are some examples of how to use the plugin.

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

You can find al list of all available certbot cli options in
the [official documentation](https://certbot.eff.org/docs/using.html#certbot-command-line-options) of _certbot_.

### Third party notices

All modules used by this project are listed below:

|                                Name                                |                                            License                                            |
| :----------------------------------------------------------------: | :-------------------------------------------------------------------------------------------: |
|           [certbot](https://github.com/certbot/certbot)            |      [Apache 2.0](https://raw.githubusercontent.com/certbot/certbot/master/LICENSE.txt)       |
|            [requests](https://github.com/psf/requests)             |          [Apache 2.0](https://raw.githubusercontent.com/psf/requests/master/LICENSE)          |
| [zope.interface](https://github.com/zopefoundation/zope.interface) | [ZPL-2.1](https://raw.githubusercontent.com/zopefoundation/zope.interface/master/LICENSE.txt) |
|          [setuptools](https://github.com/pypa/setuptools)          |             [MIT](https://raw.githubusercontent.com/pypa/setuptools/main/LICENSE)             |
|    [pkb_client](https://github.com/infinityofspace/pkb_client)     |            [MIT](https://github.com/infinityofspace/pkb_client/blob/main/License)             |

Furthermore, this readme file contains embeddings of [Shields.io](https://github.com/badges/shields)
and [PePy](https://github.com/psincraian/pepy).

### License

[MIT](https://github.com/infinityofspace/certbot_dns_porkbun/blob/master/License) - Copyright (c) Marvin Heptner
