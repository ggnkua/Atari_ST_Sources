
' [PRINTER.BAS]
' This source document is apart of the ENhanCed Hisoft ApplicatioN toolkiT (ENCHANT)
' Developed by Matthew Bacon & Paul Jones, ½ 1997-1999 Matthew Bacon & Paul Jones

FUNCTION ONLINE
STATIC time!,button,result

IF bcostat(0)=0 THEN
	time!=TIMER
	DO
		IF INKEY$=CHR$(27) THEN ONLINE=0 : EXIT FUNCTION
	LOOP UNTIL TIMER-time!>2
	button=form_alert (1,"[1][  "+MyProgram$+": |  Please turn your printer |  ON LINE! ][Try Again|Cancel]")
	SELECT CASE button
		CASE 1
			result=ONLINE : ONLINE=result : EXIT FUNCTION
		CASE 2
			ONLINE=0 : EXIT FUNCTION
	END SELECT
END IF
ONLINE=-1
END FUNCTION

REM Epson Printer Control Codes!!
prt_reset$="27,64" : prt_lq$="27,120,1" : prt_draft$="27,120,0"
prt_italic$="27,52" : prt_underlined$="27,45,1" : prt_condensed$="15"
prt_expanded$="27,87,1" : prt_superscript$="27,83,0" : prt_subscript$="27,83,1"
prt_bold$="27,69" : prt_dheight$="27,119,1" : prt_proportional$="27,112,1"
prt_roman$="27,107,0" : prt_helvetica$="27,107,1" : prt_courier$="27,107,2"
prt_prestige$="27,107,3" : prt_left$="27,97,0" : prt_centre$="27,97,1"
prt_right$="27,97,2" : prt_lmargin$="27,108,08" : prt_rmargin$="27,81,08"
prt_frmfeed$="12" : prt_lfeed$="27,74,18"


FUNCTION printer_send (code$)
STATIC dummy$,dummy,result

result=ONLINE
IF result=0 THEN printer_send=0 : EXIT FUNCTION

dummy$=code$
DO
	FOR dummy=1 TO LEN(dummy$)
		IF MID$(dummy$,dummy,1)="," THEN EXIT FOR
	NEXT dummy
	OUT 0,VAL(LEFT$(dummy$,dummy-1))
	IF dummy+1>LEN(dummy$) THEN EXIT LOOP
	dummy$=RIGHT$(dummy$,LEN(dummy$)-dummy)
LOOP
printer_send=-1
END FUNCTION

'[*END OF FILE*]
