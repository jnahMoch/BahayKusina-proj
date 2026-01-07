@echo off
echo ========================================
echo  Push to GitHub - Bahay Kusina Project
echo ========================================
echo.
echo Repository: https://github.com/jnahMoch/BahayKusina-proj.git
echo.
echo This will push ALL files including Firebase keys!
echo.
pause
echo.
echo Pushing to GitHub...
echo.
git push origin main
echo.
if %ERRORLEVEL% EQU 0 (
    echo.
    echo SUCCESS! Your code is now on GitHub.
    echo Visit: https://github.com/jnahMoch/BahayKusina-proj
) else (
    echo.
    echo PUSH FAILED! You may need to:
    echo 1. Install GitHub CLI: https://cli.github.com/
    echo 2. Run: gh auth login
    echo 3. Then run this script again
)
echo.
pause
