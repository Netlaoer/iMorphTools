@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0iMorphReloader.ps1"
if %errorlevel% neq 0 pause
