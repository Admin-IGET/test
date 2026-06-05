@echo off
cd C:\apps\
c:
javac -encoding UTF-8 UvikPic.java
echo screenshot app compiled.
pause
javac Calculator.java
echo calculator compiled
pause

javac -encoding UTF-8 WiFiManager.java
echo wifi compiled
pause
javac -encoding UTF-8 ColorSettings.java
echo settings compiled
pause
javac -encoding UTF-8 ScreenSaver.java
echo screensaver compiled
pause
javac -encoding UTF-8 DBackground.java
echo wallpaper compiled
pause
javac -encoding UTF-8 cmd.java
echo cmd compiled
pause > nul
echo everything compiled. press any key to exit
pause > nul
exit

