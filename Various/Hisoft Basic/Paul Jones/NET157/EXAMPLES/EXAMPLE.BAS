
REM $include networld.bas

PRINT "Transport layer info: ";
PRINT tcp_module$+" "+tcp_author$+" v"+tcp_version$

PRINT "NetWorld version: "+networldver$

PRINT "STiK internal errors: "
' STiK has 26 errors, STinG has more!!

FOR a=0 TO -26 STEP -1
	PRINT STR$(a)+": "+gerrtxt$(a)
NEXT a