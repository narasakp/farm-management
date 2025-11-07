@echo off
echo Starting Frontend Server on Port 8096...
python -m http.server 8096 --directory build/web
pause
