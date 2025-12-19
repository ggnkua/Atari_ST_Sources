10   REM UNIX-Talk: šber eine Schnittstelle sich auf
20   REM geteiltem Bildschirm mit dem Partner unterhalten
30   USING$,-16:USING 0,1
40   WHILE
50     CLS:PRINT 'šber welche Schnittstelle':PRINT 'wollen Sie talken?':PRINT
60     PRINT 'MIDI',0
70     PRINT 'AUX',1
80     PRINT 'Modem 1',2
90     PRINT 'Modem 2',3
100    PRINT 'Seriell 1',4
110    PRINT 'Seriell 2',5
120    PRINT
130    INPUT a
140  WEND a>=0 AND a<=5
150  DIM dev$(5):dev$(0)='MIDI':dev$(1)='AUX':dev$(2)='MOD1'
160  dev$(3)='MOD2':dev$(4)='SER1':dev$(5)='SER2':del$=CHR$(27)+'K'
170  endl=9:endx=31:l$=CHR$ $F6
180  CLS:USING$,0:GOTOXY 0,10:FOR i=1 TO 5:l$=l$+l$:NEXT:PRINT l$;
190  u1x=0:u1y=0:u2x=0:u2y=11
200  GOTOXY 6,21:PRINT 'connected via '+dev$(a);:GOTOXY 0,0
210  WHILE
220    WHILE
230      WHILE
240        key=ASC INKEY$:in=INBYTE dev$(a)
250        IF key<>0 OR in>0 THEN 310
260      WEND PEEKL $4BA>time
270      time=PEEKL $4BA+80
280      flag=flag XOR 1
290      IF flag THEN GOTOXY u1x,u1y ELSE GOTOXY u2x,u2y
300    WEND
310    IF key=27 OR in=27 THEN CLS:END
320    IF key=0 THEN 410
330    GOTOXY u1x,u1y:PRINT del$;
340    WHILE OUTBYTE dev$(a),key<>0:WEND
350    IF key=13 THEN u1x=endx:key=10
360    PRINT CHR$(key);
370    u1x=u1x+1
380    IF key=8 THEN u1x=u1x-2:IF u1x<0 THEN u1x=0
390    IF u1x>endx THEN u1x=0:u1y=u1y+1
400    IF u1y>endl THEN u1y=0
410    IF in<0 THEN 490
420    GOTOXY u2x,u2y:PRINT del$;
430    IF in=13 THEN u2x=endx:in=10
440    PRINT CHR$(in);
450    u2x=u2x+1
460    IF in=8 THEN u2x=u2x-2:IF u2x<0 THEN u2x=0
470    IF u2x>endx THEN u2x=0:u2y=u2y+1
480    IF u2y>endl+11 THEN u2y=11
490  WEND
