@echo off
echo Starting HTX Agri Development Environment...

echo.
echo Starting Backend...
start "Backend Server" cmd /k "cd backend && python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"

echo.
echo Waiting for backend to start...
timeout /t 3 /nobreak > nul

echo.
echo Starting Frontend...
start "Frontend Server" cmd /k "cd frontend && npm run dev"

echo.
echo Development environment started!
echo Backend: http://localhost:8000
echo Frontend: http://localhost:5173
echo API Docs: http://localhost:8000/docs

pause
