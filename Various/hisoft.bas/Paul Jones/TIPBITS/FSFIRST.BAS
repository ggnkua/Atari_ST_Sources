
LIBRARY "gemdos"

DEFINT a-z
REM $option k200

a&=fgetdta&

b=fsfirst%("*.*",16)
IF b<>0 THEN STOP -1

DO

FOR c=30 TO 43
d=SPEEKB(a&+c)
IF d<>0 THEN a$=a$+CHR$(d) ELSE EXIT FOR
NEXT c
PRINT a$;
a$=""

d&=SPEEKL(a&+26)
PRINT " (File size:";d&;")"
e=SPEEKW(a&+22)
'PRINT "File time stamp: ";e
f=SPEEKW(a&+24)
'PRINT "File date stamp: ";f
g=SPEEKB(a&+21)
'PRINT "Attribute: ";
'IF g AND 32 THEN PRINT "Archive"
'IF g AND 16 THEN PRINT "Subdirectory"
'IF g AND 8 THEN PRINT "Volume label"
'IF g AND 4 THEN PRINT "System file"
'IF g AND 2 THEN PRINT "Hidden"
'IF g AND 1 THEN PRINT "Read Only"

'IF g=0 THEN PRINT "Read Only"
'IF g=1 THEN PRINT "Hidden"
'IF g=2 THEN PRINT "System"
'IF g=3 THEN PRINT "Volume label"
'IF g=4 THEN PRINT "Subdirectory"
'IF g=5 THEN PRINT "Archive bit"

'PRINT
b=fsnext%

LOOP UNTIL b<>0