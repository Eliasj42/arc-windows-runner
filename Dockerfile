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

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';$ProgressPreference='silentlyContinue';"]

#Set working directory
WORKDIR /home/runner

