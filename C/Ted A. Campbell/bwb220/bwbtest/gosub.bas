10 REM -------------------------------------------------------- 
20 REM GOSUB.BAS Test Bywater BASIC Interpreter GOSUB Statement
30 REM -------------------------------------------------------- 
40 GOSUB 160 
50 PRINT "Test GOSUB Statements" 
60 PRINT "---------------------" 
70 PRINT 
80 PRINT "1 - Run Subroutine" 
90 PRINT "9 - Exit to system" 
92 PRINT "x - Exit to BASIC" 
100 PRINT 
110 INPUT c$ 
120 IF c$ = "1" then gosub 430 
130 IF c$ = "9" then goto 600 
132 IF c$ = "x" then end 
134 IF c$ = "X" then end 
140 GOTO 10 
150 END 
160 REM subroutine to clear screen 
170 PRINT 
180 PRINT 
190 PRINT 
200 PRINT 
210 PRINT 
220 PRINT 
230 PRINT 
240 PRINT 
250 PRINT 
260 PRINT 
270 PRINT 
280 PRINT 
290 PRINT 
300 PRINT 
310 PRINT 
320 PRINT 
330 PRINT 
340 PRINT 
350 PRINT 
360 PRINT 
370 PRINT 
380 PRINT 
390 PRINT 
400 PRINT 
410 PRINT 
420 RETURN 
430 REM subroutine to test branching 
435 GOSUB 160 
440 PRINT "This is the subroutine." 
445 PRINT "Press any key: "; 
450 INPUT x$ 
460 RETURN 
600 GOSUB 160 
610 PRINT "Exit from Bywater BASIC Test Program" 
620 SYSTEM 
