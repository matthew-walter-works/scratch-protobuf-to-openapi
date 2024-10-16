from datetime import date, datetime  # noqa: F401

from typing import List, Dict  # noqa: F401

from openapi_server.models.base_model import Model
from openapi_server.models.person import Person
from openapi_server import util

from openapi_server.models.person import Person  # noqa: E501

class AddressBook(Model):
    """NOTE: This class is auto generated by OpenAPI Generator (https://openapi-generator.tech).

    Do not edit the class manually.
    """

    def __init__(self, people=None):  # noqa: E501
        """AddressBook - a model defined in OpenAPI

        :param people: The people of this AddressBook.  # noqa: E501
        :type people: List[Person]
        """
        self.openapi_types = {
            'people': List[Person]
        }

        self.attribute_map = {
            'people': 'people'
        }

        self._people = people

    @classmethod
    def from_dict(cls, dikt) -> 'AddressBook':
        """Returns the dict as a model

        :param dikt: A dict.
        :type: dict
        :return: The AddressBook of this AddressBook.  # noqa: E501
        :rtype: AddressBook
        """
        return util.deserialize_model(dikt, cls)

    @property
    def people(self) -> List[Person]:
        """Gets the people of this AddressBook.


        :return: The people of this AddressBook.
        :rtype: List[Person]
        """
        return self._people

    @people.setter
    def people(self, people: List[Person]):
        """Sets the people of this AddressBook.


        :param people: The people of this AddressBook.
        :type people: List[Person]
        """

        self._people = people
