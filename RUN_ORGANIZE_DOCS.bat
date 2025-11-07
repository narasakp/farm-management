@echo off
echo ================================================
echo Farm Management - Document Organization
echo ================================================
echo.
echo This will organize all .md files into:
echo   1. docs_project_specific (Farm Management only)
echo   2. docs_reusable_knowledge (General knowledge)
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause > nul

powershell -ExecutionPolicy Bypass -File organize-docs-fast.ps1

echo.
echo ================================================
echo Done! Check the new folders:
echo   - docs_project_specific/
echo   - docs_reusable_knowledge/
echo ================================================
echo.
pause
