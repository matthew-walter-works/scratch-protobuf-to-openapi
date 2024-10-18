Here’s the updated README with the correct folder structure reflecting that the `gen` directory is at the root level and the Dockerfiles are located in a `docker` folder:

---

# Protobuf to OpenAPI Generator

This repository provides a simple setup using Docker and Makefile to automate the process of converting `.proto` files to OpenAPI specifications, generating TypeScript clients, and creating gRPC Python servers from those specs.

## Prerequisites

Before running the project, make sure you have the following installed:

- [Docker](https://www.docker.com/get-started)
- [Make](https://www.gnu.org/software/make/)

## Folder Structure

```
.
├── docker/                  # Directory containing Dockerfiles
│   ├── Dockerfile.grpc      # Dockerfile for gRPC server
│   └── Dockerfile.openapi   # Dockerfile for OpenAPI and REST API generation
├── Makefile                 # Makefile to automate the build process
├── shared/                  # Directory for proto files and generated outputs
│   ├── proto/               # Place your .proto files here
├── gen/                     # Generated gRPC stubs, OpenAPI specs, and clients
│   ├── openapi/             # Generated OpenAPI specs
│   ├── clients/             # Generated clients (TypeScript and gRPC)
│       ├── grpc/            # gRPC client files
│       └── rest/            # REST client files
│   └── server/              # Generated server stubs (REST and gRPC)
│       ├── grpc/            # gRPC server files
│       └── rest/            # REST server files
└── README.md                # Documentation for usage
```

### Steps

1. **Place your Protobuf files** in the `shared/proto/` directory.

2. **Build the Docker images**:
   Run the following command to build the Docker environment that contains all the necessary tools (e.g., `protoc`, `protoc-gen-openapi`, etc.):
   
   ```bash
   make build_docker_images
   ```

3. **Generate gRPC stubs, OpenAPI specs, TypeScript clients, and gRPC Python servers**:
   To compile all `.proto` files in the `shared/proto/` directory into gRPC stubs, OpenAPI specs, and corresponding TypeScript clients and gRPC Python servers, run:
   
   ```bash
   make all
   ```

4. **View the generated files**:
   - **gRPC stubs** will be generated in the `gen/clients/grpc/` directory.
   - **OpenAPI specs** will be generated in the `gen/openapi/` directory.
   - **TypeScript clients** will be generated for each `.proto` file in the `gen/clients/typescript/` directory.
   - **gRPC Python server files** will be generated in the `gen/server/grpc/` directory.

## Makefile Commands

- **Build Docker Images**:
  ```bash
  make build_docker_images
  ```
  Builds the Docker images that include Protobuf and OpenAPI generators as well as gRPC server dependencies.

- **Generate gRPC Stubs, OpenAPI Specs, TypeScript Clients, and gRPC Python Servers**:
  ```bash
  make all
  ```
  Runs the entire process of generating gRPC stubs, OpenAPI specs, TypeScript clients, and a gRPC Python server from the `.proto` files in the `shared/proto/` directory.

- **Clean Generated Files**:
  ```bash
  make clean
  ```
  Removes all generated files from `gen/` and `gen/openapi/`.

- **Run Docker Container Interactively**:
  ```bash
  make run_docker
  ```
  Runs the Docker container interactively so you can manually execute commands inside it.

## Example

Assuming you have a file `addressbook.proto` in the `shared/proto/` directory, running `make all` will:

- Generate gRPC stubs and TypeScript clients in `gen/clients/`.
- Generate an OpenAPI spec in `gen/openapi/`.
- Generate a gRPC Python server in `gen/server/grpc/`.

For example:

```bash
shared/
└── proto/
    └── addressbook.proto
gen/
├── clients/
│   ├── grpc/
│   │   └── addressbook/
│   └── typescript/
│       └── addressbook/
├── openapi/
│   ├── addressbook.yaml
└── server/
    ├── grpc/
    │   └── addressbook/
    └── rest/
        └── addressbook/
```

## Proto3 Requirements for OpenAPI Generation

If you're using Protobuf files with `proto3`, here are some important requirements to ensure successful generation of OpenAPI specs:

1. **Ensure `go_package` is Defined**:
   - OpenAPI generation with `protoc-gen-openapi` requires a `go_package` option in each `.proto` file. Add this to your Protobuf file:
     ```proto
     option go_package = "your/package/name";
     ```

2. **Include `google.api.http` Annotations**:
   - The OpenAPI spec requires HTTP mappings to understand how RPC methods map to RESTful operations (e.g., `GET`, `POST`). Use the `google.api.http` annotations in your `.proto` file. For example:
     ```proto
     import "google/api/annotations.proto";

     service ExampleService {
       rpc GetExample(GetExampleRequest) returns (ExampleResponse) {
         option (google.api.http) = {
           get: "/v1/example/{id}"
         };
       }
     }
     ```

   - Ensure you include `annotations.proto` and `http.proto` in your project or make them accessible in your Docker container.

3. **Import Required Google Protobuf Files**:
   - Make sure `annotations.proto` and `http.proto` are included in your project. You can download them from [googleapis](https://github.com/googleapis/googleapis/tree/master/google/api) and include them in your project under `google/api/`.

## Troubleshooting Empty OpenAPI Spec

If you're getting an empty OpenAPI spec (`paths: {}` and `components: {}`), follow these troubleshooting steps:

1. **Check `google.api.http` Annotations**:
   - Without these annotations, the generator doesn’t know how to map RPC methods to HTTP RESTful operations. Make sure every RPC method in your `.proto` files has the appropriate HTTP mappings using `google.api.http`.

2. **Verify `go_package`**:
   - Ensure that each `.proto` file has the `go_package` option defined. This is required for the `protoc-gen-openapi` plugin to correctly map package names.

3. **Verify File Imports**:
   - Ensure that the necessary Protobuf files, like `annotations.proto` and `http.proto`, are accessible in your Docker container's environment or are correctly referenced in your `.proto` file.

4. **Run the Commands Interactively**:
   - You can use the `make run_docker` command to open a shell inside the Docker container and manually run `protoc` commands to debug any specific issues.

5. **Check the Protobuf Syntax**:
   - Ensure that your `.proto` files use `proto3` syntax, as the `proto2` syntax may not be fully supported for OpenAPI generation:
     ```proto
     syntax = "proto3";
     ```

6. **Check the Output Directory**:
   - Verify that the OpenAPI spec file is being saved in the `shared/openapi/` directory after generation. You can list the contents using:
     ```bash
     ls -l shared/openapi/
     ```

If the OpenAPI spec remains empty after following these steps, double-check the `.proto` file for any missing options or annotations, or try generating a minimal Protobuf file with a simple service and HTTP mappings to isolate the issue.

## License

This project is licensed under the MIT License.
