@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "IMAGE=system-programming-fasm"
set "CONTAINER=system-programming-fasm"
set "WORKDIR=/system_programming"
for %%I in ("%~dp0.") do set "PROJECT_DIR=%%~fI"

where docker.exe >nul 2>&1
if errorlevel 1 (
    echo Docker CLI not found. Install Docker Desktop and reopen the terminal. >&2
    exit /b 1
)

call :ReadEngine
if defined ENGINE goto :CheckEngine

echo Starting Docker Desktop...
docker.exe desktop start --detach
if errorlevel 1 (
    echo Could not start Docker Desktop. Open it and run this script again. >&2
    exit /b 1
)

set "ATTEMPTS=0"
:WaitForEngine
call :ReadEngine
if defined ENGINE goto :CheckEngine
set /a ATTEMPTS+=1 >nul
if %ATTEMPTS% geq 60 (
    echo Docker did not become ready. Check Docker Desktop and run this script again. >&2
    exit /b 1
)
timeout /t 2 /nobreak >nul
goto :WaitForEngine

:CheckEngine
if /i not "%ENGINE:~0,6%"=="linux/" (
    echo Switch Docker Desktop to Linux containers and run this script again. >&2
    exit /b 1
)
if /i not "%ENGINE%"=="linux/x86_64" if /i not "%ENGINE%"=="linux/amd64" (
    echo GDB requires an x86-64 Linux Docker engine for this project. >&2
    exit /b 1
)

docker.exe image inspect "%IMAGE%" >nul 2>&1
if errorlevel 1 (
    echo Building the FASM environment...
    docker.exe build --platform linux/amd64 --tag "%IMAGE%" - < "%PROJECT_DIR%\Dockerfile"
    if errorlevel 1 exit /b 1
)

docker.exe container inspect "%CONTAINER%" >nul 2>&1
if not errorlevel 1 (
    docker.exe rm -f "%CONTAINER%" >nul
    if errorlevel 1 exit /b 1
)

docker.exe run -it --cap-add SYS_PTRACE --security-opt seccomp=unconfined ^
    --name "%CONTAINER%" --platform linux/amd64 ^
    --volume "%PROJECT_DIR%:%WORKDIR%" --workdir "%WORKDIR%" ^
    "%IMAGE%" /bin/bash
exit /b %errorlevel%

:ReadEngine
set "ENGINE="
for /f "delims=" %%I in ('docker.exe info --format "{{.OSType}}/{{.Architecture}}" 2^>nul') do set "ENGINE=%%I"
exit /b 0
