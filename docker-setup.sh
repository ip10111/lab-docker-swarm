#!/bin/bash

# Automate the creation of docker swarm, secret and docker stack from docker-compose file

# Default values
STACK_NAME="mystack"
SECRETS_FILE="example-secret-list.txt"
COMPOSE_FILE="docker-compose.yml"

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -stack) STACK_NAME="$2"; shift ;;
        -file) SECRETS_FILE="$2"; shift ;;
        -compose) COMPOSE_FILE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if Docker Swarm is already initiated
if docker info 2>/dev/null | grep -q "Swarm: active"; then
    echo "Docker Swarm is already initiated."
else
    echo "Docker Swarm is not initiated. Initiating Docker Swarm..."
    docker swarm init
    if [ $? -eq 0 ]; then
        echo "Docker Swarm has been successfully initiated."
    else
        echo "Failed to initiate Docker Swarm."
        exit 1
    fi
fi

# Read the secrets file and add each secret
while IFS= read -r line || [ -n "$line" ]; do
    SECRET_NAME=$(echo "$line" | cut -d' ' -f1)
    SECRET_VALUE=$(echo "$line" | cut -d' ' -f2- | tr -d '"')

    # Check if the secret already exists
    if docker secret ls | grep -q "$SECRET_NAME"; then
        echo "Secret $SECRET_NAME already exists, skipping."
    else
        echo -n "$SECRET_VALUE" | docker secret create "$SECRET_NAME" -
        if [ $? -eq 0 ]; then
            echo "Secret $SECRET_NAME added successfully."
        else
            echo "Failed to add secret $SECRET_NAME."
            exit 1
        fi
    fi
done < "$SECRETS_FILE"

# Deploy the Docker Compose stack
docker stack deploy -c "$COMPOSE_FILE" "$STACK_NAME"
if [ $? -eq 0 ]; then
    echo "Docker Compose stack $STACK_NAME deployed successfully."
else
    echo "Failed to deploy Docker Compose stack $STACK_NAME."
    exit 1
fi
