DEFINT a-z
REM $option y+,v+,u+,#,[,]
REM $option j10

LIBRARY "GEMAES"
REM $include gemaes.bh

CONST va_start=&H4711
COMMON SHARED junk


SUB got_vastart
STATIC mess&,id,addr&,addr2&,a,file$,b
SHARED mess(1)

file$=""

mess&=VARPTR(mess(0))
id=SPEEKW(mess&+2)
addr&=SPEEKL(mess&+6)

DO
	a=PEEKB (addr&)
	IF a<>0 THEN file$=file$+CHR$(a)
	INCR addr&
LOOP UNTIL a=0

b=form_alert (1,"[1][ From id:"+STR$(id)+"| file name: | "+file$+" ][ Ok ]")

END SUB

SUB do_message
STATIC cur_front,MessageType,title,item
SHARED exit_item,Finished_Flag,Mess(1),AlreadyOpen
	MessageType=Mess(0)
	junk=wind_get(Mess(3),WF_TOP,cur_front,junk,junk,junk)
 	SELECT CASE MessageType
	CASE AC_OPEN:
		junk=form_alert (1,"[1][ VA_START test 1 accessory by | Paul Jones to test VA_START ][ Ok ]")
	CASE VA_START
		CALL got_vastart
	END SELECT
END SUB

SUB StartAccessory(daname$)
SHARED WindX,WindY,WindW,WindH
SHARED Mess(1)
STATIC id,mpos
DIM Mess(16)
id=PEEKW(PEEKL(GB+4)+4)
mpos=menu_register(id,daname$)
junk=wind_get(0,WF_WORKXYWH,WindX,WindY,WindW,WindH)

DO
	evnt_mesag VARPTR(mess(0))
	do_message
LOOP
END SUB

StartAccessory ("  VA_START test 1")