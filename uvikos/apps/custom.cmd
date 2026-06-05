@echo off
echo NEZAVIREJTE TOTO OKNO,MINIMALIZUJTE HO!!
rd C:\internet /s /q
rd C:\edit /s /q
mkdir C:\edit\
mkdir C:\internet\
xcopy C:\apps\uvik.png C:\edit\
xcopy C:\apps\shutdown.png C:\edit\
xcopy C:\apps\settings.png C:\edit\
xcopy C:\apps\sound.png C:\edit\
xcopy C:\apps\apps2.png C:\edit\
xcopy C:\apps\start.png C:\edit\
xcopy C:\apps\startbig.png C:\edit\
xcopy C:\apps\internet.cmd C:\internet\
xcopy C:\apps\internet.lnk C:\internet\
echo fat > C:\edit\big.txt
echo snap > C:\edit\grid.txt
del "C:\apps\fallback\POKUD NEJSTE VE WINDOWS, OTEVŘETE!.cmd" /s /q