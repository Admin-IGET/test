@echo off
REM Restart UvíkOS components - terminates Java and PowerShell processes
REM This is necessary to restart the desktop environment properly
taskkill /f /im java.exe
taskkill /f /im powershell.exe
:: ----------------------

start exploreru.cmd
start C:\apps\showTaskbar.cmd
start C:\apps\hideTaskbar.cmd
cls
echo PROBIHA RESTART UVIKOS!
echo.
echo.
echo TENTO PROCES MUZE TRVAT PREZ 10 SEKUND, BUDTE TRPELIVI
echo NEZAVIREJTE TOTO OKNO
timeout 1 > nul
start C:\apps\start1.lnk
exit