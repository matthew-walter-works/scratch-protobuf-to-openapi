# Variables
DOCKER_IMAGE_OPENAPI = openapi-generator# Docker image name for OpenAPI
DOCKER_IMAGE_GRPC = grpc-generator# Docker image name for gRPC
CONTAINER_WORKDIR = /usr/src/app# Container working directory
PROTO_DIR = shared/proto# Directory containing proto files
OPENAPI_GEN_DIR = gen/openapi# Path for OpenAPI spec generation
SERVER_REST_GEN_DIR = gen/server/rest# Path for REST API generation
SERVER_GRPC_GEN_DIR = gen/server/grpc# Path for gRPC server generation
CLIENTS_GEN_DIR = gen/clients# Path for clients generation
CLIENTS_TS_GEN_DIR = $(CLIENTS_GEN_DIR)/typescript# Path for TypeScript client generation
CLIENTS_GRPC_GEN_DIR = $(CLIENTS_GEN_DIR)/grpc# Path for gRPC client generation

# Docker-related commands
DOCKER_RUN_OPENAPI = docker run -v $(PWD):$(CONTAINER_WORKDIR) --rm $(DOCKER_IMAGE_OPENAPI)
DOCKER_RUN_GRPC = docker run -v $(PWD):$(CONTAINER_WORKDIR) --rm $(DOCKER_IMAGE_GRPC)

# Print variable values for debugging
print-vars:
	@echo "Docker Image for OpenAPI: $(DOCKER_IMAGE_OPENAPI)"
	@echo "Docker Image for gRPC: $(DOCKER_IMAGE_GRPC)"
	@echo "Container Workdir: $(CONTAINER_WORKDIR)"
	@echo "Proto Directory: $(PROTO_DIR)"
	@echo "OpenAPI Generation Directory: $(OPENAPI_GEN_DIR)"
	@echo "REST API Generation Directory: $(SERVER_REST_GEN_DIR)"
	@echo "gRPC Server Generation Directory: $(SERVER_GRPC_GEN_DIR)"
	@echo "Clients Generation Directory: $(CLIENTS_GEN_DIR)"
	@echo "TypeScript Clients Generation Directory: $(CLIENTS_TS_GEN_DIR)"
	@echo "gRPC Clients Generation Directory: $(CLIENTS_GRPC_GEN_DIR)"

# Build Docker images
build_docker_images:
	@echo "Building Docker image for OpenAPI and REST API generation..."
	docker build -t $(DOCKER_IMAGE_OPENAPI) -f docker/Dockerfile.openapi .
	@echo "Building Docker image for gRPC client generation..."
	docker build -t $(DOCKER_IMAGE_GRPC) -f docker/Dockerfile.grpc .

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -rf $(OPENAPI_GEN_DIR) $(SERVER_REST_GEN_DIR) $(SERVER_GRPC_GEN_DIR) $(CLIENTS_GEN_DIR)

# Create necessary folder structure
create_structure:
	@echo "Creating folder structure for generated files..."
	mkdir -p $(OPENAPI_GEN_DIR)
	mkdir -p $(SERVER_REST_GEN_DIR)
	mkdir -p $(SERVER_GRPC_GEN_DIR)
	mkdir -p $(CLIENTS_TS_GEN_DIR)
	mkdir -p $(CLIENTS_GRPC_GEN_DIR)

# Generate OpenAPI specs from Protobuf files
openapi: create_structure
	@echo "Generating OpenAPI specs from Protobuf files inside Docker..."
	@PROTO_FILES=$(PROTO_DIR)/*.proto; \
	for f in $$PROTO_FILES; do \
		base_name=$$(basename $$f .proto); \
		$(DOCKER_RUN_OPENAPI) bash -c "protoc \
			--proto_path=$(PROTO_DIR) \
			--proto_path=/usr/include/google/api \
			--openapi_out=$(OPENAPI_GEN_DIR) \
			$$f && \
			mv $(OPENAPI_GEN_DIR)/openapi.yaml $(OPENAPI_GEN_DIR)/$$base_name.yaml && \
			echo 'OpenAPI spec for $$base_name generated at:' && ls -la $(OPENAPI_GEN_DIR)/$$base_name.yaml"; \
	done

# Generate Python REST API server from OpenAPI specs
api-rest: create_structure
	@echo "Generating Python REST API server from OpenAPI specs..."
	@OPENAPI_FILES=$(OPENAPI_GEN_DIR)/*.yaml; \
	for f in $$OPENAPI_FILES; do \
		base_name=$$(basename $$f .yaml); \
		if [ -f "$$f" ]; then \
			echo "Processing $$f for $$base_name"; \
			$(DOCKER_RUN_OPENAPI) bash -c "openapi-generator-cli generate \
				-i '$$f' \
				-g python-flask \
				-o '$(SERVER_REST_GEN_DIR)/$$base_name-server'"; \
		else \
			echo "No OpenAPI file found: $$f"; \
		fi; \
	done

# Generate gRPC Python server from Protobuf files
server-grpc: create_structure
	@echo "Generating gRPC Python server from Protobuf files..."
	@PROTO_FILES=$(PROTO_DIR)/*.proto; \
	for f in $$PROTO_FILES; do \
		base_name=$$(basename $$f .proto); \
		echo "Processing $$f for gRPC Python server"; \
		mkdir -p "$(SERVER_GRPC_GEN_DIR)/$$base_name"; \
		echo "Creating directory for gRPC Python server: $(SERVER_GRPC_GEN_DIR)/$$base_name"; \
		$(DOCKER_RUN_GRPC) bash -c "python -m grpc_tools.protoc \
			-I$(PROTO_DIR) \
			-I/usr/include/google/api \
			--python_out=$(SERVER_GRPC_GEN_DIR)/$$base_name \
			--grpc_python_out=$(SERVER_GRPC_GEN_DIR)/$$base_name \
			$$f"; \
		echo "gRPC Python server generated in: $(SERVER_GRPC_GEN_DIR)/$$base_name"; \
	done

# Generate TypeScript clients from OpenAPI specs
client-typescript: create_structure
	@echo "Generating TypeScript clients from OpenAPI specs..."
	@OPENAPI_FILES=$(OPENAPI_GEN_DIR)/*.yaml; \
	for f in $$OPENAPI_FILES; do \
		base_name=$$(basename $$f .yaml); \
		if [ -f "$$f" ]; then \
			echo "Processing $$f for $$base_name"; \
			$(DOCKER_RUN_OPENAPI) bash -c "openapi-generator-cli generate \
				-i '$$f' \
				-g typescript-fetch \
				-o '$(CLIENTS_TS_GEN_DIR)/$$base_name'"; \
		else \
			echo "No OpenAPI file found: $$f"; \
		fi; \
	done

# Generate gRPC clients from Protobuf files
client-grpc: create_structure
	@echo "Generating gRPC clients from Protobuf files..."
	@PROTO_FILES=$(PROTO_DIR)/*.proto; \
	for f in $$PROTO_FILES; do \
		base_name=$$(basename $$f .proto); \
		echo "Processing $$f for gRPC Python client"; \
		mkdir -p "$(CLIENTS_GRPC_GEN_DIR)/$$base_name"; \
		echo "Creating directory for gRPC Python client: $(CLIENTS_GRPC_GEN_DIR)/$$base_name"; \
		$(DOCKER_RUN_GRPC) bash -c "python -m grpc_tools.protoc \
			-I=$(PROTO_DIR) \
			-I/usr/include/google/api \
			--python_out=$(CLIENTS_GRPC_GEN_DIR)/$$base_name \
			--grpc_python_out=$(CLIENTS_GRPC_GEN_DIR)/$$base_name \
			$$f"; \
		echo "gRPC Python client generated in: $(CLIENTS_GRPC_GEN_DIR)/$$base_name"; \
	done

# Full build: Clean, build Docker images, create structure, and generate specs and server API
all: clean build_docker_images openapi api-rest client-typescript client-grpc server-grpc
	@echo "All steps completed successfully."

# Run this as the first target to display variable values
.DEFAULT_GOAL := print-vars
