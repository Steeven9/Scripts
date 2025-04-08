@echo off
title Backup
cls

:: Copies all the files in the specified folders and then shuts down the PC (without confirmation)
:: /XD = exclusion patterns

robocopy C:\Users\Steeven\AppData S:\Backup\AppData /MIR /NFL /NDL /R:2 /W:2 /UNILOG:C:\Users\Steeven\backup_log.txt /TEE /XD NVIDIA* AMD *cache* Temp ElevatedDiagnostics *Microsoft*

robocopy C:\Users\Steeven\Documents S:\Backup\Documents /MIR /NFL /NDL /R:2 /W:2 /UNILOG+:C:\Users\Steeven\backup_log.txt /TEE 

robocopy "C:\Users\Steeven\Saved Games" "S:\Backup\Saved Games" /MIR /NFL /NDL /R:2 /W:2 /UNILOG+:C:\Users\Steeven\backup_log.txt /TEE

shutdown /s
