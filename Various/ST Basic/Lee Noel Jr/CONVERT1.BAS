10    def seg=0:defdbl b:b=systab+20:ad=peek(b):had=ad:ntd=1
20    fullw 2:clearw 2
30    gotoxy 1,1:?"** NEO/DEGAS FILE CONVERTER **"
40    gotoxy 1,3:?"ENTER FILENAME IN UNSHIFTED LETTERS"
50    gotoxy 1,5:input">FILE FOR CONVERSION";f$:lf=len(f$)
60    if lf<5 or lf>12 then goto file
70    sf$=right$(f$,4):if sf$<>".neo" and sf$<>".pi1" then goto file
80    if sf$=".pi1" then ad=ad+94:ntd=0
90    ?"**LOADING...":bload f$,ad
100   ?"**CONVERTING...":def seg=had:if ntd then goto ntod
110   su$=".neo":ad=had:size=32128:for i=0 to 3:poke i,0:next
120   for i=4 to 35:poke i,peek(92+i):next:goto saver
130   ntod:su$=".pi1":ad=had+94:size=32034
140   for i=0 to 33:poke i+94,peek(i+2):next
150   saver:lf=lf-4:f$=left$(f$,lf)+su$:?"**SAVING "f$"..."
160   bsave f$,ad,size
170   ?">>CONVERT ANOTHER FILE (Y/N)":kp=inp(2):kp=kp+(kp>90)*32
180   if kp=89 then goto 10
190   done:?"**THIS RUN COMPLETED":end
200   file:clearw 2:gotoxy 0,1:?"**BAD FILENAME!"
210   ?"**CHECK IT, THEN RERUN PROGRAM":goto done
