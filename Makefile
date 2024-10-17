# Variables
DOCKER_IMAGE_OPENAPI = openapi-generator
CONTAINER_WORKDIR = /usr/src/app
PROTO_DIR = shared/proto
OPENAPI_GEN_DIR = gen/openapi    # Path for OpenAPI spec generation
REST_API_GEN_DIR = gen/rest_api  # Path for REST API generation

# Docker-related commands
DOCKER_RUN_OPENAPI = docker run -v $(PWD):$(CONTAINER_WORKDIR) --rm $(DOCKER_IMAGE_OPENAPI)

# Build Docker image
build_docker_images:
	@echo "Building Docker image for OpenAPI and REST API generation..."
	docker build -t $(DOCKER_IMAGE_OPENAPI) -f docker/Dockerfile.openapi .

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -rf $(OPENAPI_GEN_DIR) $(REST_API_GEN_DIR)

# Create necessary folder structure
create_structure:
	@echo "Creating folder structure for generated files..."
	mkdir -p $(OPENAPI_GEN_DIR)
	mkdir -p $(REST_API_GEN_DIR)

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
	$(DOCKER_RUN_OPENAPI) bash -c "ls -la $(OPENAPI_GEN_DIR) && cat $(OPENAPI_GEN_DIR)/openapi.yaml || echo 'openapi.yaml not found'"

# Generate Python REST API from a single OpenAPI spec
rest-api: create_structure
	@echo "Generating Python REST API from openapi.yaml..."
	$(DOCKER_RUN_OPENAPI) bash -c 'if [ -f "$(OPENAPI_GEN_DIR)/openapi.yaml" ]; then \
		echo "Processing $(OPENAPI_GEN_DIR)/openapi.yaml"; \
		openapi-python-client generate \
			--path "$(OPENAPI_GEN_DIR)/openapi.yaml" \
			--output-path "$(REST_API_GEN_DIR)/openapi-client"; \
	else \
		echo "No openapi.yaml found in $(OPENAPI_GEN_DIR)"; \
	fi'

# Full build: Clean, build Docker images, create structure, and generate specs and API
all: clean build_docker_images openapi rest-api
	@echo "All steps completed successfully."
