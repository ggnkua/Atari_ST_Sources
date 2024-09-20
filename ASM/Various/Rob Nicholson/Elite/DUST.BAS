100 PRINT "Creating DSIN.DAT and DCOS.DAT"
110 PRINT "------------------------------"
120 PRINT
130 OPEN "O",#1,"dsin.dat" : CLOSE #1
140 OPEN "O",#1,"dcos.dat" : CLOSE #1
150 OPEN "R",#1,"dsin.dat",2
160 OPEN "R",#2,"dcos.dat",2
170 FIELD #1,2 AS A$ : FIELD #2,2 AS B$
180 MAG=30000
190 FOR Y%=0 TO 56
200    PRINT CHR$(13);"Processing y =";Y%;
210    YS%=Y%*Y%
220    FOR X%=0 TO 127
230       D=SQR(X%*X%+YS%) : IF D=0 THEN S%=MAG : C%=MAG : GOTO 260
240       S%=INT(MAG*Y%/D)
250       C%=INT(MAG*X%/D)
260       N$=MKI$(S%) : LSET A$=RIGHT$(N$,1)+LEFT$(N$,1) : PUT #1
270       N$=MKI$(C%) : LSET B$=RIGHT$(N$,1)+LEFT$(N$,1) : PUT #2
280    NEXT
290 NEXT
300 CLOSE
310 END
