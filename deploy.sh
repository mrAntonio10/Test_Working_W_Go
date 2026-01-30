#!/bin/bash

# Deploy script for Ubuntu/Linux
# This script manages Docker deployment of the Go backend

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script banner
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Go Backend - Docker Deployment (Ubuntu)${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[ERROR] Docker is not installed.${NC}"
    echo "Install Docker with:"
    echo "  curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "  sudo sh get-docker.sh"
    echo "  sudo usermod -aG docker \$USER"
    exit 1
fi

echo -e "${GREEN}[OK] Docker is installed${NC}"

# Check if docker-compose is available
COMPOSE_CMD=""
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    echo -e "${RED}[ERROR] Docker Compose is not available.${NC}"
    echo "Install Docker Compose with:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install docker-compose-plugin"
    exit 1
fi

echo -e "${GREEN}[OK] Docker Compose is available (using: $COMPOSE_CMD)${NC}"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}[WARNING] .env file not found${NC}"
    echo -e "${YELLOW}Creating .env from .env.example...${NC}"
    cp .env.example .env
    echo ""
    echo -e "${YELLOW}================================================${NC}"
    echo -e "${YELLOW}  IMPORTANT: Configure your .env file!${NC}"
    echo -e "${YELLOW}================================================${NC}"
    echo ""
    echo "Edit .env with your database credentials:"
    echo "  nano .env"
    echo "  # or"
    echo "  vim .env"
    echo ""
    echo "Then run this script again."
    exit 0
fi

echo -e "${GREEN}[OK] .env file found${NC}"
echo ""

# Show menu
show_menu() {
    echo -e "${BLUE}Select an option:${NC}"
    echo ""
    echo "  ${GREEN}1${NC}. Deploy services (docker-compose up)"
    echo "  ${GREEN}2${NC}. Stop services"
    echo "  ${GREEN}3${NC}. View logs"
    echo "  ${GREEN}4${NC}. Rebuild and deploy"
    echo "  ${GREEN}5${NC}. Service status"
    echo "  ${GREEN}6${NC}. Database backup"
    echo "  ${GREEN}7${NC}. Database restore"
    echo "  ${GREEN}8${NC}. Clean all (WARNING: deletes data)"
    echo "  ${GREEN}9${NC}. Build locally (without Docker)"
    echo "  ${YELLOW}0${NC}. Exit"
    echo ""
}

# Deploy function
deploy() {
    echo -e "${BLUE}[INFO] Deploying services...${NC}"
    $COMPOSE_CMD up -d

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}================================================${NC}"
        echo -e "${GREEN}  Services deployed successfully!${NC}"
        echo -e "${GREEN}================================================${NC}"
        echo ""
        echo "Application URL: http://localhost:1323"
        echo ""
        echo "View logs with:"
        echo "  $COMPOSE_CMD logs -f"
        echo ""
    else
        echo -e "${RED}[ERROR] Deployment failed${NC}"
        exit 1
    fi
}

# Stop function
stop_services() {
    echo -e "${BLUE}[INFO] Stopping services...${NC}"
    $COMPOSE_CMD down

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS] Services stopped${NC}"
    fi
}

# Logs function
view_logs() {
    echo -e "${BLUE}[INFO] Showing logs (Ctrl+C to exit)...${NC}"
    echo ""
    $COMPOSE_CMD logs -f
}

# Rebuild function
rebuild() {
    echo -e "${BLUE}[INFO] Rebuilding and deploying services...${NC}"
    $COMPOSE_CMD up -d --build

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}[SUCCESS] Services rebuilt and deployed!${NC}"
        echo ""
        echo "Application URL: http://localhost:1323"
    fi
}

# Status function
show_status() {
    echo -e "${BLUE}[INFO] Service status:${NC}"
    echo ""
    $COMPOSE_CMD ps
    echo ""
    echo -e "${BLUE}[INFO] Container stats:${NC}"
    echo ""
    docker stats --no-stream
}

# Backup function
backup_database() {
    echo -e "${BLUE}[INFO] Creating database backup...${NC}"

    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="backup_${TIMESTAMP}.sql"

    $COMPOSE_CMD exec -T postgres pg_dump -U postgres own_assistant > "$BACKUP_FILE"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS] Backup created: ${BACKUP_FILE}${NC}"

        # Show file size
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo "Backup size: $SIZE"
    else
        echo -e "${RED}[ERROR] Backup failed${NC}"
    fi
}

# Restore function
restore_database() {
    echo -e "${YELLOW}[WARNING] This will restore the database from backup.sql${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ ! -f backup.sql ]; then
            echo -e "${RED}[ERROR] backup.sql file not found${NC}"
            return 1
        fi

        echo -e "${BLUE}[INFO] Restoring database...${NC}"
        $COMPOSE_CMD exec -T postgres psql -U postgres own_assistant < backup.sql

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[SUCCESS] Database restored${NC}"
        else
            echo -e "${RED}[ERROR] Restore failed${NC}"
        fi
    else
        echo -e "${BLUE}[INFO] Restore cancelled${NC}"
    fi
}

# Clean function
clean_all() {
    echo -e "${RED}================================================${NC}"
    echo -e "${RED}  WARNING: This will DELETE ALL DATA!${NC}"
    echo -e "${RED}================================================${NC}"
    echo ""
    echo "This will remove:"
    echo "  - All containers"
    echo "  - All volumes (DATABASE DATA)"
    echo "  - All images"
    echo ""
    read -p "Are you absolutely sure? (type 'yes' to confirm): " -r

    if [ "$REPLY" = "yes" ]; then
        echo ""
        echo -e "${BLUE}[INFO] Cleaning everything...${NC}"
        $COMPOSE_CMD down -v
        docker rmi first-go-app 2>/dev/null || true
        echo -e "${GREEN}[SUCCESS] Cleanup completed${NC}"
    else
        echo -e "${BLUE}[INFO] Cleanup cancelled${NC}"
    fi
}

# Local build function
build_local() {
    echo -e "${BLUE}[INFO] Building locally (without Docker)...${NC}"

    if [ ! -f build.sh ]; then
        echo -e "${RED}[ERROR] build.sh not found${NC}"
        return 1
    fi

    chmod +x build.sh
    ./build.sh
}

# Main loop
while true; do
    show_menu
    read -p "Option: " choice
    echo ""

    case $choice in
        1)
            deploy
            ;;
        2)
            stop_services
            ;;
        3)
            view_logs
            ;;
        4)
            rebuild
            ;;
        5)
            show_status
            ;;
        6)
            backup_database
            ;;
        7)
            restore_database
            ;;
        8)
            clean_all
            ;;
        9)
            build_local
            ;;
        0)
            echo -e "${BLUE}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}[ERROR] Invalid option${NC}"
            ;;
    esac

    echo ""
    read -p "Press Enter to continue..."
    echo ""
done
