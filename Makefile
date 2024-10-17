# Variables
DOCKER_IMAGE_OPENAPI = openapi-generator# Docker image name
CONTAINER_WORKDIR = /usr/src/app# Container working directory
PROTO_DIR = shared/proto# Directory containing proto files
OPENAPI_GEN_DIR = gen/openapi# Path for OpenAPI spec generation
REST_API_GEN_DIR = gen/rest_api# Path for REST API generation
CLIENTS_GEN_DIR = gen/clients# Path for TypeScript client generation

# Docker-related commands
DOCKER_RUN_OPENAPI = docker run -v $(PWD):$(CONTAINER_WORKDIR) --rm $(DOCKER_IMAGE_OPENAPI)

# Print variable values for debugging
print-vars:
	@echo "Docker Image: $(DOCKER_IMAGE_OPENAPI)"
	@echo "Container Workdir: $(CONTAINER_WORKDIR)"
	@echo "Proto Directory: $(PROTO_DIR)"
	@echo "OpenAPI Generation Directory: $(OPENAPI_GEN_DIR)"
	@echo "REST API Generation Directory: $(REST_API_GEN_DIR)"
	@echo "Clients Generation Directory: $(CLIENTS_GEN_DIR)"

# Build Docker image
build_docker_images:
	@echo "Building Docker image for OpenAPI and REST API generation..."
	docker build -t $(DOCKER_IMAGE_OPENAPI) -f docker/Dockerfile.openapi .

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -rf $(OPENAPI_GEN_DIR) $(REST_API_GEN_DIR) $(CLIENTS_GEN_DIR)

# Create necessary folder structure
create_structure:
	@echo "Creating folder structure for generated files..."
	mkdir -p $(OPENAPI_GEN_DIR)
	mkdir -p $(REST_API_GEN_DIR)
	mkdir -p $(CLIENTS_GEN_DIR)

# Generate OpenAPI specs from Protobuf files
openapi: create_structure
	@echo "Generating OpenAPI specs from Protobuf files inside Docker..."
	$(DOCKER_RUN_OPENAPI) bash -c "protoc \
		--proto_path=$(PROTO_DIR) \
		--proto_path=/usr/include/google/api \
		--openapi_out=$(OPENAPI_GEN_DIR) \
		$(PROTO_DIR)/*.proto && \
		echo 'OpenAPI specs generated at:' && cd $(OPENAPI_GEN_DIR) && pwd && ls -la"

# Debugging Step: List contents of gen/openapi inside Docker
debug-openapi:
	@echo "Listing contents of gen/openapi inside Docker..."
	@echo "Contents of OPENAPI_GEN_DIR is $(OPENAPI_GEN_DIR)"
	$(DOCKER_RUN_OPENAPI) bash -c "ls -la $(OPENAPI_GEN_DIR) && cat $(OPENAPI_GEN_DIR)/openapi.yaml || echo 'openapi.yaml not found'"

# Generate Python REST API server from OpenAPI spec
rest-api: create_structure
	@echo "Generating Python REST API server from OpenAPI specs..."
	@OPENAPI_FILE=$(OPENAPI_GEN_DIR)/openapi.yaml; \
	if [ -f "$$OPENAPI_FILE" ]; then \
		echo "Processing $$OPENAPI_FILE"; \
		$(DOCKER_RUN_OPENAPI) bash -c "openapi-generator-cli generate \
			-i '$$OPENAPI_FILE' \
			-g python-flask \
			-o '$(REST_API_GEN_DIR)/flask-server'"; \
	else \
		echo "No openapi.yaml found in $(OPENAPI_GEN_DIR)"; \
		echo "Looking for: $$OPENAPI_FILE"; \
	fi

# Generate TypeScript clients from OpenAPI spec
typescript-clients: create_structure
	@echo "Generating TypeScript clients from OpenAPI specs..."
	@OPENAPI_FILE=$(OPENAPI_GEN_DIR)/openapi.yaml; \
	if [ -f "$$OPENAPI_FILE" ]; then \
		echo "Processing $$OPENAPI_FILE"; \
		$(DOCKER_RUN_OPENAPI) bash -c "openapi-generator-cli generate \
			-i '$$OPENAPI_FILE' \
			-g typescript-fetch \
			-o '$(CLIENTS_GEN_DIR)/$(basename $$OPENAPI_FILE)'"; \
	else \
		echo "No openapi.yaml found in $(OPENAPI_GEN_DIR)"; \
		echo "Looking for: $$OPENAPI_FILE"; \
	fi

# Full build: Clean, build Docker images, create structure, and generate specs and server API
all: clean build_docker_images openapi rest-api typescript-clients
	@echo "All steps completed successfully."

# Run this as the first target to display variable values
.DEFAULT_GOAL := print-vars
