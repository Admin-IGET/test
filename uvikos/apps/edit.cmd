@echo off
echo NEZAVIREJTE TOTO OKNO,MINIMALIZUJTE HO!!
if not exist "C:\internet\internet.cmd" (

    rd C:\internet /s /q
    mkdir C:\internet\
    xcopy C:\apps\internet.cmd C:\internet\
    xcopy C:\apps\internet.lnk C:\internet\
)
if not exist "C:\edit\startbig.png" (

    del C:\edit\startbig.png /s /q
    xcopy C:\apps\startbig.png C:\edit\
)

if not exist "C:\edit\apps2.png" (

    del C:\edit\apps2.png /s /q
    xcopy C:\apps\apps2.png C:\edit\
)

if not exist "C:\edit\personal\" (
    xcopy "C:\apps\personal\*.*" "C:\edit\personal\" /E /I /Y
)
rd C:\custom /s /q
mkdir C:\custom\
xcopy C:\edit\uvik.png C:\custom\
xcopy C:\edit\shutdown.png C:\custom\
xcopy C:\edit\settings.png C:\custom\
xcopy C:\edit\start.png C:\custom\
xcopy C:\edit\startbig.png C:\custom\
xcopy C:\edit\sound.png C:\custom\
xcopy C:\edit\apps2.png C:\custom\
del "C:\apps\fallback\POKUD NEJSTE VE WINDOWS, OTEVŘETE!.cmd" /s /q
del "C:\apps\wallpaper\WALLPAPER - 1.png"
del "C:\apps\wallpaper\WALLPAPER - 2.JPG"
del "C:\apps\wallpaper\WALLPAPER - 3.JPG"
del "C:\apps\wallpaper\WALLPAPER - 4.JPG"
del "C:\apps\wallpaper\WALLPAPER - 5.JPG"
del "C:\apps\wallpaper\WALLPAPER - 6.JPG"
del "C:\apps\wallpaper\WALLPAPER - 7.JPG"
del "C:\apps\wallpaper\WALLPAPER - 8.JPG"
del "C:\apps\wallpaper\WALLPAPER - 9.JPG"
del "C:\apps\wallpaper\WALLPAPER -10.JPG"
del "C:\apps\wallpaper\WALLPAPER -11.JPG"
del "C:\apps\wallpaper\WALLPAPER -12.JPG"
