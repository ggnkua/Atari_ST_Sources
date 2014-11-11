REM                   PRNTUSNG.BAS   
'
PRINT "            PRINT USING chosen number of digits"
PRINT
PRINT "Number using ####.## 1234.5678"
PRINT USING "####.##";1234.5678
PRINT "Number using ##.# 12.34567" 
PRINT USING "##.#";12.34567
PRINT "Number using ###.## 12345.678"
PRINT USING "###.##";12345.678
PRINT "  % means too few #s"
PRINT "Number using ####,.## 4567.89    note comma after 4th #, then decimal point"
PRINT USING "####,.##";4567.89
'
PRINT
PRINT "JOHN"
PRINT USING"\\";"JOHN"