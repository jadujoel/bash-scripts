#!/bin/bash
# kill.sh

# Can be used if a process got stuck even after closing the terminal
# Function to kill a process running on a given port
kill_port() {
    local port=$1

    PLATFORM="$(uname -s)"
    if [[ $PLATFORM == "Darwin" || $PLATFORM = "Linux" ]]; then
        # check if awk is installed
        if ! command -v awk &> /dev/null; then
            echo "[kill] awk command not found, please install awk"
            exit 1
        fi
        # check if lsof is installed
        if ! command -v lsof &> /dev/null; then
            echo "[kill] lsof command not found, please install lsof"
            exit 1
        fi
        local pid=$(lsof -i :$PORT | awk 'NR==2 {print $2}')
    elif [[ $PLATFORM == "MINGW"* || $PLATFORM == "CYGWIN"* ]]; then
        # check if netstat is installed
        if ! command -v netstat &> /dev/null; then
            echo "[kill] netstat command not found, please install netstat"
            exit 1
        fi
        # check if grep is installed
        if ! command -v grep &> /dev/null; then
            echo "[kill] grep command not found, please install grep"
            exit 1
        fi
        # Windows (Git Bash)
        local pid=$(netstat -ano | grep ":$PORT" | awk '{print $5}')
    else
        echo "[kill] Unsupported Platform $PLATFORM"
        exit 1
    fi

    if [[ -n "$pid" ]]; then
        echo "[kill] Killing PID $pid running on port $PORT"
        kill -9 $pid
    else
        echo "[kill] No process found for port $PORT, skipping..."
    fi
}

# Main script
if [[ -z "$1" ]]; then
    echo "Usage: $0 <port>"
    exit 1
fi

PORT=$1


# check if args include --test
if [[ "$2" == "--test" ]]; then
    echo "Testing..."
    # start a server
    echo "Starting a server on port $PORT"
    if [[ "$(uname -s)" == "Darwin" || "$(uname -s)" == "Linux" ]]; then
        # check if python is installed
        if ! command -v python3 &> /dev/null; then
            echo "[test] python3 command not found, please install python3"
            exit 1
        fi
        python3 -m http.server $PORT &
    elif [[ "$(uname -s)" == "MINGW"* || "$(uname -s)" == "CYGWIN"* ]]; then
        # Windows (Git Bash)
        # check if python is installed
        if ! command -v python &> /dev/null; then
            echo "[test] python command not found, please install python"
            exit 1
        fi
        python -m http.server $PORT &
    else
        echo "[test] Unsupported Platform $(uname -s)"
        exit 1
    fi
    # set a timeout so the server has time to start
    sleep 3
fi

kill_port $PORT
