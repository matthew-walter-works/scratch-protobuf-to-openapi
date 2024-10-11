# Variables
DOCKER_IMAGE = grpc-openapi-builder
CONTAINER_WORKDIR = /usr/src/app
PROTO_DIR = shared/proto
PROTO_GEN_DIR = shared/gen
OPENAPI_GEN_DIR = shared/openapi
ARTIFACT_DIR = artifact
EXAMPLE_PROTO_URL = https://raw.githubusercontent.com/protocolbuffers/protobuf/refs/heads/main/examples/addressbook.proto

# Docker-related commands
DOCKER_RUN = docker run -v $(PWD):$(CONTAINER_WORKDIR) --rm $(DOCKER_IMAGE)

# Rules
.PHONY: all clean proto openapi sync build_docker_image install_protobuf_example run_docker artifact

# Build the Docker image
build_docker_image:
	@echo "Building Docker image..."
	docker build -t $(DOCKER_IMAGE) .

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -rf $(PROTO_GEN_DIR) $(OPENAPI_GEN_DIR) $(ARTIFACT_DIR)

# Create the necessary folder structure for generated code and artifacts
create_structure:
	@echo "Creating folder structure for generated files and artifacts..."
	mkdir -p $(PROTO_GEN_DIR)
	mkdir -p $(OPENAPI_GEN_DIR)
	mkdir -p $(ARTIFACT_DIR)

# Install example Protobuf file
# install_protobuf_example:
# 	@echo "Installing example Protobuf file..."
# 	mkdir -p $(PROTO_DIR)
# 	curl -L $(EXAMPLE_PROTO_URL) -o $(PROTO_DIR)/addressbook.proto

# Compile Protobuf to gRPC stubs using Docker
proto:
	@echo "Compiling Protobuf files to gRPC stubs inside Docker..."
	$(DOCKER_RUN) bash -c "protoc \
		--js_out=import_style=commonjs,binary:$(PROTO_GEN_DIR) \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:$(PROTO_GEN_DIR) \
		--proto_path=$(PROTO_DIR) \
		$(PROTO_DIR)/*.proto"

# Generate OpenAPI specification from Protobuf using Docker
openapi:
	@echo "Generating OpenAPI specs from Protobuf files inside Docker..."
	$(DOCKER_RUN) bash -c "protoc \
		--openapi_out=shared/openapi \
		--proto_path=shared/proto \
		--proto_path=/usr/include \
		shared/proto/*.proto"
	@echo "Listing contents of shared/openapi after generation:"
	@ls -l $(OPENAPI_GEN_DIR)

# Sync OpenAPI and generate TypeScript clients using Docker
sync:
	@echo "Generating OpenAPI clients from specs inside Docker..."
	$(DOCKER_RUN) bash -c "openapi-generator-cli generate \
		-i $(OPENAPI_GEN_DIR)/openapi.yaml \
		-g typescript-fetch \
		-o $(PROTO_GEN_DIR)/addressbook-client"

# Copy OpenAPI spec to the artifact directory
artifact:
	@echo "Copying OpenAPI spec to the artifact directory..."
	cp $(OPENAPI_GEN_DIR)/openapi.yaml $(ARTIFACT_DIR)/addressbook-openapi.yaml
	@echo "Artifact saved at $(ARTIFACT_DIR)/addressbook-openapi.yaml"

# Full build: Clean, build Docker image, create structure, generate stubs, OpenAPI, sync, and save artifact
all: clean build_docker_image create_structure proto openapi sync artifact
	@echo "All steps completed successfully."

# Run the Docker container interactively
run_docker:
	@echo "Running Docker container interactively..."
	$(DOCKER_RUN) bash

# Example of running everything together
run: all
	@echo "Build complete."
