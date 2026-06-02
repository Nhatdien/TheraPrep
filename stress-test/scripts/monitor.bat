@echo off
REM Monitoring script for Tranquara AI Service during stress tests
REM Run this in a separate terminal before starting tests

echo ============================================================
echo  Tranquara Stress Test Monitor
echo  Press Ctrl+C to stop
echo ============================================================
echo.

:loop
echo [%date% %time%] === System Status ===

REM Check AI service health
echo.
echo [AI Service Healthcheck]
curl -s http://localhost:8000/healthcheck 2>nul
if %errorlevel% neq 0 (
    echo   FAILED - AI service not responding!
)

REM Check Qdrant
echo.
echo [Qdrant Status]
curl -s http://localhost:6333/collections 2>nul | python -m json.tool 2>nul
if %errorlevel% neq 0 (
    echo   FAILED - Qdrant not responding!
)

REM Docker resource usage
echo.
echo [Docker Container Resources]
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" 2>nul

echo.
echo ----------------------------------------
timeout /t 10 /nobreak >nul
goto loop