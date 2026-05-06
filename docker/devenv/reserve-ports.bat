@echo off
REM ---------------------------------------------------------------------------
REM Reserves all Windows host ports that docker/devenv/docker-compose.yaml
REM publishes, so that Hyper-V's HNS service does not dynamically claim them
REM and break "docker compose up" with:
REM   "ports are not available: ... /forwards/expose returned unexpected status"
REM
REM Run ONCE as Administrator. Reservations persist across reboots.
REM ---------------------------------------------------------------------------

setlocal

REM --- elevation check -------------------------------------------------------
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator.
    echo Right-click reserve-ports.bat and choose "Run as administrator".
    pause
    exit /b 1
)

echo Stopping WinNAT so port exclusions can be modified...
net stop winnat /y >nul 2>&1

echo.
echo Reserving TCP ports used by docker-compose.yaml...
call :reserveTcp 1080  1   "mailer (mailcatcher web UI)"
call :reserveTcp 3447  4   "penpot devenv 3447-3450"
call :reserveTcp 4200  3   "plugins 4200-4202"
call :reserveTcp 4400  4   "MCP 4400-4403"
call :reserveTcp 6006  1   "storybook"
call :reserveTcp 6060  5   "penpot 6060-6064"
call :reserveTcp 9000  2   "minio 9000-9001"
call :reserveTcp 9090  2   "penpot 9090-9091"
call :reserveTcp 10234 1   "Serena MCP server"
call :reserveTcp 10389 1   "ldap"
call :reserveTcp 10636 1   "ldap (TLS)"
call :reserveTcp 24282 1   "Serena dashboard"

echo.
echo Reserving UDP ports used by docker-compose.yaml...
call :reserveUdp 3449  1   "penpot devenv UDP 3449"

echo.
echo Starting WinNAT...
net start winnat >nul 2>&1

echo.
echo --- Current TCP exclusions ------------------------------------------------
netsh interface ipv4 show excludedportrange protocol=tcp
echo.
echo --- Current UDP exclusions ------------------------------------------------
netsh interface ipv4 show excludedportrange protocol=udp

echo.
echo Done. If any range above shows "Access is denied" or a conflict, re-run
echo this script after a reboot - HNS will have released the conflicting range.
pause
exit /b 0

REM --- helpers ---------------------------------------------------------------
:reserveTcp
echo   TCP %~1 (+%~2)  -- %~3
netsh int ipv4 add excludedportrange protocol=tcp startport=%~1 numberofports=%~2 >nul 2>&1
if %errorLevel% neq 0 (
    echo     [skipped or already reserved]
)
exit /b 0

:reserveUdp
echo   UDP %~1 (+%~2)  -- %~3
netsh int ipv4 add excludedportrange protocol=udp startport=%~1 numberofports=%~2 >nul 2>&1
if %errorLevel% neq 0 (
    echo     [skipped or already reserved]
)
exit /b 0
