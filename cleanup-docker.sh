#!/bin/bash

# Stop all running containers
echo "Stopping all containers..."
docker stop $(docker ps -aq) 2>/dev/null

# Remove all containers
echo "Removing all containers..."
docker rm $(docker ps -aq) 2>/dev/null

# Remove all images
echo "Removing all images..."
docker rmi $(docker images -q) -f 2>/dev/null

# Remove all volumes
echo "Removing all volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null

# Remove all networks (except default ones)
echo "Removing all user-defined networks..."
docker network rm $(docker network ls -q | grep -v "bridge\|host\|none") 2>/dev/null

echo "Done!"
