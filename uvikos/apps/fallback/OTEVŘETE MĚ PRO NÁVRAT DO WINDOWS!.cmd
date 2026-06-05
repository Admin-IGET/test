@echo off
echo STISKNETE JAKOUKOLIV KLAVESU PRO NAVRAT DO WINDOWS...
pause > nul
echo.
echo.
echo CEKEJTE PROSIM...
start explorer.exe
start C:\apps\fallbackwindow.lnk
timeout 3 > nul
ping 1 > nul
cls
echo DOUFAM ZE JSTE VE WINDOWS.
exit
