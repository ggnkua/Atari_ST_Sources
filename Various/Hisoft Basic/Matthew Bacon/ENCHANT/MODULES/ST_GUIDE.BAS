
' [ST-GUIDE.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

FUNCTION STGuide (path$,node$)
STATIC dummy$,dummy&,message&,id,time!

path$=RTRIM$(LTRIM$(path$))
node$=RTRIM$(LTRIM$(node$))
IF node$<>"" THEN path$=path$+" "+node$
dummy$=SPACE$(17) : dummy&=SADD(dummy$)
IF (dummy& MOD 2)=1 THEN
	time!=TIMER
	WHILE (dummy& MOD 2)
		dummy$=SPACE$(17) : dummy&=SADD(dummy$)
		IF TIMER-time!>10 THEN EXIT WHILE
	WEND
END IF

path$=LEFT$(path$,255)+CHR$(0) : message&=SADD(path$)
id=appl_find("ST-GUIDE")
IF id=-1 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  ST-Guide not found. ][ OK ]")
	STGuide=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEW dummy&+10,0
	POKEW dummy&+8,0
	POKEL dummy&+6,message&
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,&h4711
	appl_write id,16,dummy&
	STGuide=-1
END IF
END FUNCTION

'[*END OF FILE*]
