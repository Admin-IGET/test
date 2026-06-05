@echo off
title UvikOS_Main_Window-UvikOSHideCode:ABCDEFG78946-6-6-99-DO-NOT-CLOSE
start C:\apps\background.lnk
start C:\apps\banner.lnk
start "" "C:\apps\waitscr.exe" /loading
del C:\edit\ran.txt /q > nul

powershell -NoProfile -ExecutionPolicy RemoteSigned -File "C:\apps\panel.ps1"

if not exist "C:\edit\ran.txt" (
    taskkill /f /im waitscr.exe
    start "" "C:\apps\errorscreen.exe"
)
exit