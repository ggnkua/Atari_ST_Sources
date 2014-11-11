REM                2DECPLAC        two decimal places
'
PRINT "                    2DECPLAC."
PRINT
DEF FN c(s)=INT(s*100+0.5)/100         ' defines Function
'
REM INPUT k
k=1.23456789                           ' displays 7 digits, maximum.
PRINT"                   k=  ",k
PRINT " to 2 decimal places  ",FN c(k) ' uses Function
'
Print
Rem alternative, simple method.
rem INPUT x
x=98.7654321
print "                   x= ",x
print "                      ",INT(x*100+0.5)/100
