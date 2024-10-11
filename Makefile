# Paths
PROTO_DIR = shared/proto
PROTO_GEN_DIR = shared/gen
OPENAPI_GEN_DIR = shared/openapi

# Tools
PROTOC = protoc
PROTOC_OPENAPI_PLUGIN = protoc-gen-openapi
OPENAPI_GENERATOR = openapi-generator-cli
NPM = npm

# Example Protobuf source (replace this with actual URL or GitHub repo raw URLs)
PROTO_EXAMPLES_URL = https://raw.githubusercontent.com/protocolbuffers/protobuf/refs/heads/main/examples/addressbook.proto
EXAMPLE_PROTO_FILES = addressbook.proto

# Proto and OpenAPI targets
PROTO_FILES = $(shell find $(PROTO_DIR) -name '*.proto')
PROTO_GEN_FILES = $(patsubst $(PROTO_DIR)/%.proto, $(PROTO_GEN_DIR)/%.js, $(PROTO_FILES))
OPENAPI_SPEC_FILES = $(patsubst $(PROTO_DIR)/%.proto, $(OPENAPI_GEN_DIR)/%.yaml, $(PROTO_FILES))

# Rules
.PHONY: all clean proto openapi sync install_deps create_structure install_protobuf_examples

# Default target
all: install_deps create_structure proto openapi sync

# Clean up generated files
clean:
	rm -rf $(PROTO_GEN_DIR) $(OPENAPI_GEN_DIR)

# Create folder structure for generated code
create_structure:
	@echo "Creating folder structure..."
	@mkdir -p $(PROTO_GEN_DIR)
	@mkdir -p $(OPENAPI_GEN_DIR)

# Install necessary dependencies
install_deps:
	@echo "Installing dependencies..."
	# Install protobuf and protoc-gen-openapi (ensure protoc is available)
	if ! command -v $(PROTOC) &> /dev/null; then \
		echo "protoc not found, installing protobuf..."; \
		brew install protobuf; \
	fi

	# Install protoc-gen-openapi (for generating OpenAPI from proto files)
	if ! command -v $(PROTOC_OPENAPI_PLUGIN) &> /dev/null; then \
		echo "protoc-gen-openapi not found, installing protoc-gen-openapi..."; \
		go install github.com/google/gnostic/cmd/protoc-gen-openapi@latest; \
		export PATH=$$PATH:$$GOPATH/bin; \
	fi

	# Install openapi-generator-cli (for generating client code)
	if ! command -v $(OPENAPI_GENERATOR) &> /dev/null; then \
		echo "openapi-generator-cli not found, installing openapi-generator-cli..."; \
		npm install -g @openapitools/openapi-generator-cli; \
	fi

# Install example .proto files
install_protobuf_examples:
	@echo "Installing example Protobuf files..."
	@mkdir -p $(PROTO_DIR)
	$(foreach proto,$(EXAMPLE_PROTO_FILES), \
		curl -L $(PROTO_EXAMPLES_URL)/$(proto) -o $(PROTO_DIR)/$(proto); \
		echo "Downloaded $(proto)"; \
	)

# Compile Protobuf to gRPC stubs (JavaScript/TypeScript in this example)
proto: $(PROTO_GEN_FILES)

$(PROTO_GEN_DIR)/%.js: $(PROTO_DIR)/%.proto
	@echo "Compiling $< to gRPC JavaScript stubs..."
	@$(PROTOC) \
		--js_out=import_style=commonjs,binary:$(PROTO_GEN_DIR) \
		--grpc_out=grpc_js:$(PROTO_GEN_DIR) \
		--proto_path=$(PROTO_DIR) \
		$<

# Generate OpenAPI specification from Protobuf
openapi: $(OPENAPI_SPEC_FILES)

$(OPENAPI_GEN_DIR)/%.yaml: $(PROTO_DIR)/%.proto
	@echo "Generating OpenAPI spec from $<..."
	@$(PROTOC) \
		--openapi_out=$(OPENAPI_GEN_DIR) \
		--proto_path=$(PROTO_DIR) \
		$<

# Sync Protobuf and OpenAPI specifications with code generators (e.g., TypeScript clients)
sync:
	@echo "Generating OpenAPI clients from specs..."
	$(foreach spec,$(wildcard $(OPENAPI_GEN_DIR)/*.yaml), \
		$(OPENAPI_GENERATOR) generate \
		-i $(spec) \
		-g typescript-fetch \
		-o $(PROTO_GEN_DIR)/$(notdir $(basename $(spec)))-client; \
	)

# Example of running everything together
run: clean all
	@echo "Build complete."
