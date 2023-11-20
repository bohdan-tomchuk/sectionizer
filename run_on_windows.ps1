# Function to check if a command is available
function Test-Command {
  param([string]$command)
  $null -ne (Get-Command -ErrorAction SilentlyContinue $command)
}

# Function to install a package if it is not already installed
function Install-Package {
  param([string]$package)
  
  if (-not (Test-Command $package)) {
    Write-Host "Installing $package..."
    switch ($package) {
      "npm" {
        # Install npm using Chocolatey
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        choco install nodejs
      }
      "python3" {
        # Install Python 3 using Chocolatey
        choco install python
      }
      "pip" {
        # Install pip using Chocolatey
        choco install pip
      }
    }
  }
}

# Function to install dependencies for the frontend
function Install-Frontend-Dependencies {
  # check if node_modules folder exists
  if (-not (Test-Path "frontend/node_modules")) {
    Write-Host "Installing frontend dependencies..."
    cd frontend
    npm install
    cd ..
  }
}

# Function to install dependencies for the backend
function Install-Backend-Dependencies {
  Write-Host "Installing backend dependencies..."
  pip install -r backend/requirements.txt
}

# Check and install npm, Python, and pip
Install-Package "npm"
Install-Package "python3"
Install-Package "pip"

# Install frontend and backend dependencies
Install-Frontend-Dependencies
Install-Backend-Dependencies

# Start the backend server
Write-Host "Starting the backend server..."
python backend/app.py &
$backendProcess = Get-Process -Name "python"

# Start the frontend server
Write-Host "Starting the frontend server..."
cd frontend
npm start
cd ..

# Cleanup: Stop the background process (backend server) on script exit
$backendProcess.Kill()
