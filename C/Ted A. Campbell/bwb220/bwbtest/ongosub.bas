10 print "ONGOSUB.BAS -- Test ON..GOSUB Statement"
20 input "Enter a number 1-5";n
30 on n gosub 60, 80, 100, 120, 140
40 print "The End"
50 end
60 print "You entered 1"
70 return
80 print "You entered 2"
90 return
100 print "You entered 3"
110 return
120 print "You entered 4"
130 return
140 print "You entered 5"
150 return
