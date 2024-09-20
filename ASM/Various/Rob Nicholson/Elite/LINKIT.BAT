@echo off
tm start/n/c1
qlink f:elite=elite
tm stop/n/c1
echo Link >> c:\sys\public\timelog
tm stop/c1/log/l >> c:\sys\public\timelog
