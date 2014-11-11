rem         RESTORE.BAS      re-reads part of data.
'
for g=1 to 2
print"Reading :";g
for f=1 to 6
read a
print a
next f
restore mark
next g
print "Program end"
data 1,2,3
mark:
data 4,5,6,7,8,9