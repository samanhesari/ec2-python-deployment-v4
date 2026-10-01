#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/ec2.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERROR] Configuration file not found:"
    echo "$CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"


APP_DIR="/home/ubuntu/v4-app"


get_instance_state() {

    aws ec2 describe-instances \
        --region "$AWS_REGION" \
        --instance-ids "$EC2_INSTANCE_ID" \
        --query "Reservations[0].Instances[0].State.Name" \
        --output text
}


get_public_ip() {

    aws ec2 describe-instances \
        --region "$AWS_REGION" \
        --instance-ids "$EC2_INSTANCE_ID" \
        --query "Reservations[0].Instances[0].PublicIpAddress" \
        --output text
}


case "$1" in

    status)

        echo "EC2 instance status:"

        get_instance_state

        ;;


    ip)

        IP="$(get_public_ip)"

        if [ "$IP" = "None" ]; then
            echo "[ERROR] EC2 instance does not currently have a public IP."
            exit 1
        fi

        echo "$IP"

        ;;


    start)

        STATE="$(get_instance_state)"

        echo "Current state: $STATE"

        if [ "$STATE" = "running" ]; then

            echo "EC2 is already running."

        elif [ "$STATE" = "stopped" ]; then

            echo "Starting EC2..."

            aws ec2 start-instances \
                --region "$AWS_REGION" \
                --instance-ids "$EC2_INSTANCE_ID" \
                >/dev/null

            echo "Waiting for EC2 to become running..."

            aws ec2 wait instance-running \
                --region "$AWS_REGION" \
                --instance-ids "$EC2_INSTANCE_ID"

            echo "EC2 is now running."

        else

            echo "[ERROR] EC2 is in unexpected state:"
            echo "$STATE"

            exit 1

        fi

        ;;


    stop)

        STATE="$(get_instance_state)"

        echo "Current state: $STATE"

        if [ "$STATE" = "stopped" ]; then

            echo "EC2 is already stopped."

        elif [ "$STATE" = "running" ]; then

            echo "Stopping EC2..."

            aws ec2 stop-instances \
                --region "$AWS_REGION" \
                --instance-ids "$EC2_INSTANCE_ID" \
                >/dev/null

            echo "Waiting for EC2 to stop..."

            aws ec2 wait instance-stopped \
                --region "$AWS_REGION" \
                --instance-ids "$EC2_INSTANCE_ID"

            echo "EC2 is now stopped."

        else

            echo "[ERROR] EC2 is in unexpected state:"
            echo "$STATE"

            exit 1

        fi

        ;;


    reboot)

        STATE="$(get_instance_state)"

        if [ "$STATE" != "running" ]; then

            echo "[ERROR] EC2 must be running to reboot."

            exit 1

        fi

        echo "Rebooting EC2..."

        aws ec2 reboot-instances \
            --region "$AWS_REGION" \
            --instance-ids "$EC2_INSTANCE_ID"

        echo "Reboot request sent."

        ;;


    ssh)

        IP="$(get_public_ip)"

        if [ "$IP" = "None" ]; then

            echo "[ERROR] EC2 does not have a public IP."

            exit 1

        fi

        echo "Connecting to $EC2_USER@$IP..."

        ssh \
            -i "$SSH_KEY" \
            "$EC2_USER@$IP"

        ;;


    setup)

        IP="$(get_public_ip)"

        if [ "$IP" = "None" ]; then

            echo "[ERROR] EC2 does not have a public IP."

            exit 1

        fi

        echo "Running EC2 setup..."

        ssh \
            -i "$SSH_KEY" \
            "$EC2_USER@$IP" \
            "sudo apt-get update && \
             sudo apt-get install -y docker.io docker-compose-v2 && \
             sudo systemctl enable docker && \
             sudo systemctl start docker && \
             sudo usermod -aG docker \$USER && \
             mkdir -p $APP_DIR"

        echo
        echo "[SUCCESS] EC2 setup completed."
        echo
        echo "If Docker permissions were changed, log out and back in."
        ;;


    app-status)

        IP="$(get_public_ip)"

        if [ "$IP" = "None" ]; then

            echo "[ERROR] EC2 does not have a public IP."

            exit 1

        fi

        ssh \
            -i "$SSH_KEY" \
            "$EC2_USER@$IP" \
            "cd $APP_DIR && docker compose --env-file .env -f docker-compose.prod.yml ps"

        ;;


    logs)

        IP="$(get_public_ip)"

        if [ "$IP" = "None" ]; then

            echo "[ERROR] EC2 does not have a public IP."

            exit 1

        fi

        ssh \
            -i "$SSH_KEY" \
            "$EC2_USER@$IP" \
            "cd $APP_DIR && docker compose --env-file .env -f docker-compose.prod.yml logs --tail=100"

        ;;


    restart)

        IP="$(get_public_ip)"

        if [ "$IP" = "None" ]; then

            echo "[ERROR] EC2 does not have a public IP."

            exit 1

        fi

        echo "Restarting application..."

        ssh \
            -i "$SSH_KEY" \
            "$EC2_USER@$IP" \
            "cd $APP_DIR && docker compose --env-file .env -f docker-compose.prod.yml restart"

        echo "Application restarted."

        ;;


    app-stop)

        IP="$(get_public_ip)"

        if [ "$IP" = "None" ]; then

            echo "[ERROR] EC2 does not have a public IP."

            exit 1

        fi

        echo "Stopping application..."

        ssh \
            -i "$SSH_KEY" \
            "$EC2_USER@$IP" \
            "cd $APP_DIR && docker compose --env-file .env -f docker-compose.prod.yml stop"

        echo "Application stopped."

        ;;


    *)

        echo
        echo "Usage:"
        echo
        echo "  $0 status"
        echo "  $0 ip"
        echo "  $0 start"
        echo "  $0 stop"
        echo "  $0 reboot"
        echo "  $0 ssh"
        echo "  $0 setup"
        echo "  $0 app-status"
        echo "  $0 logs"
        echo "  $0 restart"
        echo "  $0 app-stop"
        echo

        exit 1

        ;;

esac