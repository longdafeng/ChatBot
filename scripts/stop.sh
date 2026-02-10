#!/usr/bin/env bash

# Stop the ChatBot UI service
# This script finds and kills any running streamlit processes related to the ChatBot

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "Stopping ChatBot UI service..."

# Find and kill streamlit processes running chat_ui.py or flow_ui.py
PIDS=$(ps aux | grep -E "streamlit.*chat_ui\.py|streamlit.*flow_ui\.py" | grep -v grep | awk '{print $2}')

if [ -n "$PIDS" ]; then
    for PID in $PIDS; do
        echo "Stopping process $PID..."
        kill "$PID" 2>/dev/null || true
    done

    # Wait a bit for processes to terminate
    sleep 2

    # Force kill if still running
    PIDS=$(ps aux | grep -E "streamlit.*chat_ui\.py|streamlit.*flow_ui\.py" | grep -v grep | awk '{print $2}')
    if [ -n "$PIDS" ]; then
        for PID in $PIDS; do
            echo "Force stopping process $PID..."
            kill -9 "$PID" 2>/dev/null || true
        done
    fi
else
    echo "No ChatBot UI service is running."
fi

# Stop database container only when local DB is managed by make init
if [ -f "$PROJECT_ROOT/.env" ]; then
    set -a
    source "$PROJECT_ROOT/.env"
    set +a

    if [ "${REUSE_CURRENT_DB}" != "true" ]; then
        docker_name=""
        if [ "${DB_STORE}" = "seekdb" ]; then
            docker_name="chatbot-seekdb"
        elif [ "${DB_STORE}" = "oceanbase" ]; then
            docker_name="chatbot-oceanbase"
        fi

        if [ -n "$docker_name" ] && command -v docker &> /dev/null; then
            if docker ps --format "{{.Names}}" 2>/dev/null | grep -q "^${docker_name}$"; then
                echo "Stopping docker container ${docker_name}..."
                docker stop "${docker_name}" >/dev/null || true
            elif sudo docker ps --format "{{.Names}}" 2>/dev/null | grep -q "^${docker_name}$"; then
                echo "Stopping docker container (sudo) ${docker_name}..."
                sudo docker stop "${docker_name}" >/dev/null || true
            fi
        fi
    fi
fi

echo "ChatBot UI service stopped."
