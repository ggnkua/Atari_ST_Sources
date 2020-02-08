
' [CLIPBRD.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

FUNCTION GetClipboard$
STATIC dummy$,toserr

toserr=scrp_read(dummy$)
IF toserr=0 THEN
	junk=form_alert(1,"[1][  "+MyProgram$+": |  The Clipboard path could |  not be found! ][ OK ]")
	GetClipboard$=""
ELSE
	GetClipboard$=dummy$
END IF
END FUNCTION


FUNCTION SetClipboard (BYVAL dummy$)
STATIC toserr

toserr=scrp_write(dummy$)
IF toserr=0 THEN
	junk=form_alert(1,"[1][  "+MyProgram$+": |  The Clipboard path could |  not be set! ][ OK ]")
	SetClipboard=0
ELSE
	SetClipboard=-1
END IF
END FUNCTION

'[*END OF FILE*]
