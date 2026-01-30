#!/bin/bash

# Build script for Go Backend
# This script installs dependencies and compiles the Go application

set -e  # Exit on any error

echo "================================================"
echo "  Go Backend Build Script"
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo -e "${RED}Error: Go is not installed. Please install Go first.${NC}"
    echo "Visit: https://golang.org/doc/install"
    exit 1
fi

echo -e "${GREEN}✓ Go version:${NC} $(go version)"
echo ""

# Download dependencies
echo -e "${YELLOW}→ Downloading Go dependencies...${NC}"
go mod download
echo -e "${GREEN}✓ Dependencies downloaded${NC}"
echo ""

# Verify dependencies
echo -e "${YELLOW}→ Verifying dependencies...${NC}"
go mod verify
echo -e "${GREEN}✓ Dependencies verified${NC}"
echo ""

# Tidy up go.mod and go.sum
echo -e "${YELLOW}→ Tidying up dependencies...${NC}"
go mod tidy
echo -e "${GREEN}✓ Dependencies tidied${NC}"
echo ""

# Run tests (optional, comment out if you don't have tests yet)
# echo -e "${YELLOW}→ Running tests...${NC}"
# go test ./... -v
# echo -e "${GREEN}✓ Tests passed${NC}"
# echo ""

# Build the application
echo -e "${YELLOW}→ Building application for Linux/Ubuntu...${NC}"
OUTPUT_BINARY="./bin/server"

# Create bin directory if it doesn't exist
mkdir -p ./bin

# Build with optimizations for Linux (Ubuntu)
# GOOS=linux ensures the binary will run on Ubuntu servers
GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o ${OUTPUT_BINARY} server.go

if [ -f "${OUTPUT_BINARY}" ]; then
    echo -e "${GREEN}✓ Build successful!${NC}"
    echo -e "${GREEN}  Binary created at: ${OUTPUT_BINARY}${NC}"

    # Make binary executable
    chmod +x ${OUTPUT_BINARY}

    # Show binary size
    SIZE=$(du -h ${OUTPUT_BINARY} | cut -f1)
    echo -e "${GREEN}  Binary size: ${SIZE}${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

echo ""
echo "================================================"
echo -e "${GREEN}  Build completed successfully!${NC}"
echo "================================================"
echo ""
echo "To run the application:"
echo "  ${OUTPUT_BINARY}"
echo ""
echo "Or with environment variables:"
echo "  SERVER_PORT=8080 ${OUTPUT_BINARY}"
