@echo off
copy c:\sys\batch\elite.bat > nul
copy c:\fastback\stelite.fb > nul
pkzip -u stelite
fb @stelite
