d:
GEM ON
PATH d:\bt

:start
cd d:\bt
newfont
if ERRORLEVEL 192 goto bbs192
if ERRORLEVEL 144 goto bbs144
if ERRORLEVEL 120 goto bbs120
if ERRORLEVEL 96 goto bbs96
if ERRORLEVEL 90 goto mail
if ERRORLEVEL 80 goto arcmail
if ERRORLEVEL 72 goto bbs72
if ERRORLEVEL 70 goto ndiff
if ERRORLEVEL 60 goto bakevn
if ERRORLEVEL 65 goto bakodd
if ERRORLEVEL 50 goto pollhub
if ERRORLEVEL 48 goto bbs48
if ERRORLEVEL 30 goto update
if ERRORLEVEL 24 goto bbs24
if ERRORLEVEL 20 goto renum
if ERRORLEVEL 12 goto bbs12
if ERRORLEVEL 10 goto fido
if ERRORLEVEL 3 goto bbs3

exit

:bbs192
cd d:\stk
bbs -B19200
goto bbs

:bbs144
cd d:\stk
bbs -B14400
goto bbs

:bbs120
cd d:\stk
bbs -B12000
goto bbs

:bbs96
cd d:\stk
bbs -B9600
goto bbs

:bbs72
cd d:\stk
bbs -B7200
goto bbs

:bbs48
cd d:\stk
bbs -B4800
goto bbs

:bbs24
cd d:\stk
bbs -B2400
goto bbs

:bbs12
cd d:\stk
bbs -B1200
goto bbs

:bbs3
cd d:\stk
bbs -B300
goto bbs


:bbs
cd d:\bt
BTPACK -B
scan -T -P
PACK -T -A D:\BT\ARC.TTP m
BTPACK -T
goto start

:renum
cd d:\stk\bin
fdrenum
goto start

:fido
cd d:\stk\bin
fidodoor -LO -NAME Tom Smythe -TL 99 -UL 32766
CD D:\BT
BTPACK -B
SCAN -T -P
PACK -T -A D:\BT\ARC.TTP m
BTPACK -T
goto start

:pollhub
makebink POLL 1:999/1
goto start

:ndiff
cd d:\bt\inb
if EXISTS nodediff.a?? goto parse
goto start

:parse
arc xo nodediff.a?? d:\bt\nl\*.*
cd d:\bt\nl
parselst
goto start

:mail
BTPACK -B -V
import -P -T
scan -T -P
pack -T
BTPACK -T -V
cd d:\stk\bin
fdrenum NORENUM
goto start

:arcmail
BTPACK -B
import -P -T -A D:\BT\ARC.TTP x

scan -T -P
PACK -T -A D:\BT\ARC.TTP m
BTPACK -T -V
cd d:\stk\bin
fdrenum NORENUM
goto start

:bakevn
cd d:\bt
lharc u f:\STK_BAK\EVEN.LZH d:\stk\*.sys
lharc u f:\STK_BAK\EVEN.LZH d:\stk\bin\fidodoor.cfg
lharc u f:\STK_BAK\EVEN.LZH d:\stk\bin\fidodoor.cbk
lharc u f:\STK_BAK\EVEN.LZH d:\stk\bin\fidodoor.usr
lharc u f:\STK_BAK\EVEN.LZH areas.bbs
lharc u f:\STK_BAK\EVEN.LZH *.cfg
lharc u f:\STK_BAK\EVEN.LZH *.evt
lharc u f:\STK_BAK\EVEN.LZH *.rte
goto update

:bakodd
cd d:\bt
lharc u f:\STK_BAK\ODD.LZH d:\stk\*.sys
lharc u f:\STK_BAK\ODD.LZH d:\stk\bin\fidodoor.cfg
lharc u f:\STK_BAK\ODD.LZH d:\stk\bin\fidodoor.cbk
lharc u f:\STK_BAK\ODD.LZH d:\stk\bin\fidodoor.usr
lharc u f:\STK_BAK\ODD.LZH areas.bbs
lharc u f:\STK_BAK\ODD.LZH *.cfg
lharc u f:\STK_BAK\ODD.LZH *.evt
lharc u f:\STK_BAK\ODD.LZH *.rte
goto update

:update
cd d:\stk\bin
fdrenum
cd d:\stk\today195
todays
cd d:\stk
wizfile
cd d:\bt
lharc u e:\general\allfiles.lzh e:\general\allfiles.txt
lharc u e:\general\newfiles.lzh e:\general\newfiles.txt
arc u e:\general\allfiles.arc e:\general\allfiles.txt
arc u e:\general\newfiles.arc e:\general\newfiles.txt
sortie sortie.dat
goto start

