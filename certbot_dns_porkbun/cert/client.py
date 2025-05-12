"""
The certbot Authenticator implementation for Porkbun domains.
"""

import logging

from pkb_client.client import PKBClient, DNSRecordType
from dns import resolver
from tldextract import tldextract
from certbot import errors
from certbot.plugins import dns_common


DEFAULT_PROPAGATION_SECONDS = 600

ACME_TXT_PREFIX = "_acme-challenge"


def resolve_challenge_domain(domain) -> tuple[str, str]:
    """
    Resolve the challenge root domain and subdomain from the provided domain.
    It follows CNAME and DNAME records to find the canonical name.

    :param domain: the domain to get the challenge root domain and subdomain from
    :return: a tuple of the root domain and subdomain
    """

    domain = domain.replace("*", "")
    domain = f"{ACME_TXT_PREFIX}.{domain}"

    try:
        # follow all CNAME and DNAME records
        canonical_name = resolver.canonical_name(domain)
        logging.info(
            "Resolved domain '%s' to '%s' via CNAME/DNAME record",
            domain,
            canonical_name,
        )
    except (resolver.NoAnswer, resolver.NXDOMAIN):
        canonical_name = domain

    extract_result = tldextract.extract(canonical_name.to_text())
    root_domain = f"{extract_result.domain}.{extract_result.suffix}"
    name = extract_result.subdomain

    return root_domain, name


class Authenticator(dns_common.DNSAuthenticator):
    """
    Authenticator class to handle a DNS-01 challenge for Porkbun domains.
    """

    description = "Obtain certificates using a DNS TXT record for Porkbun domains"

    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self.credentials = None

    @classmethod
    def add_parser_arguments(
        cls, add: callable, default_propagation_seconds=DEFAULT_PROPAGATION_SECONDS
    ) -> None:
        """
        Add required or optional argument for the cli of certbot.

        :param add: method handling the argument adding to the cli
        """

        super(Authenticator, cls).add_parser_arguments(
            add, default_propagation_seconds=default_propagation_seconds
        )
        add("credentials", help="Porkbun credentials INI file.")
        add("key", help="Porkbun API key (overwrites credentials file)")
        add("secret", help="Porkbun API key secret (overwrites credentials file)")

    def more_info(self) -> str:
        """
        Get more information about this plugin.
        This method is used by certbot to show more info about this plugin.

        :return: string with more information about this plugin
        """

        return "This plugin configures a DNS TXT record to respond to a DNS-01 challenge using the Porkbun DNS API."

    def _setup_credentials(self) -> None:
        """
        Setup Porkbun key and secret from credentials file.
        """

        # If both cli params are provided we do not need a credentials file
        if self.conf("key") and self.conf("secret"):
            return

        self._configure_file(
            "credentials", "Absolute path to Porkbun credentials INI file"
        )
        dns_common.validate_file_permissions(self.conf("credentials"))
        self.credentials = self._configure_credentials(
            "credentials",
            "Porkbun credentials INI file",
            {
                "key": "Porkbun API key.",
                "secret": "Porkbun API key secret.",
            },
        )

    def _perform(self, domain: str, validation_name: str, validation: str) -> None:
        """
        Add the validation DNS TXT record to the provided Porkbun domain.
        Moreover, it resolves the canonical name (CNAME) for the provided domain with the acme txt prefix.

        :param domain: the Porkbun domain for which a TXT record will be created
        :param validation_name: the value to validate the dns challenge
        :param validation: the value for the TXT record

        :raise PluginError: if the TXT record can not be set or something goes wrong
        """

        client = self._get_porkbun_client()

        propagation_seconds = self.conf("propagation_seconds")
        if propagation_seconds < 600:
            logging.warning(
                "The propagation time is less than Porkbun DNS TTL minimum of 600 seconds. Subsequent "
                "challenges for same domain may fail. Try increasing the propagation time if you encounter "
                "issues."
            )

        root_domain, name = resolve_challenge_domain(domain)

        # check if there is already a dns challenge record for the domain
        challenge_dns_records = client.get_all_dns_records(
            domain=root_domain, record_type=DNSRecordType.TXT, subdomain=name
        )
        if any(record.content == validation for record in challenge_dns_records):
            logging.warning(
                "Challenge TXT record already exists for domain %s with value %s. Skipping record creation.",
                domain,
                validation,
            )
        else:
            try:
                client.create_dns_record(
                    root_domain, DNSRecordType.TXT, validation, name=name
                )
            except Exception as e:
                raise errors.PluginError(e)

    def _cleanup(self, domain: str, validation_name: str, validation: str) -> None:
        """
        Delete the TXT record of the provided Porkbun domain.

        :param domain: the Porkbun domain for which the TXT record will be deleted
        :param validation_name: the value to validate the dns challenge
        :param validation: the value for the TXT record

        :raise PluginError:  if the TXT record can not be deleted or something goes wrong
        """

        # get the record id with the TXT record
        root_domain, name = resolve_challenge_domain(domain)

        challenge_dns_records = self._get_porkbun_client().get_all_dns_records(
            domain=root_domain, record_type=DNSRecordType.TXT, subdomain=name
        )

        record_id = None
        for record in challenge_dns_records:
            if record.content == validation:
                record_id = record.id
                break

        if record_id is None:
            logging.warning(
                "No challenge TXT record found for domain %s with value %s",
                domain,
                validation,
            )
        elif not self._get_porkbun_client().delete_dns_record(root_domain, record_id):
            raise errors.PluginError(f"TXT for domain {root_domain} was not deleted")

    def _get_porkbun_client(self) -> PKBClient:
        """
        Create a new PKBClient with the provided API key and secret.

        :return: the created PKBClient object
        """

        key = self.conf("key") or self.credentials.conf("key")
        secret = self.conf("secret") or self.credentials.conf("secret")

        return PKBClient(key, secret)
