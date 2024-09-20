100 REM Build CHRSET.M68 from Grafix Editor .SHP file.
110 INP.FILE$="elite_ch.shp"
120 OUT.FILE$="chrset.m68"
130 DIM CH%(255,7)
131 PRINT "Reading data .. ";
140 OPEN "R",#1,INP.FILE$,1
150 FIELD #1,1 AS BR$
160 ' Skip ID header
170 GET #1 : IF ASC(BR$) THEN 170
180 'REPEAT
190    ' Read no. bytes in record
200    GOSUB 900 : NB=N : IF NB=0 THEN 450
210    ' Skip record if linked.
220    GET #1 : FLAGS=ASC(BR$)
230    IF NOT ((FLAGS AND 2)=2) THEN 260
240       FOR I=1 TO NB-1 : GET #1 : NEXT I
250       GOTO 430
260    'ELSE
270       ' Read width and depth.
280       GOSUB 900 : WID=INT(N/16)
290       GOSUB 900 : DEP=INT(N/8)
300       NB=NB-5
310       ' Read name of shape.
320       SHAPE$=""
330       GET #1 : NB=NB-1 : IF ASC(BR$) THEN SHAPE$=SHAPE$+BR$ : GOTO 330
340       IF NOT (LEFT$(SHAPE$,2)="CH") THEN 400
350          ' Skip colour data.
360          FOR I=1 TO 4 : GET #1 : NEXT
370          ' Read bit map bytes.
371          CH=VAL("&H"+MID$(SHAPE$,3))
380          FOR I=0 TO 7 : GET #1 : CH%(CH,I)=ASC(BR$) : NEXT
390          GOTO 420
400       'ELSE
410          FOR I=1 TO NB : GET #1 : NEXT
420       'ENDIF
430    'ENDIF
440 GOTO 180
450 CLOSE
460 ' Write character set file.
461 PRINT "Writing .. ";
470 OPEN "O",#1,OUT.FILE$
480 PRINT #1,"elite_chrset:" : PRINT #1,
490 T$=""
500 FOR CH=0 TO 127
510    FOR I=0 TO 7 : N=CH%(CH,I) : GOSUB 800 : NEXT I
520 NEXT CH
530 PRINT #1,T$
540 CLOSE
541 PRINT "Done.";
550 END
800 ' Write DB byte to file.
810 N$=HEX$(N) : N$="$"+STRING$(2-LEN(N$),"0")+N$
820 IF LEN(T$+N$)>70 THEN PRINT #1,T$ : T$=""
830 IF T$="" THEN T$="    db " ELSE T$=T$+","
840 T$=T$+N$
850 RETURN
900 '
910 ' Read word from file.
920 '
930 GET #1 : LO$=BR$ : GET #1 : HI$=BR$ : N=CVI(LO$+HI$)
940 RETURN
