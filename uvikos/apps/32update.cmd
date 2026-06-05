@echo off
echo NEZAVIREJTE TOTO OKNO,
echo CEKEJTE PROSIM!
del /F /Q /S "%CD%\apps\fallback\POKUD NEJSTE VE WINDOWS, OTEVŘETE!.cmd"
del /F /Q /S C:\backup\*.*
del /F /Q /S C:\backup\settings\*.*
xcopy "C:\apps\icons.txt" "C:\backup\"
xcopy "C:\apps\settings.txt" "C:\backup\"
xcopy "C:\apps\bsettings.txt" "C:\backup\"
xcopy "C:\apps\settings\1wallpaper.png" "C:\backup\settings\"
xcopy "C:\apps\settings\1wallpaper.gif" "C:\backup\settings\"

del /F /Q /S C:\apps\*.*
del /F /Q /S C:\apps\settings\*.*
del /F /Q /S C:\apps\wallpaper\*.*
del /F /Q /S C:\apps\UvikChat\*.*
del /F /Q /S C:\apps\fallback\*.*
xcopy "%CD%\apps\*.*" "C:\apps\"
xcopy "%CD%\apps\settings\*.*" "C:\apps\settings\"
xcopy "%CD%\apps\wallpaper\*.*" "C:\apps\wallpaper\"
xcopy "%CD%\apps\UvikChat\*.*" "C:\apps\UvikChat\"
xcopy "%CD%\apps\fallback\*.*" "C:\apps\fallback\"
if not exist "C:\apps\personal\" (
xcopy "%CD%\apps\personal\*.*" "C:\apps\personal\"
)
del /F /Q /S C:\apps\settings.txt
del /F /Q /S C:\apps\settings\1wallpaper.png
del /F /Q /S C:\apps\settings\1wallpaper.gif

del /F /Q /S C:\apps\icons.txt
del /F /Q /S C:\apps\bsettings.txt
xcopy "C:\backup\*.*" "C:\apps\"
xcopy "C:\backup\settings\*.*" "C:\apps\settings\"
del /F /Q /S C:\backup\*.*
del /F /Q /S C:\backup\settings\*.*
del /F /Q /S "C:\apps\fallback\POKUD NEJSTE VE WINDOWS, OTEVŘETE!.cmd"
C:\apps\compile-install.cmd