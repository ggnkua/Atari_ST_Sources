10 rem FNCALLFN.BAS -- Test User-defined function called
20 rem                 from user-defined function
30 def fnabs(x) = abs(x)
40 def fncmp(y) = 1.45678+fnabs(y)
50 print "Test user-defined function calling user-defined function"
60 print "The result should be: ";2.45678
70 q = -1.000
80 print "The result is:      : "; fncmp( q )
90 end
