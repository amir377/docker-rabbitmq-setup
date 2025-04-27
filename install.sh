#!/bin/bash

prompt_user() {
    local prompt_text="$1"
    local default_value="$2"
    read -p "$prompt_text (Default: $default_value): " input
    echo "${input:-$default_value}"
}

# Prompt user for RabbitMQ setup details
container_name=$(prompt_user "Enter the container name" "rabbitmq")
network_name=$(prompt_user "Enter the network name" "general")
rabbitmq_port=$(prompt_user "Enter the RabbitMQ port (AMQP)" "5672")
rabbitmq_management_port=$(prompt_user "Enter the RabbitMQ Management UI port" "15672")
allow_host=$(prompt_user "Enter the allowed host" "0.0.0.0")
rabbitmq_user=$(prompt_user "Enter the RabbitMQ default user" "admin")
rabbitmq_pass=$(prompt_user "Enter the RabbitMQ default password" "admin")

# Generate the .env file
echo "Creating .env file for RabbitMQ setup..."
cat > .env <<EOL
# RabbitMQ container settings
CONTAINER_NAME=$container_name
NETWORK_NAME=$network_name
RABBITMQ_PORT=$rabbitmq_port
RABBITMQ_MANAGEMENT_PORT=$rabbitmq_management_port
ALLOW_HOST=$allow_host

# RabbitMQ credentials
RABBITMQ_DEFAULT_USER=$rabbitmq_user
RABBITMQ_DEFAULT_PASS=$rabbitmq_pass
EOL
echo ".env file created successfully."

# Docker checks
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully."
fi

# Create the network
echo "Creating Docker network $network_name if it does not exist..."
docker network create $network_name || echo "Network $network_name already exists. Skipping creation."

# Create docker-compose.yaml
echo "Generating docker-compose.yaml file from docker-compose.example.yaml..."
if [ -f "docker-compose.example.yaml" ]; then
    sed -e "s/\${CONTAINER_NAME}/$container_name/g" \
        -e "s/\${NETWORK_NAME}/$network_name/g" \
        -e "s/\${RABBITMQ_PORT}/$rabbitmq_port/g" \
        -e "s/\${RABBITMQ_MANAGEMENT_PORT}/$rabbitmq_management_port/g" \
        -e "s/\${ALLOW_HOST}/$allow_host/g" \
        -e "s/\${RABBITMQ_DEFAULT_USER}/$rabbitmq_user/g" \
        -e "s/\${RABBITMQ_DEFAULT_PASS}/$rabbitmq_pass/g" \
        docker-compose.example.yaml > docker-compose.yaml
    echo "docker-compose.yaml file created successfully."
else
    echo "docker-compose.example.yaml file not found. Please ensure it exists in the current directory."
    exit 1
fi

# Start Docker Compose
echo "Starting Docker Compose with --build for RabbitMQ..."
if docker-compose up -d --build; then
    echo "Checking container status..."
    if [ "$(docker inspect -f '{{.State.Running}}' $container_name)" = "true" ]; then
        echo "RabbitMQ setup is complete and running. Access the Management UI at http://localhost:$rabbitmq_management_port"
    else
        echo "Container is not running. Fetching logs..."
        docker logs $container_name
    fi
else
    echo "Failed to start Docker Compose. Ensure Docker is running and try again."
    exit 1
fi
