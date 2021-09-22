10    on error goto 460:u$=string$(34,45):skip=0
20    fullw 2:clearw 2:if peek(systab)<>4 then goto rezok
30    ?"RUN THIS IN MEDIUM OR HIGH RESOLUTION":goto done
40    rezok:gotoxy 1,3:?"DISK SWAPS NEEDED?  PRESS Y/N":gosub yn
50    if kp$="N" then skip=1
60    def seg=0:defdbl b:b=systab+20:ad=peek(b):had=ad:ntd=1
70    clearw 2:gotoxy 1,3:?"** NEO/DEGAS.CCC FILE CONVERTER **"
80    gotoxy 1,4:?u$:input"  >FILE FOR CONVERSION";f$:lf=len(f$)
90    if lf<5 or lf>12 then goto file
100   ui$=f$:gosub cap:f$=uo$:s$=right$(f$,4):r=7
110   if s$=".NEO"or s$=".PI1"or s$=".PI2"or s$=".PI3"then goto ok
120   goto file
130   ok:if not s$=".NEO" then ad=ad+94:ntd=0
140   gotoxy 0,r:?"**LOAD "f$:r=r+1:gosub disk:bload f$,ad
150   lf=lf-4:gosub id:def seg=had:if ntd then goto ntod
160   ?"**CONVERTING":r=r+1:for i=0 to 1:poke i,0:next
170   for i=2 to 35:poke i,peek(92+i):next:ad=had+36
180   cf$=f$+".CCC":bload cf$,ad
190   ?"**LOAD "cf$:r=r+1:gosub active:lf=lf-1:gosub id:lf=lf+1
200   su$="X.NEO":ad=had:size=32128:gosub saver:goto more
210   nfile:su$=".NEO":ad=had:size=32128:gosub saver:goto more
220   ntod:su$=".CCC":ad=had+36:size=92:gosub saver
230   ?"**CONVERTING":r=r+1
240   for i=0 to 33:poke i+94,peek(i+2):next
250   i=3:rez=peek(i):rez=rez+1:rez$=str$(rez):rez$=right$(rez$,1)
260   gosub id:su$=".PI"+rez$:ad=had+94:size=32034:gosub saver
270   goto more
280   file:clearw 2:gotoxy 0,1:?"**BAD FILENAME!"
290   gotoxy 0,2:?"**PRESS ANY KEY TO TRY AGAIN":gosub key:goto 60
300   cap:ul=len(ui$):uo$="":for uk=1 to ul:code=asc(mid$(ui$,uk,1))
310   uo$=uo$+chr$((code>90)*32+code):next:return
320   key:kp=inp(2):return
330   yn:gosub key:kp$=chr$(kp):ui$=kp$:gosub cap:kp$=uo$
340   if kp$<>"Y" and kp$<>"N" then goto yn else return
350   id:f$=left$(f$,lf):return
360   saver:f$=f$+su$:?"**SAVE "f$:r=r+1
370   if ntd=0 or su$=".CCC" then gosub disk
380   gosub active:bsave f$,ad,size:return
390   more:?:?">>CONVERT ANOTHER FILE?":?">>PRESS Y/N"
400   gosub yn:if kp$="Y" then goto 60 else goto done
410   done:?:?"RUN COMPLETED:ANY KEY EXITS":gosub key:end
420   disk:if skip then goto noswap
430   gotoxy 0,r:?">WAITING FOR DISK:PRESS ANY KEY WHEN READY"
440   gosub key:gotoxy 0,r:?spc(42)
450   noswap:gosub active:gotoxy 0,r:return
460   if err=53 and erl=180 then resume 210:rem trap errors
470   clearw 2:?tab(6);"ERROR NUMBER"err:?tab(8);"IN LINE"erl
480   ?tab(4);"PRESS Y TO TRY AGAIN":?tab(6);"PRESS N TO STOP"
490   gosub yn:if kp$="Y" then resume 60 else goto done
500   active:r=r-1:gotoxy 20,r:?"<ACTIVATED":r=r+1:return
