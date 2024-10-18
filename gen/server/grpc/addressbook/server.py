# server.py
import grpc
from concurrent import futures
import addressbook_pb2_grpc  # Import the generated gRPC code


class AddressBookService(addressbook_pb2_grpc.AddressBookServicer):
    # Implement the methods defined in the proto file here
    pass


def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    addressbook_pb2_grpc.add_AddressBookServicer_to_server(
        AddressBookService(), server)
    server.add_insecure_port('[::]:50051')  # Change port as needed
    server.start()
    print("Server is running on port 50051...")
    server.wait_for_termination()


if __name__ == '__main__':
    serve()
