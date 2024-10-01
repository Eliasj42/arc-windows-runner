# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2022
ARG RUNNER_OS=win
ARG RUNNER_ARCH=x64
ARG RUNNER_VERSION
ARG RUNNER_CONTAINER_HOOKS_VERSION=0.6.1

# Install Git Bash to use Bash commands
RUN powershell.exe -Command \
    Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); \
    choco install git -y

# Switch to bash for the rest of the build process
SHELL ["bash", "-c"]

WORKDIR /home/runner

# Install Actions Runner
RUN curl -L -o actions-runner.zip https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${RUNNER_OS}-${RUNNER_ARCH}-${RUNNER_VERSION}.zip && \
    unzip actions-runner.zip && \
    rm actions-runner.zip

# Optional: Install Runner Container Hooks (commented out)
# RUN curl -L -o runner-container-hooks.zip https://github.com/actions/runner-container-hooks/releases/download/v${RUNNER_CONTAINER_HOOKS_VERSION}/actions-runner-hooks-k8s-${RUNNER_CONTAINER_HOOKS_VERSION}.zip && \
#     unzip runner-container-hooks.zip -d ./k8s && \
#     rm runner-container-hooks.zip

# Install Docker CLI using Chocolatey
RUN choco install docker-cli docker-compose -y

# Enable long paths
RUN reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d 1 /f

# Download vswhere.exe from the official GitHub releases
RUN curl -L -o vswhere.exe https://github.com/microsoft/vswhere/releases/download/2.8.4/vswhere.exe
