
' [BUBBLE.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

FUNCTION BubbleGEM (BYVAL message$)
STATIC dummy$,dummy&,message&,id,time!

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

message$=LEFT$(message$,255)+CHR$(0) : message&=SADD(message$)
id=appl_find("BUBBLE  ")
IF id=-1 THEN
'	junk=form_alert (1,"[1][  "+MyProgram$+": |  BubbleGEM not found. ][ OK ]")
	BubbleGEM=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEL dummy&+10,message&
	POKEW dummy&+8,MOUSE(1)
	POKEW dummy&+6,MOUSE(0)
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,&HBABB
	appl_write id,16,dummy&
	BubbleGEM=-1
END IF
END FUNCTION


FUNCTION BubbleGEM_Font (font_no,point_size)
STATIC dummy$,dummy&,message&,id,fontid,total_fonts

dummy$=SPACE$(16) : dummy&=VARPTR(dummy$)
id=appl_find("BUBBLE  ")
IF id=-1 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  BubbleGEM not found. ][ OK ]")
	BubbleGEM_Font=0
ELSE
	IF GDOS<>-1 THEN
		BubbleGEM_Font=0
	ELSE
		total_fonts=vst_load_fonts
		IF total_fonts<font_no THEN font_no=total_fonts
		vst_unload_fonts
		fontid=vqt_name(font_no,dummy$)
		POKEW dummy&,&HBABE
		POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
		POKEW dummy&+4,0
		POKEW dummy&+6,fontid
		POKEW dummy&+8,point_size
		POKEL dummy&+10,0
		POKEW dummy&+14,0
		appl_write id,16,dummy&
		BubbleGEM_Font=-1
	END IF
END IF
END FUNCTION

'[*END OF FILE*]
