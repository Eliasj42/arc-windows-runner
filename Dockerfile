##### BASE IMAGE INFO ######
#Using servercore insider edition for compacted size.
#For compatibility on "your" host running docker you may need to use a specific tag.
#E.g. the host OS version must match the container OS version. 
#If you want to run a container based on a newer Windows build, make sure you have an equivalent host build. 
#Otherwise, you can use Hyper-V isolation to run older containers on new host builds. 
#The default entrypoint is for this image is Cmd.exe. To run the image:
#docker run mcr.microsoft.com/windows/servercore/insider:10.0.{build}.{revision}
#tag reference: https://mcr.microsoft.com/en-us/product/windows/servercore/insider/tags

#Win10
FROM mcr.microsoft.com/windows/servercore:ltsc2022

#Win11
#FROM mcr.microsoft.com/windows/servercore/insider:10.0.26244.5000

FROM mcr.microsoft.com/windows/servercore:ltsc2022
ARG RUNNER_OS=win
ARG RUNNER_ARCH=x64
ARG RUNNER_VERSION
ARG RUNNER_CONTAINER_HOOKS_VERSION=0.6.1

#Set working directory
WORKDIR /actions-runner

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';$ProgressPreference='silentlyContinue';"]

RUN `
  ###############################################################################################
  #   Install Actions Runner
  #   You must always install the runner, and you want the latest version to avoid the restrictions
  #   applied to out-of-date runners.
  #   https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/autoscaling-with-self-hosted-runners#:~:text=Warning,-Any%20updates%20released
  ###############################################################################################
  Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v${env:RUNNER_VERSION}/actions-runner-${env:RUNNER_OS}-${env:RUNNER_ARCH}-${env:RUNNER_VERSION}.zip -OutFile actions-runner.zip;`
  Add-Type -AssemblyName System.IO.Compression.FileSystem;`
  [System.IO.Compression.ZipFile]::ExtractToDirectory('actions-runner.zip', $PWD);`
  Remove-Item -Path actions-runner.zip -Force
  ###############################################################################################
  #   Install Runner Container Hooks
  #   While it is possible to include these hooks, Windows runners can't use these today. 
  #   GitHub documents that you must use Linux runners for Docker container actions, job containers,
  #   or service containers.
  #   See also https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#jobsjob_idservices
  #   and https://github.com/actions/runner/issues/904
  ###############################################################################################
  # Invoke-WebRequest -OutFile runner-container-hooks.zip -Uri https://github.com/actions/runner-container-hooks/releases/download/v${env:RUNNER_CONTAINER_HOOKS_VERSION}/actions-runner-hooks-k8s-${env:RUNNER_CONTAINER_HOOKS_VERSION}.zip;`
  # [System.IO.Compression.ZipFile]::ExtractToDirectory('runner-container-hooks.zip', (Join-Path -Path $PWD -ChildPath 'k8s'));`
  # Remove-Item -Path runner-container-hooks.zip -Force;`
  ###############################################################################################

#Install chocolatey
ADD scripts/Install-Choco.ps1 .
RUN .\Install-Choco.ps1 -Wait

#Install Git, GitHub-CLI, Azure-CLI and PowerShell Core with Chocolatey (add more tooling if needed at build)
RUN choco install -y \
    git \
    gh \
    powershell-core \
    azure-cli

#Download GitHub Runner based on RUNNER_VERSION argument (Can use: Docker build --build-arg RUNNER_VERSION=x.y.z)
RUN Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v$env:RUNNER_VERSION/actions-runner-win-x64-$env:RUNNER_VERSION.zip" -OutFile "actions-runner.zip"; \
    Expand-Archive -Path ".\\actions-runner.zip" -DestinationPath '.'

#Add GitHub runner configuration startup script
#ADD scripts/start.ps1 .
#ADD scripts/Cleanup-Runners.ps1 .
#ENTRYPOINT ["pwsh.exe", ".\\start.ps1"]