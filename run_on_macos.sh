#!/bin/bash

# Function to check if a command is available
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install a package if it is not already installed
install_package() {
  if ! command_exists "$1"; then
    echo "Installing $1..."

    case "$(uname -s)" in
      Darwin)
        # Install on macOS
        case "$1" in
          "npm")
            brew install node
            ;;
          "python3")
            brew install python
            ;;
          "pip")
            brew install pip
            ;;
        esac
        ;;
      CYGWIN*|MINGW32*|MSYS*|MINGW*)
        # Install on Windows
        case "$1" in
          "npm")
            choco install nodejs
            ;;
          "python3")
            choco install python
            ;;
          "pip")
            choco install pip
            ;;
          "choco")
            # Install Chocolatey on Windows
            Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
            ;;
        esac
        ;;
      *)
        echo "Unsupported operating system."
        exit 1
        ;;
    esac
  fi
}

# Function to install dependencies for the frontend
install_frontend_dependencies() {
  if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    cd frontend
    npm install
    cd ..
  fi
}

# Function to install dependencies for the backend
install_backend_dependencies() {
  echo "Installing backend dependencies..."
  pip install -r requirements.txt
}

# Check and install npm, Python, pip, and Chocolatey (on Windows)
install_package "choco"
install_package "npm"
install_package "python3"
install_package "pip"

# Install frontend and backend dependencies
install_frontend_dependencies
install_backend_dependencies

# Start the backend server
echo "Starting the backend server..."
python3 app.py &
BACKEND_PID=$!

# Start the frontend server
echo "Starting the frontend server..."
cd frontend
npm start
cd ..

# Cleanup: Stop the background process (backend server) on script exit
trap 'kill $BACKEND_PID' EXIT

# Note: The frontend server (npm start) runs in the foreground, so the script will wait for it to finish.
# The user can stop the script with Ctrl+C to stop both the frontend and backend servers.
