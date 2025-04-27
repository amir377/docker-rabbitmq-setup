function Prompt-User($message, $default) {
    $input = Read-Host "$message (Default: $default)"
    if ([string]::IsNullOrWhiteSpace($input)) { return $default } else { return $input }
}

# Prompt
$containerName = Prompt-User "Enter the container name" "rabbitmq"
$networkName = Prompt-User "Enter the network name" "general"
$rabbitmqPort = Prompt-User "Enter the RabbitMQ port (AMQP)" "5672"
$rabbitmqManagementPort = Prompt-User "Enter the RabbitMQ Management UI port" "15672"
$allowHost = Prompt-User "Enter the allowed host" "0.0.0.0"
$rabbitmqUser = Prompt-User "Enter the RabbitMQ default user" "admin"
$rabbitmqPass = Prompt-User "Enter the RabbitMQ default password" "admin"

# Generate .env
@"
CONTAINER_NAME=$containerName
NETWORK_NAME=$networkName
RABBITMQ_PORT=$rabbitmqPort
RABBITMQ_MANAGEMENT_PORT=$rabbitmqManagementPort
ALLOW_HOST=$allowHost

RABBITMQ_DEFAULT_USER=$rabbitmqUser
RABBITMQ_DEFAULT_PASS=$rabbitmqPass
"@ | Set-Content -Path ".env"

Write-Host ".env file created."

# Docker checks
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not installed. Please install Docker and try again."
    exit
}

if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Compose is not installed. Please install Docker Compose and try again."
    exit
}

# Create network
docker network create $networkName | Out-Null

# Create docker-compose.yaml
(Get-Content docker-compose.example.yaml) |
ForEach-Object {
    $_ -replace '\$\{CONTAINER_NAME\}', $containerName `
       -replace '\$\{NETWORK_NAME\}', $networkName `
       -replace '\$\{RABBITMQ_PORT\}', $rabbitmqPort `
       -replace '\$\{RABBITMQ_MANAGEMENT_PORT\}', $rabbitmqManagementPort `
       -replace '\$\{ALLOW_HOST\}', $allowHost `
       -replace '\$\{RABBITMQ_DEFAULT_USER\}', $rabbitmqUser `
       -replace '\$\{RABBITMQ_DEFAULT_PASS\}', $rabbitmqPass
} | Set-Content -Path "docker-compose.yaml"

Write-Host "docker-compose.yaml created."

# Start container
docker-compose up -d --build

if ((docker inspect -f '{{.State.Running}}' $containerName) -eq "true") {
    Write-Host "RabbitMQ setup complete. Management UI: http://localhost:$rabbitmqManagementPort"
} else {
    Write-Host "Container failed. Showing logs..."
    docker logs $containerName
}
