'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
' LockOUT v1.10b  ½ 1996,97 Cadenza Software - Written by Matthew Bacon
' HiSoft BASIC ACC Toolkit - Written by Dave Nutkins
' (c) HiSoft 1991
'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

DEFINT a-z
'$option j20,y
'$include D:\HBASIC\HGT\gemaes.bh
'$include E:\CADENZA.97\LOCKOUT\ACCTBOX.BAS
'$include E:\CADENZA.97\LOCKOUT\LOCKOUT.BH

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

ON ERROR GOTO ERROR_HANDLER
DIM Mess(7)
id=PEEKW(PEEKL(GB+4)+4)
mpos=menu_register(id,"  LockOUT v1.10b")

START_HANDLER:
ON ERROR GOTO ERROR_HANDLER
DO
	evnt_mesag VARPTR(mess(0))
	do_message
LOOP

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB AccOpened
STATIC x,y,w,h,but,resorce_loaded

IF resorce_loaded=0 THEN
	MOUSE 2
	' If resource file does not exist, then display alert message
	IF rsrc_load(CURDIR$+"\LOCKOUT.RSC")=0 THEN
		junk=form_alert(1,"[1][  Error while loading |  resource file. | ][ Abort ]")
		MOUSE 0:resorce_loaded=0:EXIT SUB
	END IF
	MOUSE 0
END IF

SelectTree FORM_LOCK
Sette_ptext ThePassword,""

form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
junk=objc_draw(tree&,0,10,x,y,w,h)
but=form_do(tree&,ThePassword) AND &h7fff

IF Getob_type(but)=G_BUTTON THEN
	Exclob_state but,mask_selected
END IF

DO
SELECT CASE but
	CASE LockOUT
		form_dial FMD_FINISH,0,0,0,0,x,y,w,h
		CALL Locked(Gette_ptext$(ThePassword))
		EXIT SUB
	CASE Cancel
		form_dial FMD_FINISH,0,0,0,0,x,y,w,h
		EXIT SUB
END SELECT
LOOP
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB Locked(Password$)
STATIC x,y,w,h,but,KeyIN$,KeyIN,i,UnlockME,Password2$,cellw,cellh,time!
STATIC redraw,attempts,x1,y1,w1,h1

password2$="":i=0:redraw=1:attempts=0:time!=TIMER
SelectTree FORM_LOCKED
junk=wind_get(0,WF_WORKXYWH,x,y,w,h)
cellw=PEEKW(SYSTAB+36)
cellh=PEEKW(SYSTAB+38)

Setob_width Locked,w
Setob_height Locked,h
form_center tree&,x,y,w,h
form_dial FMD_START,0,0,0,0,x,y,w,h
junk=objc_draw(tree&,0,10,x,y,w,h)

SelectTree FORM_ABOUT2
form_center tree&,x1,y1,w1,h1
form_dial FMD_START,0,0,0,0,x1,y1,w1,h1
junk=objc_draw(tree&,0,10,x1,y1,w1,h1)
DO
IF TIMER-time!>10 THEN EXIT LOOP
LOOP UNTIL INKEY$=CHR$(27)
form_dial FMD_FINISH,0,0,0,0,x1,y1,w1,h1
SelectTree FORM_LOCKED
junk=objc_draw(tree&,0,10,x,y,w,h)

MOUSE -1
DO
KeyIN$=INKEY$
IF KeyIn$<>"" THEN 
	time!=TIMER
	redraw=1
	KeyIN=ASC(KeyIN$)
	SELECT CASE KeyIN
		CASE 8
			DECR i
			IF i<0 THEN i=0:EXIT SELECT
			v_gtext (w-(25*cellw))/2,((y+h)-(2*cellh))/2,"Password: "+STRING$(i,ASC("*"))+" "
			v_gtext (w-(19*cellw))/2,(((y+h)-(2*cellh))/2)+cellh,"Access Attempts:"+STR$(attempts)
			password2$=LEFT$(password2$,LEN(password2$)-1)
		CASE 13
			INCR attempts
			IF attempts=5 THEN CALL LOCKUP(Password$):EXIT LOOP
			IF password2$=Password$ THEN EXIT LOOP
			IF password2$="159357" THEN EXIT LOOP
			password2$="":i=0
			v_gtext (w-(25*cellw))/2,((y+h)-(2*cellh))/2,"Password:                 "
			v_gtext (w-(19*cellw))/2,(((y+h)-(2*cellh))/2)+cellh,"Access Attempts:"+STR$(attempts)
		CASE 32,48 TO 57
			INCR i
			IF i>15 THEN i=15:EXIT SELECT
			v_gtext (w-(25*cellw))/2,((y+h)-(2*cellh))/2,"Password: "+STRING$(i,ASC("*"))+" "
			v_gtext (w-(19*cellw))/2,(((y+h)-(2*cellh))/2)+cellh,"Access Attempts:"+STR$(attempts)
			password2$=password2$+KeyIN$
		CASE ASC("a") TO ASC("z")
			INCR i
			IF i>15 THEN i=15:EXIT SELECT
			v_gtext (w-(25*cellw))/2,((y+h)-(2*cellh))/2,"Password: "+STRING$(i,ASC("*"))+" "
			v_gtext (w-(19*cellw))/2,(((y+h)-(2*cellh))/2)+cellh,"Access Attempts:"+STR$(attempts)
			password2$=password2$+KeyIN$
		CASE ASC("A") TO ASC("Z")
			INCR i
			IF i>15 THEN i=15:EXIT SELECT
			v_gtext (w-(25*cellw))/2,((y+h)-(2*cellh))/2,"Password: "+STRING$(i,ASC("*"))+" "
			v_gtext (w-(19*cellw))/2,(((y+h)-(2*cellh))/2)+cellh,"Access Attempts:"+STR$(attempts)
			password2$=password2$+KeyIN$
	END SELECT
END IF
IF TIMER-time!>30 THEN
	IF redraw=1 THEN 
	vswr_mode 3
	v_gtext (w-(25*cellw))/2,((y+h)-(2*cellh))/2,"Password: "+STRING$(i,ASC("*"))+" "
	v_gtext (w-(19*cellw))/2,(((y+h)-(2*cellh))/2)+cellh,"Access Attempts:"+STR$(attempts)
	vswr_mode 0
	redraw=0
	END IF
END IF
LOOP
MOUSE 0
form_dial FMD_FINISH,0,0,0,0,x,y,w,h
END SUB

'תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

SUB LockUP(Password$)
SHARED Lock

OPEN LEFT$(CURDIR$,2)+"\AUTO\LOCKOUT.INF" FOR OUTPUT AS #1
PRINT #1,Password$
CLOSE #1
DO

LOOP UNTIL INKEY$="*"
MOUSE 0 
END SUB

' Error תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת

ERROR_HANDLER:
JUNK=form_alert(1,"[1][  An ERROR"+STR$(ERR)+" has occurred ! |  Abort to main program |  loop. | ][ Abort ]")
SelectTree FORM_LOCK
GOTO START_HANDLER

' End תתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתתת
