REM CHAIN1.BAS
print "This is program CHAIN1.BAS"
X = 5.6789
common X
print "The value of X is";X
print "We shall no pass execution to program CHAIN2.BAS..."
chain "chain2.bas"
