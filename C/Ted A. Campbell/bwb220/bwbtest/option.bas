1 PRINT "OPTION.BAS -- Test OPTION BASE Statement"
5 OPTION BASE 1
10 DIM n(5) 
20 FOR i = 1 to 5 
30 LET n(i) = i + 2 
40 PRINT "The value at position ";i;" is ";n(i) 
50 NEXT i 
60 END 
