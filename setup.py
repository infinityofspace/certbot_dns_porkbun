from setuptools import setup, find_packages

import certbot_dns_porkbun

with open("Readme.md") as f:
    long_description = f.read()

setup(
    name="certbot_dns_porkbun",
    version=certbot_dns_porkbun.__version__,
    author="infinityofspace",
    url="https://github.com/infinityofspace/certbot_dns_porkbun",
    description="Plugin for certbot to obtain certificates using a DNS TXT record for Porkbun domains",
    long_description=long_description,
    long_description_content_type="text/markdown",
    license="MIT",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Programming Language :: Python :: 3.13",
        "License :: OSI Approved :: MIT License",
        "Topic :: Security",
        "Topic :: Internet :: WWW/HTTP",
        "Topic :: Utilities",
        "Topic :: System :: Systems Administration",
    ],
    packages=find_packages(),
    python_requires=">=3.10",
    install_requires=[
        "setuptools>=41.6.0",
        "certbot>=1.18.0,<5.0",
        "pkb_client>=2.0,<3.0",
        "dnspython>=2.0.0,<3.0",
        "tldextract>=5.1.2,<6.0",
    ],
    entry_points={
        "certbot.plugins": [
            "dns-porkbun = certbot_dns_porkbun.cert.client:Authenticator",
        ]
    },
)
