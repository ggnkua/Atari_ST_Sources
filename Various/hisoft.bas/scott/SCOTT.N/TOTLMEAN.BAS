REM            
REM                 TOTALMEAN
REM
n=0
c=0
t=0
m=0
PRINT "                 TOTAL/MEAN     Enter -0 to stop. "
REPEAT one
INPUT "Enter next number ";n
IF n=-0 THEN
 EXIT one
END IF
t=t+n
c=c+1
m=t/c
PRINT "  Count ";c;"                "; "Total ";t;"        ";"Mean ";m
END REPEAT one
