#!/bin/bash

# Optimized Deploy Script for Ubuntu
# This script builds, deploys and cleans up Docker images efficiently

set -e  # Exit on any error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
IMAGE_NAME="test_working_w_go-app"
CONTAINER_NAME="first-app"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Go Backend - Optimized Docker Deploy${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[ERROR] Docker is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] Docker is available${NC}"

# Check .env file
if [ ! -f .env ]; then
    echo -e "${YELLOW}[WARNING] .env file not found${NC}"
    echo "Creating .env from .env.example..."
    cp .env.example .env
    echo ""
    echo -e "${YELLOW}Please configure .env and run again${NC}"
    exit 0
fi

echo -e "${GREEN}[OK] .env file found${NC}"
echo ""

# Determine docker compose command
COMPOSE_CMD=""
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    echo -e "${RED}[ERROR] Docker Compose not available${NC}"
    exit 1
fi

echo -e "${GREEN}[OK] Using: $COMPOSE_CMD${NC}"
echo ""

# Step 1: Stop and remove existing services
echo -e "${BLUE}[1/5] Stopping existing services...${NC}"
$COMPOSE_CMD down 2>/dev/null || true
echo -e "${GREEN}✓ Services stopped${NC}"
echo ""

# Step 2: Remove old images
echo -e "${BLUE}[2/5] Removing old images...${NC}"
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}"; then
    docker rmi ${IMAGE_NAME}:latest 2>/dev/null || true
    echo -e "${GREEN}✓ Old images removed${NC}"
else
    echo -e "${YELLOW}  No existing images found${NC}"
fi
echo ""

# Step 3: Build and start with docker-compose
echo -e "${BLUE}[3/5] Building and starting with docker compose...${NC}"

# Build and start with docker-compose (uses docker-compose.yml configuration)
$COMPOSE_CMD up -d --build --force-recreate

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Container built and started successfully${NC}"

    # Wait a moment for the container to initialize
    sleep 3

    # Check if container is running
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${GREEN}✓ Container is running${NC}"

        # Show image size
        IMAGE_SIZE=$(docker images ${IMAGE_NAME}:latest --format "{{.Size}}")
        echo -e "${GREEN}✓ Image size: ${IMAGE_SIZE}${NC}"
    else
        echo -e "${RED}✗ Container stopped unexpectedly${NC}"
        echo ""
        echo "Container logs:"
        docker logs ${CONTAINER_NAME}
        exit 1
    fi
else
    echo -e "${RED}✗ Failed to build/start container${NC}"
    exit 1
fi
echo ""

# Step 5: Clean up unused images
echo -e "${BLUE}[5/5] Cleaning up unused Docker images...${NC}"
docker image prune -f > /dev/null 2>&1

# Also remove dangling images
DANGLING=$(docker images -f "dangling=true" -q 2>/dev/null | wc -l)
if [ "$DANGLING" -gt 0 ]; then
    docker rmi $(docker images -f "dangling=true" -q) 2>/dev/null || true
    echo -e "${GREEN}✓ Removed $DANGLING dangling image(s)${NC}"
else
    echo -e "${GREEN}✓ No dangling images to remove${NC}"
fi
echo ""

# Show final status
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  Deployment Completed Successfully!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${BLUE}Container Status:${NC}"
docker ps --filter name=${CONTAINER_NAME} --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo -e "${BLUE}Application Info:${NC}"
SERVER_PORT=$(grep SERVER_PORT .env | cut -d '=' -f2)
SERVER_PORT=${SERVER_PORT:-1323}
echo "  URL: http://localhost:${SERVER_PORT}"
echo ""

echo -e "${BLUE}Useful Commands:${NC}"
echo "  View logs:       $COMPOSE_CMD logs -f"
echo "  Stop:            $COMPOSE_CMD down"
echo "  Restart:         $COMPOSE_CMD restart"
echo "  Shell access:    docker exec -it ${CONTAINER_NAME} sh"
echo "  View ports:      docker ps --format 'table {{.Names}}\t{{.Ports}}'"
echo ""

# Test the application
echo -e "${BLUE}Testing application...${NC}"
sleep 1
if curl -s http://localhost:${SERVER_PORT}/ > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Application is responding!${NC}"
else
    echo -e "${YELLOW}⚠ Application might still be starting up${NC}"
    echo "  Check logs with: docker logs -f ${CONTAINER_NAME}"
fi
echo ""

# Show disk usage
echo -e "${BLUE}Docker Disk Usage:${NC}"
docker system df
echo ""

echo -e "${GREEN}Done! Your application is running.${NC}"
