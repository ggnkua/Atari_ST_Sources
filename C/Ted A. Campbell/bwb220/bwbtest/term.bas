10 REM BWBASIC Program to Demonstrate Terminal-Specific Use 
20 REM The following definitions are for an ANSI Terminal. 
30 REM You may have to define different variables for your 
40 REM particular terminal 
50 REM 
60 LET CL$ = chr$(&h1b)+"[2J" 
70 PRINT CL$; 
80 PRINT " Bywater BASIC" 
90 INPUT c$ 
100 END 
