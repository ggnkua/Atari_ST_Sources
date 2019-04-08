CLS
PRINT
INPUT "User Name For Program: ", reg$
reg3$ = "00000-00000-00000-00000-00000"
FOR i = 1 TO 29
    RANDOMIZE TIMER
    counter4 = INT(RND(1) * 10)
    MID$(reg3$, i, i) = CHR$(counter4 + 48)
NEXT i
MID$(reg3$, 6, 6) = CHR$(45)
MID$(reg3$, 12, 12) = CHR$(45)
MID$(reg3$, 18, 18) = CHR$(45)
MID$(reg3$, 24, 24) = CHR$(45)
username$ = reg$
userserial$ = reg3$
counter4 = 0
FOR i = 1 TO LEN(reg$)
    counter4 = counter4 + 5.2190352875
    z2 = ASC(MID$(reg$, i, i))
    MID$(reg$, i, i) = CHR$(z2 + counter4)
NEXT i
OPEN "dname.dat" FOR OUTPUT AS #1
PRINT #1, reg$
CLOSE #1
counter4 = 0
FOR i = 1 TO LEN(reg3$)
    counter4 = counter4 + 5.4132856934
    z2 = ASC(MID$(reg3$, i, i))
    MID$(reg3$, i, i) = CHR$(z2 + counter4)
NEXT i
OPEN "reg.dat" FOR OUTPUT AS #1
PRINT #1, reg3$
CLOSE #1
finish:
END

