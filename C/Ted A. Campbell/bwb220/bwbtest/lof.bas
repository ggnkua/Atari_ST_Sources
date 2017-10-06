10 print "Test LOF() Function"
20 input "Filename";F$
30 open "i", 1, F$
40 print "Length of file ";F$;" is ";LOF(1);" bytes"
50 close 1
