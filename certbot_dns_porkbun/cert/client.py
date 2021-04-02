import zope.interface
from certbot import errors, interfaces
from certbot.plugins import dns_common
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

    def __init__(self, *args, **kwargs) -> None:
        super(Authenticator, self).__init__(*args, **kwargs)

    @classmethod
    def add_parser_arguments(cls, add: callable) -> None:
        """
        Add required or optional argument for the cli of certbot.

        :param add: method handling the argument adding to the cli
        """

        super(Authenticator, cls).add_parser_arguments(add, default_propagation_seconds=DEFAULT_PROPAGATION_SECONDS)
        add("key", help="Porkbun API key")
        add("secret", help="Porkbun API key secret")

    @staticmethod
    def more_info() -> str:
        """
        Get more information about this plugin.
        This method is used by certbot to show more info about this plugin.

        :return: string with more information about this plugin
        """

        return "This plugin configures a DNS TXT record to respond to a DNS-01 challenge using the Porkbun API."

    def _setup_credentials(self):
        pass

    def _perform(self, domain: str, validation_name: str, validation: str) -> None:
        """
        Add the validation DNS TXT record to the provided Porkbun domain.

        :param domain: the Porkbun domain for which a TXT record will be created
        :param validation_name: the value to validate the dns challenge
        :param validation: the value for the TXT record

        :raise PluginError: if the TXT record can not be set or something goes wrong
        """

        domain_parts = domain.split(".")
        root_domain = ".".join(domain_parts[-2:])
        subdomains = domain_parts[:-2]

        if len(subdomains) > 0:
            name = ACME_TXT_PREFIX + "." + ".".join(subdomains)
        else:
            name = ACME_TXT_PREFIX

        try:
            self.record_ids[validation] = self._get_porkbun_client().dns_create(root_domain, "TXT", validation,
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

        domain_parts = domain.split(".")
        root_domain = ".".join(domain_parts[-2:])

        # get the record id with the TXT record
        record_id = self.record_ids[validation]

        try:
            if not self._get_porkbun_client().dns_delete(root_domain, record_id):
                raise errors.PluginError("TXT for domain {} was not deleted".format(domain))
        except Exception as e:
            raise errors.PluginError(e)

    def _get_porkbun_client(self) -> PKBClient:
        """
        Create a new PKBClient with the provided API key and secret.

        :return: the created PKBClient object
        """

        return PKBClient(self.conf("key"), self.conf("secret"))
