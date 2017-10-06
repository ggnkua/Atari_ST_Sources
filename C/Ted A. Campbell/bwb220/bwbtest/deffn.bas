10 REM ------------------------------------------ 
20 PRINT "DEFFN.BAS -- Test DEF FN Statement" 
30 DEF fnadd( x, y ) = x + y 
40 PRINT fnadd( 2, 3 ) 
50 DEF fnjoin$( a$, b$ ) = a$ + b$ 
60 PRINT fnjoin$( chr$( &h43 ), "orrect" ) 
70 END 
