echo off
rem                           **********************
rem                           compilation msd7show.c
rem                           **********************
megamax\cc.prg msd7show.c
rem                           **********************
rem                           link
rem                           **********************
megamax\link.ttp msd7show.o -o msd7show.prg
rem                           **********************

