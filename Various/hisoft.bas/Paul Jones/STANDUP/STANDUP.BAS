
' Stand Up!
' November 1996

DEFINT a-z

REM $option !gy
REM $option j30

REM $include standup.bh

REM $include acctbox.bas
REM $include filesel.bas

REM $include dialog.bas


SUB Checkdi
STATIC button,fsmessage$,f$,file$,stext$,buf,buf$,texter$(1),info$(1)
STATIC buf2$,fsname$,texty$,alert,a
SHARED button,fsmessage$,file$,stext$,fsname$,info$(1)

IF button=load THEN
	fsmessage$="Select Stand Up! file..."
	f$=FileSelect$
	IF f$<>"" THEN

IF FEXISTS(f$) THEN

Sette_ptext file,f$
OPEN f$ FOR INPUT AS #1
FOR a=1 TO 3
LINE INPUT #1,info$(a)
NEXT a
CLOSE #1

		Sette_ptext info1,info$(1)
		Sette_ptext info2,info$(2)
		Sette_ptext info3,info$(3)
		file$=f$

	END IF
	END IF
END IF

IF button=find THEN
	IF file$="" THEN alert=form_alert (1,"[1][ Error: | No Stand Up! file selected ][ Ok ]") : END IF
	IF stext$="" THEN alert=form_alert (1,"[1][ Error: | No search text selected! ][ Ok ]") : END IF
		IF FEXISTS(file$) THEN

buf=0
OPEN file$ FOR INPUT AS #1
WHILE NOT EOF (1)
LINE INPUT #1,buf$
INCR buf
WEND
CLOSE #1

buf=buf-3

IF buf MOD 2<>0 THEN alert=form_alert (1,"[1][ Error: | Faulty Stand Up! file ][ Ok ]")

IF buf MOD 2=0 THEN

DIM texter$ (buf)

texty$=""

OPEN file$ FOR INPUT AS #1

FOR a=1 TO 3
LINE INPUT #1,buf$
NEXT a

FOR a=1 TO buf/2
LINE INPUT #1,buf$
LINE INPUT #1,buf2$
IF UCASE$(buf$)=UCASE$(stext$) THEN texty$=buf2$
IF UCASE$(buf2$)=UCASE$(stext$) THEN texty$=buf$
NEXT a

CLOSE #1

IF texty$="" THEN alert=form_alert (1,"[1][ Text not found ][ Ok ]")
IF texty$<>"" THEN alert=form_alert (1,"[1][ '"+stext$+"' | can be written as | '"+texty$+"' ][ Ok ]")

ERASE texter$

buf=0

END IF
END IF
END IF

END SUB

SUB AccOpened
STATIC button,stext$
SHARED button,stext$

DO
SelectTree main
button=HandleDialog (text)
stext$=Gette_ptext$ (text)
CALL Checkdi
REM Exclob_state file,mask_selected
LOOP UNTIL button=ok

END SUB

SUB WindowMessage
END SUB

DIM info$(3)
InitResourceFile "STANDUP.RSC"
SelectTree main
Sette_ptext text,""
Sette_ptext info1,"No file loaded"
Sette_ptext info2,"No file loaded"
Sette_ptext info3,"No file loaded"
Sette_ptext file,"No file loaded"
StartAccessory("  Stand Up! v0.13")
