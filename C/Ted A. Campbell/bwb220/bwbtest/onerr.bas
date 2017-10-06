10 rem onerr.bas -- test bwBASIC ON ERROR GOSUB statement
20 print "Test bwBASIC ON ERROR GOSUB statement"
30 on error gosub 100
40 print "The next line will include an error"
50 if d$ = 78.98 then print "This should not print"
60 print "This is the line after the error"
70 end
100 rem Error handler
110 print "This is the error handler"
120 print "The error number is ";err
130 print "The error line   is ";erl
150 return
