import connexion
from typing import Dict
from typing import Tuple
from typing import Union

from openapi_server.models.add_person_response import AddPersonResponse  # noqa: E501
from openapi_server.models.address_book import AddressBook  # noqa: E501
from openapi_server.models.person import Person  # noqa: E501
from openapi_server.models.status import Status  # noqa: E501
from openapi_server import util


def address_book_service_add_person(person):  # noqa: E501
    """address_book_service_add_person

    Add a new person to the address book # noqa: E501

    :param person: 
    :type person: dict | bytes

    :rtype: Union[AddPersonResponse, Tuple[AddPersonResponse, int], Tuple[AddPersonResponse, int, Dict[str, str]]
    """
    if connexion.request.is_json:
        person = Person.from_dict(connexion.request.get_json())  # noqa: E501
    return 'do some magic!'


def address_book_service_get_person(id):  # noqa: E501
    """address_book_service_get_person

    Get a person by their ID # noqa: E501

    :param id: 
    :type id: int

    :rtype: Union[Person, Tuple[Person, int], Tuple[Person, int, Dict[str, str]]
    """
    return 'do some magic!'


def address_book_service_list_people():  # noqa: E501
    """address_book_service_list_people

    List all people in the address book # noqa: E501


    :rtype: Union[AddressBook, Tuple[AddressBook, int], Tuple[AddressBook, int, Dict[str, str]]
    """
    return 'do some magic!'
