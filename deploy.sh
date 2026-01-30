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

# Step 1: Stop and remove existing container
echo -e "${BLUE}[1/5] Stopping and removing old container...${NC}"
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    docker stop ${CONTAINER_NAME} 2>/dev/null || true
    docker rm ${CONTAINER_NAME} 2>/dev/null || true
    echo -e "${GREEN}✓ Old container removed${NC}"
else
    echo -e "${YELLOW}  No existing container found${NC}"
fi
echo ""

# Step 2: Remove old image
echo -e "${BLUE}[2/5] Removing old image...${NC}"
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}"; then
    OLD_IMAGE_ID=$(docker images --format '{{.ID}}' ${IMAGE_NAME}:latest 2>/dev/null || echo "")
    if [ ! -z "$OLD_IMAGE_ID" ]; then
        docker rmi ${IMAGE_NAME}:latest 2>/dev/null || true
        echo -e "${GREEN}✓ Old image removed${NC}"
    fi
else
    echo -e "${YELLOW}  No existing image found${NC}"
fi
echo ""

# Step 3: Build new image
echo -e "${BLUE}[3/5] Building new Docker image...${NC}"
docker build -t ${IMAGE_NAME}:latest . --no-cache

if [ $? -eq 0 ]; then
    # Get image size
    IMAGE_SIZE=$(docker images ${IMAGE_NAME}:latest --format "{{.Size}}")
    echo -e "${GREEN}✓ Image built successfully (Size: ${IMAGE_SIZE})${NC}"
else
    echo -e "${RED}✗ Image build failed${NC}"
    exit 1
fi
echo ""

# Step 4: Start the container
echo -e "${BLUE}[4/5] Starting container...${NC}"
docker run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    --network host \
    --env-file .env \
    ${IMAGE_NAME}:latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Container started successfully${NC}"

    # Wait a moment for the container to initialize
    sleep 2

    # Check if container is running
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${GREEN}✓ Container is running${NC}"
    else
        echo -e "${RED}✗ Container stopped unexpectedly${NC}"
        echo ""
        echo "Container logs:"
        docker logs ${CONTAINER_NAME}
        exit 1
    fi
else
    echo -e "${RED}✗ Failed to start container${NC}"
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
echo "  View logs:       docker logs -f ${CONTAINER_NAME}"
echo "  Stop:            docker stop ${CONTAINER_NAME}"
echo "  Restart:         docker restart ${CONTAINER_NAME}"
echo "  Shell access:    docker exec -it ${CONTAINER_NAME} sh"
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
