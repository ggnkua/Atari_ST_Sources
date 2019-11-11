'$include C:\PROGRAMS\HBASIC\HGT\ACCTBOX.BAS
FUNCTION ConvertAlt(ScanCode)
STATIC a&,res
	a&=keytbl&(-1,-1,-1)
	res=PEEKB(PEEKL(a&)+CLNG(ScanCode)\256)
	IF res>="a"% AND res<="z"% THEN res=res-"a"%+"A"%
	ConvertAlt=res
END FUNCTION
DECLARE FUNCTION CreateShortCut(BYVAL Scancode)
DECLARE SUB ProcessClicks(BYVAL clicks,BYVAL kstate,BYVAL x,BYVAL y)
DECLARE SUB ProcessKeys(BYVAL ascii$,BYVAL scan_code,BYVAL kstate)
'$include C:\PROGRAMS\HBASIC\HGT\dialog.bas
'$include C:\PROGRAMS\HBASIC\HGT\objcext.bas
'$include C:\PROGRAMS\HBASIC\HGT\xformdo.bas
'$include C:\PROGRAMS\HBASIC\HGT\window.bas
'$include C:\PROGRAMS\HBASIC\HGT\objwind.bas
'$include C:\PROGRAMS\HBASIC\HGT\formwind.bas
