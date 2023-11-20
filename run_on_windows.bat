@echo off
setlocal

:: Check and install npm, Python, pip, and Chocolatey (on Windows)
call :install_package "choco"
call :install_package "npm"
call :install_package "python3"
call :install_package "pip"

:: Install frontend and backend dependencies
call :install_frontend_dependencies
call :install_backend_dependencies

:: Start the backend server
echo Starting the backend server...
cd backend
start /b python app.py
cd ..

:: Start the frontend server
echo Starting the frontend server...
cd frontend
start npm run serve
cd ..

pause

:: Function to check if a command is available
:command_exists
where %1 >nul 2>nul
if %errorlevel% neq 0 (
  exit /b 0
) else (
  exit /b 1
)

:: Function to install a package if it is not already installed
:install_package
echo Checking if %1 is installed...
call :command_exists %~1
if %errorlevel% neq 0 (
  echo Installing %1...
  if "%1"=="npm" (
    choco install nodejs
  )
  if "%1"=="python3" (
    choco install python
  )
  if "%1"=="pip" (
    choco install pip
  )
  if "%1"=="choco" (
    @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
  )
)
exit /b 0

:: Function to install dependencies for the frontend
:install_frontend_dependencies
if not exist "node_modules" (
  echo Installing frontend dependencies...
  cd frontend
  npm install
  cd ..
)
exit /b 0

:: Function to install dependencies for the backend
:install_backend_dependencies
echo Installing backend dependencies...
cd backend
pip install -r requirements.txt
cd ..
exit /b 0

:: Note: The frontend server (npm start) runs in a new command prompt window, so the script will wait for it to finish.
:: The user can stop the script with Ctrl+C to stop both the frontend and backend servers.