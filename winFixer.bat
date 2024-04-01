@echo off
title WinFixer
cls
echo Fixing stuff...

chkdsk /r

sfc /scannow

dism /online /cleanup-image /restorehealth

echo Done!
pause
