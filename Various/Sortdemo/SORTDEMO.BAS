1     REM Basic version on Selection sort
10    MAXSIZE% = 20
20    DIM Numbers%(MAXSIZE%),SortedNumbers%(MAXSIZE%)
30    FOR x% = 0 TO MAXSIZE%
40       Numbers%(x%) = RND * 200
50    NEXT x%
60    GOSUB SELECTSORT:FULLW 2:CLEARW 2
70    PRINT "       UNSORTED NUMBERS    ","         SORTED NUBMERS"
80    FOR x% = 0 TO MAXSIZE%
90       PRINT ,Numbers%(x%),"     ",SortedNumbers%(x%)
100   NEXT x%
110   INPUT A$
120   END
200   SELECTSORT:
210   FOR x% = 0 TO MAXSIZE%
220      SortedNumbers%(x%) = Numbers%(x%)
230   NEXT x%
240   FOR x% = 0 TO MAXSIZE%-1
250      FOR y% = x%+1 TO MAXSIZE%
260         IF SortedNumbers%(x%) < SortedNumbers%(y%) THEN GOTO 300
270            temp% = SortedNumbers%(x%)
280            SortedNumbers%(x%) = SortedNumbers%(y%)
290            SortedNumbers%(y%) = temp%
300      NEXT y%
310   NEXT x%
320   RETURN
