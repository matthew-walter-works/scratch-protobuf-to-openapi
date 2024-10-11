# Use an official Node.js runtime as a base image
FROM node:16-bullseye-slim

# Install basic build tools and Java
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    unzip \
    wget \
    golang-go \
    protobuf-compiler \
    default-jre \
    && rm -rf /var/lib/apt/lists/*

# Ensure Go binaries are in the PATH
ENV PATH=$PATH:/root/go/bin

# Clone and install protoc-gen-openapi from source
RUN git clone https://github.com/google/gnostic.git /tmp/gnostic \
    && cd /tmp/gnostic \
    && go build ./cmd/protoc-gen-openapi \
    && mv protoc-gen-openapi /usr/local/bin/ \
    && rm -rf /tmp/gnostic

# Install protoc-gen-grpc-web plugin
RUN wget https://github.com/grpc/grpc-web/releases/download/1.4.2/protoc-gen-grpc-web-1.4.2-linux-x86_64 \
    -O /usr/local/bin/protoc-gen-grpc-web \
    && chmod +x /usr/local/bin/protoc-gen-grpc-web

# Download google/api/annotations.proto and http.proto for HTTP mapping
RUN mkdir -p /usr/include/google/api && \
    wget https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/annotations.proto -O /usr/include/google/api/annotations.proto && \
    wget https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/http.proto -O /usr/include/google/api/http.proto

# Verify protoc installation
RUN protoc --version

# Verify protoc-gen-grpc-web installation
RUN protoc-gen-grpc-web --version

# Install openapi-generator-cli globally using npm
RUN npm install -g @openapitools/openapi-generator-cli

# Create a working directory
WORKDIR /usr/src/app

# Copy the project files into the container
COPY . .

# Install any project-specific dependencies
RUN yarn install

# Create folders for the generated code
RUN mkdir -p shared/gen shared/openapi

# Entry point for the Docker container
CMD ["bash"]
