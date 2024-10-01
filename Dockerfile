# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2022
ARG RUNNER_OS=win
ARG RUNNER_ARCH=x64
ARG RUNNER_VERSION
ARG RUNNER_CONTAINER_HOOKS_VERSION=0.6.1

# Use PowerShell as the default shell for setup tasks
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR C:/home/runner

# Install Chocolatey to install Git (with Git Bash) and Docker CLI
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); `
    choco install git -y; `
    choco install docker-cli docker-compose -y

# Download and install Git Bash
RUN Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v${env:RUNNER_VERSION}/actions-runner-${env:RUNNER_OS}-${env:RUNNER_ARCH}-${env:RUNNER_VERSION}.zip -OutFile actions-runner.zip; `
    Add-Type -AssemblyName System.IO.Compression.FileSystem; `
    [System.IO.Compression.ZipFile]::ExtractToDirectory('actions-runner.zip', $PWD); `
    Remove-Item -Path actions-runner.zip -Force

# Install Git Bash
RUN choco install git -y

# Set Git Bash as the default shell
SHELL ["C:\\Program Files\\Git\\bin\\bash.exe", "-c"]

# Now all following RUN commands will be executed using Bash
# Download vswhere.exe and move to a directory
RUN curl -L -o vswhere.exe "https://github.com/microsoft/vswhere/releases/download/2.8.4/vswhere.exe" && \
    mv vswhere.exe "/Program Files/vswhere.exe"

# Set up your runner, and use Bash
RUN curl -L -o actions-runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${RUNNER_OS}-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz && \
    tar -xzf actions-runner.tar.gz && \
    rm actions-runner.tar.gz
