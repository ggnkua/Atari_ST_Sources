
' [PROTOCOL.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

FUNCTION Protocol_send (app$,messtype,message$)
STATIC dummy$,dummy&,message&,id

dummy$=SPACE$(17) : dummy&=SADD(dummy$)
IF (dummy& MOD 2)=1 THEN dummy$=SPACE$(17) : dummy&=SADD(dummy$)
message$=LEFT$(message$,255)+CHR$(0) : message&=SADD(message$)
app$=LEFT$(app$,8)
id=appl_find(app$)
IF id=-1 THEN
	junk=form_alert (1,"[1][  "+MyProgram$+": |  "+app$+" could not be |  found. ][ OK ]")
	Protocol_send=0
ELSE
	POKEW dummy&+14,0
	POKEW dummy&+12,0
	POKEL dummy&+10,message&
	POKEW dummy&+8,MOUSE(1)
	POKEW dummy&+6,MOUSE(0)
	POKEW dummy&+4,0
	POKEW dummy&+2,PEEKW(PEEKL(GB+4)+4)
	POKEW dummy&,messtype
	appl_write id,16,dummy&
	Protocol_send=-1
END IF
END FUNCTION


FUNCTION Protocol_recieve (id,message&,message$)
STATIC message$,mess&,id,addr&,dummy

message$=""
mess&=message&
id=SPEEKW(mess&+2)
addr&=SPEEKL(mess&+6)
IF addr&<>0 THEN
	DO
		dummy=PEEKB (addr&)
		IF dummy<>0 THEN message$=message$+CHR$(dummy)
		INCR addr&
	LOOP UNTIL dummy=0
	Protocol_recieve=-1
ELSE
	Protocol_recieve=0
END IF
END FUNCTION

'[*END OF FILE*]
