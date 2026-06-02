@echo off
REM Run all k6 stress test scenarios sequentially with JSON reports
REM Usage: run-all.bat [AI_SERVICE_URL]
REM Example: run-all.bat http://localhost:8000

setlocal enabledelayedexpansion

set "URL=%~1"
if "%URL%"=="" set "URL=http://localhost:8000"

set "TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "RESULTS_DIR=results_%TIMESTAMP%"

mkdir "%RESULTS_DIR%" 2>nul

echo ============================================================
echo  Tranquara AI Service - k6 Stress Test Suite
echo  Target: %URL%
echo  Results: %RESULTS_DIR%\
echo  Time: %date% %time%
echo ============================================================
echo.

REM ===== Scenario 1: Smoke Test =====
echo [1/6] Running Smoke Test (1 VU)...
k6 run -e AI_SERVICE_URL=%URL% --out json=%RESULTS_DIR%/smoke.json smoke.js
if !errorlevel! equ 0 (
    echo   [PASS] Smoke Test completed
) else (
    echo   [WARN] Smoke Test had issues (exit code: !errorlevel!)
)
echo.

REM ===== Scenario 2: Light Load =====
echo [2/6] Running Light Load Test (10 VUs, 30s)...
k6 run -e AI_SERVICE_URL=%URL% --out json=%RESULTS_DIR%/light-load.json light-load.js
if !errorlevel! equ 0 (
    echo   [PASS] Light Load Test completed
) else (
    echo   [WARN] Light Load Test had issues (exit code: !errorlevel!)
)
echo.

REM ===== Scenario 3: Medium Load =====
echo [3/6] Running Medium Load Test (25 VUs, 60s)...
k6 run -e AI_SERVICE_URL=%URL% --out json=%RESULTS_DIR%/medium-load.json medium-load.js
if !errorlevel! equ 0 (
    echo   [PASS] Medium Load Test completed
) else (
    echo   [WARN] Medium Load Test had issues (exit code: !errorlevel!)
)
echo.

REM ===== Scenario 4: Heavy Load =====
echo [4/6] Running Heavy Load Test (50 VUs, 120s)...
k6 run -e AI_SERVICE_URL=%URL% --out json=%RESULTS_DIR%/heavy-load.json heavy-load.js
if !errorlevel! equ 0 (
    echo   [PASS] Heavy Load Test completed
) else (
    echo   [WARN] Heavy Load Test had issues (exit code: !errorlevel!)
)
echo.

REM ===== Scenario 5: Spike Test =====
echo [5/6] Running Spike Test (50 VUs burst)...
k6 run -e AI_SERVICE_URL=%URL% --out json=%RESULTS_DIR%/spike.json spike-test.js
if !errorlevel! equ 0 (
    echo   [PASS] Spike Test completed
) else (
    echo   [WARN] Spike Test had issues (exit code: !errorlevel!)
)
echo.

REM ===== Scenario 6: Sustained Load =====
echo [6/6] Running Sustained Load Test (10 VUs, 5 min)...
k6 run -e AI_SERVICE_URL=%URL% --out json=%RESULTS_DIR%/sustained.json sustained-load.js
if !errorlevel! equ 0 (
    echo   [PASS] Sustained Load Test completed
) else (
    echo   [WARN] Sustained Load Test had issues (exit code: !errorlevel!)
)
echo.

echo ============================================================
echo  All tests completed!
echo  JSON results saved to: %RESULTS_DIR%\
echo.
echo  To analyze results, use:
echo    k6 run --summary-output=report.html (for HTML summary)
echo    Or import JSON files into Grafana/j6 dashboard
echo ============================================================

endlocal