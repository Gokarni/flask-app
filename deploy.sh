#!/bin/bash

# Create network if not exists
if ! docker network ls | grep -w flask-network; then
    docker network create flask-network
fi

# Backend
docker stop mysql 2>/dev/null
docker rm mysql 2>/dev/null
docker run -d --network=flask-network --name mysql -e MYSQL_ROOT_PASSWORD=admin mysql

# Frontend
docker stop frontend 2>/dev/null
docker rm frontend 2>/dev/null
docker run -d -p 5000:5000 --network=flask-network --env-file .env frontend
