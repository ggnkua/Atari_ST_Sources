DIM chart(300000, 23)
DIM linecounter(1000000)
OPEN "keno midday.dat" FOR INPUT AS #1
OPEN "kenomidday.dat" FOR OUTPUT AS #2
INPUT "How many numbers in your Lottery : ", numbers
ON ERROR GOTO nextpart
FOR iii = i TO linecounter
    FOR zzz = 1 TO numbers
        INPUT #1, z
        chart(linecounter, zzz) = z
    NEXT zzz
    linecounter = linecounter + 1
    PRINT "Building Line "; linecounter; " of array"

NEXT iii
nextpart:
PRINT linecounter
FOR iii = linecounter TO 1 - 1
    FOR aaa = 1 TO 3
        pattern1$ = "## "
        PRINT USING pattern$; chart(linecounter, aaa);
        pattern2$ = "#### "
        PRINT USING pattern2$; chart(linecounter, aaa);
        pattern3$ = "##  "
        PRINT USING pattern3$; chart(linecounter, aaa);
    NEXT aaa
    FOR sss = 1 TO numbers
        pattern4$ = "## "
        PRINT USING pattern4$; chart(linecounter, numbers);
    NEXT sss
    PRINT
    linecounter = linecounter - 1

NEXT iii
CLOSE #2





