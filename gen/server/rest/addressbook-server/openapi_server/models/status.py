from datetime import date, datetime  # noqa: F401

from typing import List, Dict  # noqa: F401

from openapi_server.models.base_model import Model
from openapi_server.models.google_protobuf_any import GoogleProtobufAny
from openapi_server import util

from openapi_server.models.google_protobuf_any import GoogleProtobufAny  # noqa: E501

class Status(Model):
    """NOTE: This class is auto generated by OpenAPI Generator (https://openapi-generator.tech).

    Do not edit the class manually.
    """

    def __init__(self, code=None, message=None, details=None):  # noqa: E501
        """Status - a model defined in OpenAPI

        :param code: The code of this Status.  # noqa: E501
        :type code: int
        :param message: The message of this Status.  # noqa: E501
        :type message: str
        :param details: The details of this Status.  # noqa: E501
        :type details: List[GoogleProtobufAny]
        """
        self.openapi_types = {
            'code': int,
            'message': str,
            'details': List[GoogleProtobufAny]
        }

        self.attribute_map = {
            'code': 'code',
            'message': 'message',
            'details': 'details'
        }

        self._code = code
        self._message = message
        self._details = details

    @classmethod
    def from_dict(cls, dikt) -> 'Status':
        """Returns the dict as a model

        :param dikt: A dict.
        :type: dict
        :return: The Status of this Status.  # noqa: E501
        :rtype: Status
        """
        return util.deserialize_model(dikt, cls)

    @property
    def code(self) -> int:
        """Gets the code of this Status.

        The status code, which should be an enum value of [google.rpc.Code][google.rpc.Code].  # noqa: E501

        :return: The code of this Status.
        :rtype: int
        """
        return self._code

    @code.setter
    def code(self, code: int):
        """Sets the code of this Status.

        The status code, which should be an enum value of [google.rpc.Code][google.rpc.Code].  # noqa: E501

        :param code: The code of this Status.
        :type code: int
        """

        self._code = code

    @property
    def message(self) -> str:
        """Gets the message of this Status.

        A developer-facing error message, which should be in English. Any user-facing error message should be localized and sent in the [google.rpc.Status.details][google.rpc.Status.details] field, or localized by the client.  # noqa: E501

        :return: The message of this Status.
        :rtype: str
        """
        return self._message

    @message.setter
    def message(self, message: str):
        """Sets the message of this Status.

        A developer-facing error message, which should be in English. Any user-facing error message should be localized and sent in the [google.rpc.Status.details][google.rpc.Status.details] field, or localized by the client.  # noqa: E501

        :param message: The message of this Status.
        :type message: str
        """

        self._message = message

    @property
    def details(self) -> List[GoogleProtobufAny]:
        """Gets the details of this Status.

        A list of messages that carry the error details.  There is a common set of message types for APIs to use.  # noqa: E501

        :return: The details of this Status.
        :rtype: List[GoogleProtobufAny]
        """
        return self._details

    @details.setter
    def details(self, details: List[GoogleProtobufAny]):
        """Sets the details of this Status.

        A list of messages that carry the error details.  There is a common set of message types for APIs to use.  # noqa: E501

        :param details: The details of this Status.
        :type details: List[GoogleProtobufAny]
        """

        self._details = details
