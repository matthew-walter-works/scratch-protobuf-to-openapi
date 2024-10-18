import unittest

from flask import json

from openapi_server.models.add_person_response import AddPersonResponse  # noqa: E501
from openapi_server.models.address_book import AddressBook  # noqa: E501
from openapi_server.models.person import Person  # noqa: E501
from openapi_server.models.status import Status  # noqa: E501
from openapi_server.test import BaseTestCase


class TestAddressBookServiceController(BaseTestCase):
    """AddressBookServiceController integration test stubs"""

    def test_address_book_service_add_person(self):
        """Test case for address_book_service_add_person

        
        """
        person = {"lastUpdated":"2000-01-23T04:56:07.000+00:00","name":"name","phones":[{"number":"number","type":6},{"number":"number","type":6}],"id":0,"email":"email"}
        headers = { 
            'Accept': 'application/json',
            'Content-Type': 'application/json',
        }
        response = self.client.open(
            '/v1/person',
            method='POST',
            headers=headers,
            data=json.dumps(person),
            content_type='application/json')
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_address_book_service_get_person(self):
        """Test case for address_book_service_get_person

        
        """
        headers = { 
            'Accept': 'application/json',
        }
        response = self.client.open(
            '/v1/person/{id}'.format(id=56),
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    def test_address_book_service_list_people(self):
        """Test case for address_book_service_list_people

        
        """
        headers = { 
            'Accept': 'application/json',
        }
        response = self.client.open(
            '/v1/people',
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
