@echo off
title UvikOS_Main_Window-UvikOSHideCode:ABCDEFG78946-6-6-99-DO-NOT-CLOSE
echo NEZAVIREJTE TOTO OKNO,
echo CEKEJTE PROSIM.
echo POKUD NEMIZI, MINIMALIZUJTE HO.
start C:\apps\start1.lnk
ping 1 > nul
powershell -windowstyle hidden -c (New-Object Media.SoundPlayer 'C:\apps\startup.wav').PlaySync();
exit