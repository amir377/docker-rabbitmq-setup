# Docker RabbitMQ Setup

This repository provides an easy-to-use solution for deploying a RabbitMQ server inside a Docker container.
It includes a user-friendly PowerShell script (`install.ps1`) and a Bash script (`install.sh`) to automate the setup with customizable parameters.

---

## Features

- **Environment File Generation**: Automatically generates a `.env` file with your custom RabbitMQ settings.
- **Docker Network Management**: Creates a Docker network if it doesn't already exist.
- **Docker Compose Configuration**: Dynamically generates a `docker-compose.yaml` from a `docker-compose.example.yaml` template.
- **Build and Run**: Uses `docker-compose up -d --build` to start RabbitMQ.
- **Status Check**: Checks if RabbitMQ is running after deployment.
- **Error Handling**: Displays logs if the container fails to start.
- **Management UI Access**: Easily access the RabbitMQ Management Dashboard.

---

## Prerequisites

- Docker installed and running.
- Docker Compose installed.
- **Linux only**: install `dos2unix` if needed:
  ```bash
  sudo apt install dos2unix
  ```
- Git installed:
  ```bash
  sudo apt install git       # Debian/Ubuntu
  sudo yum install git       # CentOS/RHEL
  brew install git           # macOS
  ```

---

## Installation Steps

### One Command Install

#### Windows
Open **PowerShell (Admin)** and run:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; git clone https://github.com/yourusername/docker-rabbitmq-setup; cd docker-rabbitmq-setup; ./install.ps1
```

#### Linux / Mac
Run this in your terminal:
```bash
git clone https://github.com/yourusername/docker-rabbitmq-setup && cd docker-rabbitmq-setup && dos2unix install.sh && chmod +x install.sh && ./install.sh
```

---

## Manual Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/docker-rabbitmq-setup.git
   cd docker-rabbitmq-setup
   ```

2. Place your `docker-compose.example.yaml` in the root directory (if not already there).

3. Run the install script:
    - Windows: `install.ps1`
    - Linux/Mac: `install.sh`

4. Follow the prompts to set up:
    - Container name
    - Network name
    - AMQP port
    - Management UI port
    - Default user and password

---

## File Structure

| File                         | Description                                                    |
| ----------------------------- | -------------------------------------------------------------- |
| `install.sh`                  | Automated setup script for Linux/Mac                           |
| `install.ps1`                 | Automated setup script for Windows PowerShell                  |
| `.env.example`                | Example environment configuration                             |
| `docker-compose.example.yaml` | Template for Docker Compose deployment                        |
| `.env`                        | (Generated) Holds your actual RabbitMQ environment variables  |
| `docker-compose.yaml`         | (Generated) Final Docker Compose file used for running         |

---

## Accessing RabbitMQ

- **AMQP Port**: `5672` (default) — used by apps to connect
- **Management UI**: [http://localhost:15672](http://localhost:15672)
- **Default Credentials** (from `.env` file):
    - Username: `admin`
    - Password: `admin`

---

## Troubleshooting

- To view container logs:
  ```bash
  docker logs <container-name>
  ```

- To manually access container shell:
  ```bash
  docker exec -it <container-name> bash
  ```

- If the container fails to start, the script automatically shows you the logs.

---

## License

This project is licensed under the MIT License.
See the [LICENSE](LICENSE) file for details.

---

Happy Messaging! 🚀
