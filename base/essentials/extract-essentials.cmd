@echo off
7zip\x86\7za.exe x 7zip.7z -o%~dp0\7zip -y
del %~dp0\7zip.7z
del %~dp0\extract-essentials.cmd