DIM chart(300000, 23)
DIM numbers(50)
DIM numb(50)
DIM totalnumbers(100)
DIM linecounter(1000000)
ON erro GOTO fini
CLS
PRINT
INPUT "How many winning numbers in your Lottery : ", numbers
INPUT "How many total numbers in your Lottery : ", totalnumbers
PRINT
PRINT "Data Filename must have all numbers in it."
PRINT "No short foorms such as Jan or January."
PRINT
PRINT "You must change these to numbers with a"
PRINT "Word processor before using this program."
PRINT
PRINT "To make it easy to conver this data file"
PRINT "Data file must be called lotto.dat "
PRINT
PRINT "Data File Out can be called anything you"
PRINT "Desire: It does not matter."

IF fileout$ = "" THEN GOTO fini
filein$ = "lotto.dat"
fileout$ = "default.dat"
OPEN filein$ FOR INPUT AS #1
OPEN fileout$ FOR OUTPUT AS #2
linecounter = 2360
FOR iii = 1 TO linecounter
    FOR zzz = 1 TO numbers
        LINE INPUT #1, A$
        month = VAL("mid$(A$,1,2)")
        day = VAL("mid$(A$,4,5)")
        year = VAL("mid$(a$,7,10)")
        chart(linecounter, 1) = month
        chart(linecounter, 2) = day
        chart(linecounter, 3) = year
        GOSUB build
        chart(linecounter, ttt) = numbers(ttt)
    NEXT zzz
    build:
    FOR ttt = 1 TO numbers
        numbers(ttt) = VAL("mid$(A$,(11+vvv),(11+vvv+3)")
        vvv = vvv + 1
    NEXT ttt
    FOR ppp = 1 TO numbers
        chart(linecounter, (ppp + 3)) = numbers(ttt)
    NEXT ppp

    FOR ddd = 1 TO numbers
        PRINT chart(linecounter, ddd)
    NEXT ddd
NEXT iii
PRINT "Press any key to continue"
DO WHILE INKEY$ = ""
LOOP
CLS

pattern1$ = "## ## #### ## ## ## ## ## ## ## ## ## ## ##"
pattern1$ = "           ## ## ## ## ## ## ## ## ## ## ##"
FOR iii = 1 TO 2360
    FOR jjj = 1 TO numbers
        PRINT chart(iii, jjj);
    NEXT jjj
    PRINT
NEXT iii
GOTO closeall
fini:
PRINT
PRINT "lotto.dat not found ! Copy your input data file to lotto.dat"
PRINT "Then rerun this program again."

PRINT
PRINT "Press a key to continue."
CLOSE #1
DO WHILE INKEY$ = ""
LOOP
GOTO endit
closeall:
PRINT "Success, you file is written correctly !!!!!!!!!!!!!!!!!!!!!!!!!!"
PRINT
PRINT "Press any key to continue."
DO WHILE INKEY$ = ""
    endit:
LOOP
CLOSE #2





