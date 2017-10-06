10 rem WRITEINP.BAS -- Test WRITE # and INPUT # Statements
20 print "WRITEINP.BAS -- Test WRITE # and INPUT # Statements"
30 s1$ = "String 1"
40 s2$ = "String 2"
50 s3$ = "String 3"
60 x1 = 1.1234567
70 x2 = 2.2345678
80 x3 = 3.3456789
90 open "o", #1, "data.tmp"
100 write #1, s1$, x1, s2$, x2, s3$, x3
110 close #1
120 print "This is what was written:"
130 write s1$, x1, s2$, x2, s3$, x3
140 open "i", #2, "data.tmp"
150 input #2, b1$, n1, b2$, n2, b3$, n3
160 close #2
170 print "This is what was read:"
180 write b1$, n1, b2$, n2, b3$, n3
190 print "End of WRITEINP.BAS"
200 end
