import logging

import dns.name
import zope.interface
from certbot import errors, interfaces
from certbot.plugins import dns_common
from dns import resolver
from pkb_client.client import PKBClient

DEFAULT_PROPAGATION_SECONDS = 60

ACME_TXT_PREFIX = "_acme-challenge"


@zope.interface.implementer(interfaces.IAuthenticator)
@zope.interface.provider(interfaces.IPluginFactory)
class Authenticator(dns_common.DNSAuthenticator):
    """
    Authenticator class to handle a DNS-01 challenge for Porkbun domains.
    """

    description = "Obtain certificates using a DNS TXT record for Porkbun domains"
    record_ids = dict()

    _domain = None

    def __init__(self, *args, **kwargs) -> None:
        super(Authenticator, self).__init__(*args, **kwargs)
        self.credentials = None

    @classmethod
    def add_parser_arguments(cls, add: callable) -> None:
        """
        Add required or optional argument for the cli of certbot.

        :param add: method handling the argument adding to the cli
        """

        super(Authenticator, cls).add_parser_arguments(add, default_propagation_seconds=DEFAULT_PROPAGATION_SECONDS)
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

        self._configure_file('credentials',
                             'Absolute path to Porkbun credentials INI file')
        dns_common.validate_file_permissions(self.conf('credentials'))
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

        # replace wildcard in domain
        domain = domain.replace("*", "")
        domain = f"{ACME_TXT_PREFIX}.{domain}"

        propagation_seconds = self.conf("propagation_seconds")

        try:
            # follow all CNAME and DNAME records
            canonical_name = resolver.canonical_name(domain)

            if domain != canonical_name.to_text().rstrip('.') and propagation_seconds < 600:
                logging.warning("Make sure your CNAME record is propagated to all DNS servers, "
                                "because the default CNAME TTL propagation time is 600 seconds "
                                f"and your certbot propagation time is only {propagation_seconds}.")

            self._root_domain = canonical_name.split(3)[1].to_text().rstrip('.')

            acme_challenge_prefix = dns.name.Name(labels=[ACME_TXT_PREFIX])
            if acme_challenge_prefix.fullcompare(dns.name.Name(labels=[canonical_name.labels[0]]))[0] \
                    == dns.name.NAMERELN_EQUAL:
                name = canonical_name.split(3)[0].to_text()
            else:
                name = acme_challenge_prefix.concatenate(canonical_name.split(3)[0]).to_text()
        except (resolver.NoAnswer, resolver.NXDOMAIN):
            canonical_name = domain

            self._root_domain = ".".join(canonical_name.split('.')[-2:])

            name = ".".join(canonical_name.split('.')[:-2])

        try:
            self.record_ids[validation] = self._get_porkbun_client().dns_create(self._root_domain,
                                                                                "TXT",
                                                                                validation,
                                                                                name=name)
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
        record_id = self.record_ids[validation]

        try:
            if not self._get_porkbun_client().dns_delete(self._root_domain, record_id):
                raise errors.PluginError("TXT for domain {} was not deleted".format(domain))
        except Exception as e:
            raise errors.PluginError(e)

    def _get_porkbun_client(self) -> PKBClient:
        """
        Create a new PKBClient with the provided API key and secret.

        :return: the created PKBClient object
        """

        key = self.conf("key") or self.credentials.conf("key")
        secret = self.conf("secret") or self.credentials.conf("secret")

        return PKBClient(key, secret)
