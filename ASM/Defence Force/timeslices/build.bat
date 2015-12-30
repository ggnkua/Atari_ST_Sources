::
:: http://sun.hasenbraten.de/vasm/index.php?view=tutorial
:: http://sun.hasenbraten.de/vasm/release/vasm.html
::
del monodemo.prg
::vasmm68k_mot_win32.exe -Ftos -monst -x -o monodemo.prg monodemo.s
vasm.exe -m68000 -Ftos -noesc -no-opt -o monodemo.prg monodemo.s

del timslces.prg
upx-3.03 --ultra-brute monodemo.prg -o timslces.prg
copy timslces.prg C:\svn\public\atari\demos\defenceforce\TimeSlices\Final\fixed.prg


pause
