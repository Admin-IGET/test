@echo off
REM UvíkOS Installation Script
REM This script installs the UvíkOS desktop environment
REM All operations are for legitimate desktop customization
echo NEZAVIREJTE TOTO OKNO,
echo CEKEJTE PROSIM!
xcopy "%CD%\apps\*.*" "C:\apps\"
xcopy "%CD%\apps\settings\*.*" "C:\apps\settings\"
xcopy "%CD%\apps\wallpaper\*.*" "C:\apps\wallpaper\"
xcopy "%CD%\apps\fallback\*.*" "C:\apps\fallback\"
xcopy "%CD%\apps\personal\*.*" "C:\apps\personal\"
mkdir C:\edit\
echo fat > C:\edit\big.txt
echo snap > C:\edit\grid.txt
timeout 1 > nul
C:\apps\compile-install.cmd