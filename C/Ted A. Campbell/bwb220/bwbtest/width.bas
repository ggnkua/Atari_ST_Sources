10 open "o", #1, "data.tmp"
20 width #1, 35
30 print #1, "123456789012345678901234567890123456789012345678901234567890"
40 close #1
50 print "Check file <data.tmp> to see if the printing wrapped at col 35"
