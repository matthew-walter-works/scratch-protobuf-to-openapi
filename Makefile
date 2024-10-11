# Variables
DOCKER_IMAGE = grpc-openapi-builder
CONTAINER_WORKDIR = /usr/src/app
PROTO_DIR = shared/proto
PROTO_GEN_DIR = shared/gen
OPENAPI_GEN_DIR = shared/openapi

# Docker-related commands
DOCKER_RUN = docker run -v $(PWD):$(CONTAINER_WORKDIR) --rm $(DOCKER_IMAGE)

# Rules
.PHONY: all clean proto openapi sync build_docker_image run_docker

# Build the Docker image
build_docker_image:
	@echo "Building Docker image..."
	docker build -t $(DOCKER_IMAGE) .

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -rf $(PROTO_GEN_DIR) $(OPENAPI_GEN_DIR)

# Create the necessary folder structure for generated code
create_structure:
	@echo "Creating folder structure for generated files..."
	mkdir -p $(PROTO_GEN_DIR)
	mkdir -p $(OPENAPI_GEN_DIR)

# Compile Protobuf to gRPC stubs using Docker for all .proto files
proto:
	@echo "Compiling Protobuf files to gRPC stubs inside Docker..."
	for proto_file in $(PROTO_DIR)/*.proto; do \
		$(DOCKER_RUN) bash -c "protoc \
			--js_out=import_style=commonjs,binary:$(PROTO_GEN_DIR) \
			--grpc-web_out=import_style=commonjs,mode=grpcwebtext:$(PROTO_GEN_DIR) \
			--proto_path=$(PROTO_DIR) \
			$$proto_file"; \
	done

# Generate OpenAPI specification for each .proto file
openapi:
	@echo "Generating OpenAPI specs from Protobuf files inside Docker..."
	for proto_file in $(PROTO_DIR)/*.proto; do \
		base_name=$$(basename $$proto_file .proto); \
		$(DOCKER_RUN) bash -c "protoc \
			--openapi_out=$(OPENAPI_GEN_DIR) \
			--proto_path=$(PROTO_DIR) \
			--proto_path=/usr/include \
			$$proto_file"; \
		mv $(OPENAPI_GEN_DIR)/openapi.yaml $(OPENAPI_GEN_DIR)/$$base_name.openapi.yaml; \
	done
	@echo "Listing contents of shared/openapi after generation:"
	@ls -l $(OPENAPI_GEN_DIR)

# Sync: Generate TypeScript clients for each OpenAPI spec
sync:
	@echo "Generating OpenAPI clients from specs inside Docker..."
	for openapi_file in $(OPENAPI_GEN_DIR)/*.openapi.yaml; do \
		base_name=$$(basename $$openapi_file .openapi.yaml); \
		$(DOCKER_RUN) bash -c "openapi-generator-cli generate \
			-i $$openapi_file \
			-g typescript-fetch \
			-o $(PROTO_GEN_DIR)/$$base_name-client"; \
	done

# Full build: Clean, build Docker image, create structure, generate stubs, OpenAPI, and sync
all: clean build_docker_image create_structure proto openapi sync
	@echo "All steps completed successfully."

# Run the Docker container interactively
run_docker:
	@echo "Running Docker container interactively..."
	$(DOCKER_RUN) bash

# Example of running everything together
run: all
	@echo "Build complete."
