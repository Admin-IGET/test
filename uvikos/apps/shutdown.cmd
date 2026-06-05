@echo off
echo NEZAVIREJTE TOTO OKNO,
echo CEKEJTE PROSIM.
@cd C:\apps
C:
taskkill /f /im powershell.exe
start explorer1.cmd 

timeout 5 > nul
exit

