100 OPEN "I",#1,"common.m68"
101 OPEN "O",#2,"common.pak"
110 WHILE NOT EOF(1)
120    LINE INPUT #1,A$
130    P=INSTR(A$,CHR$(9))
140    WHILE P : GOSUB 210 : P=INSTR(P+1,A$,CHR$(9)) : WEND
150    IF MID$(A$,40,1)=" " THEN A$=LEFT$(A$,39)
160    WHILE RIGHT$(A$,1)=" " : A$=LEFT$(A$,LEN(A$)-1) : WEND
170    IF A$="" OR LEFT$(A$,1)="*" THEN 190
171    P=INSTR(A$,"  ")
172    WHILE P : A$=LEFT$(A$,P)+MID$(A$,P+2) : P=INSTR(P,A$,"  ") : WEND
180    PRINT A$ : PRINT #2,A$
190 WEND
200 END
210 N=(INT((P-1)/8)+1)*8-P+1
220 A$=LEFT$(A$,P-1)+SPACE$(N)+MID$(A$,P+1)
230 RETURN
