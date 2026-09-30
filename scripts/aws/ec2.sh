#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/ec2.conf"

APP_DIR="/home/ubuntu/v4-app"

# ============================================================
# CONFIGURATION
# ============================================================

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERROR] Configuration file not found:"
    echo "$CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

EC2_USER="${EC2_USER:-ubuntu}"

# ============================================================
# VALIDATION
# ============================================================

if [ -z "$AWS_REGION" ]; then
    echo "[ERROR] AWS_REGION is not configured."
    exit 1
fi

if [ -z "$EC2_INSTANCE_ID" ]; then
    echo "[ERROR] EC2_INSTANCE_ID is not configured."
    exit 1
fi

if [ -z "$EC2_KEY" ]; then
    echo "[ERROR] EC2_KEY is not configured."
    exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
    echo "[ERROR] AWS CLI is not installed."
    exit 1
fi

# ============================================================
# AWS HELPERS
# ============================================================

get_state() {

    aws ec2 describe-instances \
        --region "$AWS_REGION" \
        --instance-ids "$EC2_INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].State.Name' \
        --output text
}

get_ip() {

    aws ec2 describe-instances \
        --region "$AWS_REGION" \
        --instance-ids "$EC2_INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text
}

get_dns() {

    aws ec2 describe-instances \
        --region "$AWS_REGION" \
        --instance-ids "$EC2_INSTANCE_ID" \
        --query 'Reservations[0].Instances[0].PublicDnsName' \
        --output text
}

check_running() {

    STATE=$(get_state)

    if [ "$STATE" != "running" ]; then
        echo "[ERROR] EC2 is not running."
        echo "[INFO] Current state: $STATE"
        exit 1
    fi
}

check_key() {

    if [ ! -f "$EC2_KEY" ]; then
        echo "[ERROR] SSH key not found:"
        echo "$EC2_KEY"
        exit 1
    fi

    chmod 400 "$EC2_KEY"
}

ssh_ec2() {

    IP="$1"

    shift

    ssh \
        -i "$EC2_KEY" \
        -o StrictHostKeyChecking=accept-new \
        -o ConnectTimeout=10 \
        "$EC2_USER@$IP" \
        "$@"
}

# ============================================================
# STATUS
# ============================================================

command_status() {

    echo
    echo "========================================"
    echo "           EC2 STATUS"
    echo "========================================"
    echo

    STATE=$(get_state)
    IP=$(get_ip)
    DNS=$(get_dns)

    echo "Instance ID : $EC2_INSTANCE_ID"
    echo "Region      : $AWS_REGION"
    echo "User        : $EC2_USER"
    echo "State       : $STATE"
    echo "Public IP   : $IP"
    echo "Public DNS  : $DNS"

    echo
}

# ============================================================
# IP
# ============================================================

command_ip() {

    STATE=$(get_state)

    if [ "$STATE" != "running" ]; then
        echo "[INFO] Instance is not running."
        echo "[INFO] Current state: $STATE"
        exit 0
    fi

    get_ip
}

# ============================================================
# START
# ============================================================

command_start() {

    STATE=$(get_state)

    echo "[INFO] Current state: $STATE"

    if [ "$STATE" = "running" ]; then
        echo "[INFO] EC2 is already running."
        return
    fi

    if [ "$STATE" != "stopped" ]; then
        echo "[ERROR] Cannot start EC2 from state: $STATE"
        exit 1
    fi

    echo "[INFO] Starting EC2..."

    aws ec2 start-instances \
        --region "$AWS_REGION" \
        --instance-ids "$EC2_INSTANCE_ID"

    echo "[INFO] Waiting for EC2 to start..."

    aws ec2 wait instance-running \
        --region "$AWS_REGION" \
        --instance-ids "$EC2_INSTANCE_ID"

    echo "[SUCCESS] EC2 is running."

    echo
    echo "[INFO] Public IP:"
    get_ip
}

# ============================================================
# STOP
# ============================================================

command_stop() {

    STATE=$(get_state)

    echo "[INFO] Current state: $STATE"

    if [ "$STATE" = "stopped" ]; then
        echo "[INFO] EC2 is already stopped."
        return
    fi

    if [ "$STATE" != "running" ]; then
        echo "[ERROR] Cannot stop EC2 from state: $STATE"
        exit 1
    fi

    echo
    echo "[WARNING] You are about to stop the EC2 instance."
    echo

    read -r -p "Continue? [y/N]: " ANSWER

    if [[ ! "$ANSWER" =~ ^[Yy]$ ]]; then
        echo "[INFO] Cancelled."
        return
    fi

    echo "[INFO] Stopping EC2..."

    aws ec2 stop-instances \
        --region "$AWS_REGION" \
        --instance-ids "$EC2_INSTANCE_ID"

    echo "[INFO] Waiting for EC2 to stop..."

    aws ec2 wait instance-stopped \
        --region "$AWS_REGION" \
        --instance-ids "$EC2_INSTANCE_ID"

    echo "[SUCCESS] EC2 stopped."
}

# ============================================================
# REBOOT
# ============================================================

command_reboot() {

    check_running

    echo
    echo "[WARNING] You are about to reboot EC2."
    echo

    read -r -p "Continue? [y/N]: " ANSWER

    if [[ ! "$ANSWER" =~ ^[Yy]$ ]]; then
        echo "[INFO] Cancelled."
        return
    fi

    aws ec2 reboot-instances \
        --region "$AWS_REGION" \
        --instance-ids "$EC2_INSTANCE_ID"

    echo "[SUCCESS] Reboot requested."
}

# ============================================================
# SSH
# ============================================================

command_ssh() {

    check_running
    check_key

    IP=$(get_ip)

    echo
    echo "[INFO] Connecting to $EC2_USER@$IP"
    echo

    ssh_ec2 "$IP"
}

# ============================================================
# EC2 SETUP
# ============================================================

command_setup() {

    check_running
    check_key

    IP=$(get_ip)

    echo
    echo "========================================"
    echo "       V4 EC2 SERVER SETUP"
    echo "========================================"
    echo

    echo "[INFO] Connecting to $EC2_USER@$IP"
    echo

    ssh \
        -i "$EC2_KEY" \
        -o StrictHostKeyChecking=accept-new \
        -o ConnectTimeout=10 \
        "$EC2_USER@$IP" \
        'bash -s' <<'REMOTE'

set -e

echo
echo "========================================"
echo "       EC2 SERVER SETUP"
echo "========================================"
echo

echo "[1/8] Checking operating system..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "[INFO] OS: $PRETTY_NAME"
fi

echo
echo "[2/8] Checking sudo..."

sudo -n true

echo "[SUCCESS] sudo available."

echo
echo "[3/8] Repairing package manager..."

sudo dpkg --configure -a
sudo apt-get -f install -y
sudo apt-get update

echo
echo "[4/8] Checking Docker..."

if command -v docker >/dev/null 2>&1; then

    echo "[SUCCESS] Docker already installed."

else

    echo "[INFO] Installing Docker..."

    sudo apt-get install -y docker.io

fi

docker --version

echo
echo "[5/8] Checking Docker Compose..."

if dpkg-query -W -f='${Status}' docker-compose-v2 2>/dev/null \
    | grep -q "install ok installed"; then

    echo "[INFO] Removing docker-compose-v2..."

    sudo apt-get remove -y docker-compose-v2

fi

sudo dpkg --configure -a
sudo apt-get -f install -y

if docker compose version >/dev/null 2>&1; then

    echo "[SUCCESS] Docker Compose already installed."

else

    echo "[INFO] Installing Docker Compose plugin..."

    sudo apt-get install -y docker-compose-plugin

fi

docker compose version

echo
echo "[6/8] Configuring Docker service..."

sudo systemctl enable docker
sudo systemctl start docker

if sudo systemctl is-active --quiet docker; then
    echo "[SUCCESS] Docker service is running."
else
    echo "[ERROR] Docker service is not running."
    exit 1
fi

echo
echo "[7/8] Configuring Docker permissions..."

if id -nG "$USER" | grep -qw docker; then

    echo "[SUCCESS] $USER is already in docker group."

else

    echo "[INFO] Adding $USER to docker group."

    sudo usermod -aG docker "$USER"

    echo "[SUCCESS] User added to docker group."

fi

echo
echo "[8/8] Preparing application directory..."

sudo mkdir -p /home/ubuntu/v4-app
sudo chown "$USER:$USER" /home/ubuntu/v4-app

echo "[SUCCESS] Application directory ready."

echo
echo "========================================"
echo "       EC2 SETUP COMPLETE"
echo "========================================"
echo

echo "Docker:"
docker --version

echo
echo "Docker Compose:"
docker compose version

echo
echo "Docker service:"
sudo systemctl is-active docker

echo
echo "Docker group:"
id -nG "$USER"

echo

REMOTE

    echo
    echo "========================================"
    echo "       VERIFYING DOCKER ACCESS"
    echo "========================================"
    echo

    ssh \
        -i "$EC2_KEY" \
        -o StrictHostKeyChecking=accept-new \
        -o ConnectTimeout=10 \
        "$EC2_USER@$IP" \
        'docker ps'

    echo
    echo "========================================"
    echo "       EC2 SETUP COMPLETE"
    echo "========================================"
    echo

}

# ============================================================
# APPLICATION STATUS
# ============================================================

command_app_status() {

    check_running
    check_key

    IP=$(get_ip)

    echo
    echo "========================================"
    echo "       V4 APPLICATION STATUS"
    echo "========================================"
    echo

    ssh_ec2 "$IP" \
        "cd '$APP_DIR' && docker compose -f docker-compose.prod.yml ps"
}

# ============================================================
# APPLICATION LOGS
# ============================================================

command_logs() {

    check_running
    check_key

    IP=$(get_ip)

    echo
    echo "========================================"
    echo "       V4 APPLICATION LOGS"
    echo "========================================"
    echo

    ssh_ec2 "$IP" \
        "cd '$APP_DIR' && docker compose -f docker-compose.prod.yml logs --tail=100"
}

# ============================================================
# APPLICATION RESTART
# ============================================================

command_restart() {

    check_running
    check_key

    IP=$(get_ip)

    echo "[INFO] Restarting V4 application..."

    ssh_ec2 "$IP" \
        "cd '$APP_DIR' && docker compose -f docker-compose.prod.yml restart"

    echo "[SUCCESS] Application restarted."
}

# ============================================================
# APPLICATION STOP
# ============================================================

command_app_stop() {

    check_running
    check_key

    IP=$(get_ip)

    echo
    echo "[WARNING] This will stop the V4 application."
    echo

    read -r -p "Continue? [y/N]: " ANSWER

    if [[ ! "$ANSWER" =~ ^[Yy]$ ]]; then
        echo "[INFO] Cancelled."
        return
    fi

    ssh_ec2 "$IP" \
        "cd '$APP_DIR' && docker compose -f docker-compose.prod.yml down"

    echo "[SUCCESS] Application stopped."
}

# ============================================================
# HELP
# ============================================================

command_help() {

    echo
    echo "V4 EC2 CONTROL"
    echo
    echo "Usage:"
    echo "  ./scripts/aws/ec2.sh <command>"
    echo
    echo "EC2:"
    echo "  status        Show EC2 status"
    echo "  ip            Show public IP"
    echo "  start         Start EC2"
    echo "  stop          Stop EC2"
    echo "  reboot        Reboot EC2"
    echo "  ssh           SSH into EC2"
    echo
    echo "Server:"
    echo "  setup         Setup Docker and Docker Compose"
    echo
    echo "Application:"
    echo "  app-status    Show application status"
    echo "  logs          Show application logs"
    echo "  restart       Restart application"
    echo "  app-stop      Stop application"
    echo
}

# ============================================================
# MAIN
# ============================================================

COMMAND="${1:-help}"

case "$COMMAND" in

    status)
        command_status
        ;;

    ip)
        command_ip
        ;;

    start)
        command_start
        ;;

    stop)
        command_stop
        ;;

    reboot)
        command_reboot
        ;;

    ssh)
        command_ssh
        ;;

    setup)
        command_setup
        ;;

    app-status)
        command_app_status
        ;;

    logs)
        command_logs
        ;;

    restart)
        command_restart
        ;;

    app-stop)
        command_app_stop
        ;;

    help|--help|-h)
        command_help
        ;;

    *)
        echo "[ERROR] Unknown command: $COMMAND"
        echo
        command_help
        exit 1
        ;;

esac