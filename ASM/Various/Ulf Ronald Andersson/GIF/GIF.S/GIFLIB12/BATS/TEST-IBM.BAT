@echo off
rem
rem Tests for the gif_lib utilities.
rem Usage:
rem	testgif [gif_dir] [display_prgm]
rem
rem   This test assumes the gif_lib utilities are available from one of the
rem path directorys, and that DIR is set (directly or through command line)
rem to the directory holf these gif files:
rem 1. SOLID2.GIF
rem 2. CHERYL.GIF
rem 3. PORSCHE.GIF
rem   In addition, set DISPLAY ( directly or through command line) to the
rem program to display gif files in our system.
rem   As this batch file intensively uses pipes which on msdos are saved as
rem files on CURRENT disk, it is going to be a good idea to execute this batch
rem from a ram disk.

set GIF_DIR=d:\c\gif\pic\
if not x%1 == x set GIF_DIR = %1

rem
rem Two display programs are available gif2herc for hercules monochrome device
rem and gif2bgi for any device you have bgi driver for. See the docs for these
rem programs for more.
rem
rem set GIF_DISPLAY=gif2herc
set GIF_DISPLAY=gif2bgi -u c:\tc\bgi\ati\ati.2
if not x%2 == x set GIF_DISPLAY = %2

@echo on

gifwedge | %GIF_DISPLAY%

gifbg -d tl -s 320 200 -c 255 255 255 -l 64 > bg1.gif
gifcomb %GIF_DIR%porsche.gif bg1.gif | %GIF_DISPLAY%
del bg1.gif

text2gif -f 1 -s 7 -c 0 255 0 -t "Created using the IRIT solid modeler, Gershon Elber 1990" > credit.gif
gifasm %GIF_DIR%solid2.gif credit.gif | %GIF_DISPLAY%
del credit.gif

gifhisto -t %GIF_DIR%cheryl.gif
gifhisto -b -s 200 512 %GIF_DIR%cheryl.gif | gifflip -l | %GIF_DISPLAY%

gifflip -r %GIF_DIR%solid2.gif | gifrsize | %GIF_DISPLAY%

gifinter %GIF_DIR%cheryl.gif | gifflip -x | %GIF_DISPLAY%

gifbg -d "TL" -s 320 175 -c 255 255 255 -l 64 | gifpos -s 640 350 -i   0   0 > b1.gif
gifbg -d "BL" -s 320 175 -c 255 255 255 -l 64 | gifpos -s 640 350 -i   0 175 > b2.gif
gifbg -d "TR" -s 320 175 -c 255 255 255 -l 64 | gifpos -s 640 350 -i 320   0 > b3.gif
gifbg -d "BR" -s 320 175 -c 255 255 255 -l 64 | gifpos -s 640 350 -i 320 175 > b4.gif
gifasm b1.gif b2.gif b3.gif b4.gif > backgrnd.gif
%GIF_DISPLAY% backgrnd.gif
del b?.gif
del backgrnd.gif

copy %GIF_DIR%solid2.gif s1.gif
gifrsize s1.gif > s2.gif
gifrsize s2.gif > s3.gif
gifrsize s3.gif > s4.gif
gifpos -i 320 0 s2.gif | gifinto s2.gif
gifpos -i 480 0 s3.gif | gifinto s3.gif
gifpos -i 560 0 s4.gif | gifinto s4.gif
gifasm s1.gif s2.gif s3.gif s4.gif > sall.gif
giftext sall.gif
%GIF_DISPLAY% sall.gif
gifrsize -s 0.45 sall.gif | %GIF_DISPLAY%
del s?.gif
del sall.gif

gifpos -s 720 348 -i 400 148 %GIF_DIR%porsche.gif | %GIF_DISPLAY%

gifrsize -S 300 600 %GIF_DIR%solid2.gif | %GIF_DISPLAY%

gifinter %GIF_DIR%cheryl.gif | gifrsize | %GIF_DISPLAY% -z 2

rem This is broken since it overflow the 128 chars limit:
gifinter %GIF_DIR%cheryl.gif | gifclip -i 222 0 390 134 | gifpos -s 169 135 | gifrsize -s 2.0 > t.gif
%GIF_DISPLAY% t.gif
del t.gif

gifrotat -a 45 %GIF_DIR%cheryl.gif | %GIF_DISPLAY%

@echo off

rem Remove these variables from current shell
Exit:

set GIF_DIR=
set GIF_DISPLAY=




