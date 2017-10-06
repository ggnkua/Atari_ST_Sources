
REM Multi - converted from old MODLIB routines to incorporate the NEW
REM routines by yours truely. 30/7/1997

DEFINT a-z
REM $option y+,v+,u+,#,[
REM $option j10
REM $option fC:\MULTI.ACC

LIBRARY "GEMAES","MODPLAY","GEMDOS"

REM $include gemaes.bh
REM $include F:\hbasic\enchant\hgt\fselect.bas

CONST va_start=&H4711
COMMON SHARED junk

SUB Play
STATIC mess&,id,addr&,addr2&,a,file$,b,a%(1),l&,ad&,b$,moder
SHARED mess(1),file$,moder

OPEN file$ FOR INPUT AS #1
l&=LOF(1)
CLOSE #1

IF moder>0 THEN
	moder=0
	StopMod a%()
	IF ad&>0 THEN a=mfree (ad&)
END IF

'ERASE a%
'DIM a%(l&+40000)

'ad&=VARPTR(a%(0))

ad&=malloc& (l&)
IF ad&=0 THEN
	a=form_alert (1,"[1][ Not enough memory to load: | "+file$+"! ][ OK ]")
	EXIT SUB
END IF
BLOAD file$,ad&

PlayMod ad&
INCR moder

GetModName ad&,b$

' b=form_alert (1,"[1][ Mod name: "+b$+" ][ Ok ]")

END SUB

SUB opts
STATIC b,moder,a%(),fsmessage$,fsname$,fspath$,file$
SHARED fsmessage$,fsname$,fspath$,file$,moder

b=form_alert (1,"[1][ Stop playing, Play new MOD | or infomation ][ Stop | Play | Info ]")
IF b=1 AND moder>0 THEN StopMod a%() : moder=0
IF b=2 THEN
	fsmessage$="File to play..."
	file$=fileselect$
	b=form_alert (1,"[1][ Are you sure? Play: | "+file$+" ? ][ Yes | No ]")
	IF b=1 AND moder>0 THEN
		StopMod a%()
		moder=0
	END IF
	IF b=1 THEN CALL Play
END IF
IF b=3 THEN b=form_alert (1,"[1][ MultiPhile v1 by Paul Jones | Plays MODs (for now) | ½ 1997 to PJCO ][ Ok ]")

END SUB

SUB Getcommand
STATIC mess&,id,addr&,addr2&,a,file$,b,a%(1),l&,ad&,b$,moder
SHARED mess(1),file$

REM mess0+1=&H4711
REM mess2+3=sent from (id)
REM mess4+5+6+7=address of string of mod file
REM mess9-16=blank

file$=""

mess&=VARPTR(mess(0))
id=SPEEKW(mess&+2)
addr&=SPEEKL(mess&+6)
addr2&=addr&

'OPEN "vastart.dat" FOR OUTPUT AS #1


DO
a=PEEKB (addr&)
IF a<>0 THEN file$=file$+CHR$(a)
'b=form_alert (1,"[1][ Number "+STR$(a)+" Char: "+CHR$(a)+" ][ Ok ]")
INCR addr&
'PRINT #1,a
LOOP UNTIL a=0

'CLOSE #1

'b=form_alert (1,"[1][ From:"+STR$(id)+" file name: | "+file$+" ][ Ok ]")
'b=form_alert (1,"[1][ Address: "+STR$(addr&)+" ][ Ok ]")

CALL Play


END SUB

SUB do_message
STATIC cur_front,MessageType,title,item,b
SHARED exit_item,Finished_Flag,Mess(1),AlreadyOpen
	MessageType=Mess(0)
	junk=wind_get(Mess(3),WF_TOP,cur_front,junk,junk,junk)
 	SELECT CASE MessageType
	CASE AC_OPEN:
		CALL opts
	CASE va_start
		CALL Getcommand
	END SELECT
END SUB

SUB StartAccessory(daname$)
SHARED WindX,WindY,WindW,WindH
SHARED Mess(1)
STATIC id,mpos
DIM Mess(7)
id=PEEKW(PEEKL(GB+4)+4)
mpos=menu_register(id,daname$)
junk=wind_get(0,WF_WORKXYWH,WindX,WindY,WindW,WindH)

DO
	evnt_mesag VARPTR(mess(0))
	do_message
LOOP
END SUB

DIM a%(1)
InitMod a%()
StartAccessory ("  MultiPhile v1.1")