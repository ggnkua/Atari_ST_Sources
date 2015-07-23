********************************************************************************
*				  Peacebug, WINDOW V1.10							15.03.1995 *
*				  ----------------------									   *
*																			   *
* written by:	  Emanuel M”cklin											   *
*				  Zschokkestrasse 7 										   *
*				  CH-8037 Zrich											   *
*                 peace@soziologie.unizh.ch                                   *
*																			   *
* ”ffnet ein Fenster und l„sst Peacebug darin laufen, dient als Demonstration  *
* der Bildschirmroutinen													   *
* h„ngt sich in die Userenter/Userquit Vektoren um die Maus aus-/einzuschalten *
********************************************************************************

GERMAN					EQU -1					; englische/deutsche Version?
REGISTER				REG D0-A6

*-------------------------------------------------------------------------------


PROGRAMM_ANFANG:BRA.S	LetsGo					; weil die folgenden Routinen
												; eventuell resident bleiben

*-------------------------------------------------------------------------------

						DC.L 'XBRA'
						DC.L 'PWIN'
OLD_ENTER:				DC.L 0
ENTER:			MOVEM.L 	#REGISTER,-(SP)
				ALINE		#10
				MOVEM.L 	(SP)+,#REGISTER
				MOVE.L		OLD_ENTER(PC),-(SP)
				RTS

*-------------------------------------------------------------------------------

						DC.L 'XBRA'
						DC.L 'PWIN'
OLD_QUIT:				DC.L 0
QUIT:			MOVEM.L 	#REGISTER,-(SP)
				ALINE		#9
				MOVEM.L 	(SP)+,#REGISTER
				MOVE.L		OLD_QUIT(PC),-(SP)
				RTS
RESIDENT_ENDE:

*-------------------------------------------------------------------------------

LetsGo:			LEA			VB(pc),a4
				MOVE.L		a0,d0
				SEQ			_app-VB(a4)
				BNE.S		ACC

				MOVE.L		4(sp),a0			; Basepagepointer
				LEA			OWN_STACK-VB(a4),sp	; Stack initialisieren
				MOVE.L		#256,d0				; L„nge BASEPAGE
				ADD.L		12(a0),d0			; L„nge TEXT Segment
				ADD.L		20(a0),d0			; L„nge DATA Segment
				ADD.L		28(a0),d0			; L„nge BSS Segment
				MOVE.L		d0,-(sp)			; L„nge
				PEA			(a0)				; Basepage
				PEA			$4a0000				; Dummy + Code
				TRAP		#1					; MSHRINK 74
				LEA			12(sp),sp

ACC:			LEA			OWN_STACK-VB(a4),sp	; Stack initialisieren

				MOVE.L		#$0A000100,D0		; APPL_INIT 10
				BSR 		AES_INIT
				MOVE.W		GLOBAL+20-VB(a4),MFDB_SOURCE+12-VB(a4)	; Planes

				MOVE.L		#$4D000500,D0		; GRAF_HANDLE
				BSR 		AES_INIT

				MOVE.W		GINTOUT-VB(a4),V_HANDLE-VB(a4)	; VDI Workstation
				LEA			INTIN-VB(a4),A0
				moveq		#9,d0
				moveq		#1,d1
SetLoop:		move.w		d1,(a0)+
				dbra		d0,SetLoop
				MOVE.W		#2,INTIN+20-VB(a4)	; RC-Koordinaten
				MOVE.L		#$6400060B,D0		; OPEN VIRTUAL WORKSTATION
				BSR 		VDI_INIT
				MOVE.W		CONTRL+12-VB(a4),V_HANDLE-VB(a4)

				MOVE.L		INTOUT-VB(a4),MFDB_SOURCE+4-VB(a4); Aufl”sung max_x und max_y
				ADDI.L		#$00010001,MFDB_SOURCE+4-VB(a4)
				MOVE.W		INTOUT-VB(a4),D0
				ADDI.W		#15,D0
				LSR.W		#4,D0
				MOVE.W		D0,MFDB_SOURCE+8-VB(a4)	; Words pro Zeile

				CLR.W		HANDLE-VB(a4)
				MOVEQ		#4,D3
				BSR 		WIND_GET			; Desktop
				MOVEM.L 	D0-D1,DESKTOP_MASSE-VB(a4)

				tst.b		_app-VB(a4)
				bne 		AC_OPEN

				MOVE.W		GLOBAL+4-VB(a4),GINTIN-VB(a4)
				LEA 		ACCESSORY_NAME-VB(a4),A0
				MOVE.L		A0,ADDRIN-VB(a4)
				MOVE.L		#$23010101,D0		; MENU_REGISTER 35
				BSR 		AES_INIT

*-------------------------------------------------------------------------------

MAIN_DIALOG:	CLR.W		MESSAGE_BUFFER-VB(a4)
				MOVE.W		#$0031,GINTIN-VB(a4)	; Keyboard, Timer, Message
				MOVE.L		#$00500000,GINTIN+28-VB(a4)
				MOVE.L		#MESSAGE_BUFFER,ADDRIN-VB(a4)
				MOVE.L		#$19100701,D0		;EVNT_MULTI 25
				BSR 		AES_INIT
				LEA 		MESSAGE_BUFFER-VB(a4),A0
				CMPI.W		#40,(A0)
				BEQ 		AC_OPEN
				CMPI.W		#$4711,(A0)
				BEQ 		AC_OPEN
				TST.B		WINDOW-VB(a4)
				BEQ.S		MAIN_DIALOG
				BTST		#0,GINTOUT+1-VB(a4) 	; Keyboard?
				BNE.S		KEYBOARD
				BTST		#4,GINTOUT+1-VB(a4) 	; Message?
				BNE.S		MESSAGE
				BTST		#5,GINTOUT+1-VB(a4) 	; Timer?
				BNE.S		TIMER
				BRA.S		MAIN_DIALOG

*---------------

MESSAGE:		CMPI.W		#41,(A0)
				BEQ 		AC_CLOSE
				MOVE.W		HANDLE-VB(a4),D0
				CMP.W		6(A0),D0
				BNE.S		MAIN_DIALOG
				CMPI.W		#21,(A0)
				BEQ 		WM_TOPPED
				CMPI.W		#20,(A0)
				BEQ 		WM_REDRAW
				CMPI.W		#22,(A0)
				BEQ 		WM_CLOSED
				CMPI.W		#23,(A0)
				BEQ 		WM_FULLED
				CMPI.W		#27,(A0)
				BEQ 		WM_MOVED_SIZED
				CMPI.W		#28,(A0)
				BEQ 		WM_MOVED_SIZED
				BRA 		MAIN_DIALOG

*---------------

KEYBOARD:		MOVE.W		GINTOUT+10-VB(a4),D7	; D7=Scancode*256+asciicode
				CMP.W		#$1011,D7			; Control Q?
				BEQ 		WM_CLOSED
				CMP.W		#$1615,D7			; Control U?
				BEQ 		WM_CLOSED
				BRA 		MAIN_DIALOG

*---------------

TIMER:			MOVEQ		#4,D3
				BSR 		WIND_GET			; Arbeitsbereich
				MOVEM.L 	D0-D1,-(SP)
				MOVEQ		#11,D3
				BSR 		WIND_GET			; 1st retangle
				MOVEM.L 	(SP)+,D2-D3
				CMP.L		D0,D2				; Arbeitsbereich frei?
				BNE.S		NOT_TOP
				CMP.L		D1,D3
				BNE.S		NOT_TOP
				movem.l		DESKTOP_MASSE-VB(a4),d2-d3
				cmp.w		d2,d0				; Arbeitsbereicht voll
				blt.s		NOT_TOP				; auf dem Desktop?
				swap		d0
				swap		d2
				cmp.w		d2,d0
				blt.s		NOT_TOP
				add.l		d1,d0
				add.l		d3,d2
				cmp.w		d2,d0
				bgt.s		NOT_TOP
				swap		d0
				swap		d2
				cmp.w		d2,d0
				bgt.s		NOT_TOP
				BSR 		CHANGE_TO_WINDOW
				BRA 		MAIN_DIALOG
NOT_TOP:		BSR 		CHANGE_TO_SCREEN
				BRA 		MAIN_DIALOG

*---------------

ENDE_WINDOW:	MOVE.L		#$65000000,D0
				BSR 		VDI_INIT			; CLOSE VIRTUAL WOKSTATION
				MOVE.L		#$13000100,D0
				BSR 		AES_INIT			; APPL_EXIT
				CLR.W		-(SP)
				PEA 		RESIDENT_ENDE-PROGRAMM_ANFANG+256.w
				MOVE.W		#49,-(SP)			; PTERMRES
				TRAP		#1

*-------------------------------------------------------------------------------

WM_REDRAW:		MOVEM.L 	8(A0),D2-D3
				MOVEM.L 	D2-D3,INTER_XYWH-VB(a4)
				MOVE.B		IN_WINDOW-VB(a4),-(SP)
				BSR 		CHANGE_TO_SCREEN
				TST.B		(SP)+
				BEQ.S		SCREEN_OK
				BSR 		CHANGE_IT
SCREEN_OK:		BSR 		BEGIN_UPDATE
				BSR 		MOUSE_OFF

* jetzt die Reckecksliste abarbeiten
				MOVEQ		#11,D3
				BRA.S		EINSTIEG
NEXT_RETANGLE:	MOVEQ		#12,D3
EINSTIEG:		BSR 		WIND_GET			; 1st/next retangle
				TST.L		D1
				BEQ.S		ZEICHNEN_ENDE

				MOVE.L		#MFDB_SOURCE,CONTRL+14-VB(a4)
				MOVE.L		#MFDB_DEST,CONTRL+18-VB(a4)

				MOVEM.L 	INTER_XYWH-VB(a4),D2-D3
				BSR.S		RC_INTERSECT
				BEQ.S		NEXT_RETANGLE

				SUB.L		#$00010001,D1
				ADD.L		D0,D1

				MOVE.L		D0,PTSIN+8-VB(a4)
				SUB.L		WORK-VB(a4),D0
				MOVE.L		D0,PTSIN-VB(a4)
				MOVE.L		D1,PTSIN+12-VB(a4)
				SUB.L		WORK-VB(a4),D1
				MOVE.L		D1,PTSIN+4-VB(a4)
				MOVE.W		#3,INTIN-VB(a4)
				MOVE.L		#$6D040001,D0
				BSR 		VDI_INIT			; COPY RASTER

				BRA.S		NEXT_RETANGLE

ZEICHNEN_ENDE:	BSR 		MOUSE_ON
				BSR 		END_UPDATE
				BRA 		MAIN_DIALOG

* ---> D0.l=X1/Y1, D1.l=W1/H1
* ---> D2.l=X1/Y1, D3.l=W1/H1
* <--- D0.l=X/Y, D1.l=W/H
RC_INTERSECT:	MOVEM.L 	#REGISTER,-(SP)

				ADD.L		D0,D1
				ADD.L		D2,D3

				MOVE.W		D0,INTER_Y-VB(a4)
				CMP.W		D0,D2
				BLS.S		Y_OK
				MOVE.W		D2,INTER_Y-VB(a4)

Y_OK:			SWAP		D0
				SWAP		D2
				MOVE.W		D0,INTER_X-VB(a4)
				CMP.W		D0,D2
				BLS.S		X_OK
				MOVE.W		D2,INTER_X-VB(a4)

X_OK:			MOVE.W		D1,INTER_H-VB(a4)
				CMP.W		D1,D3
				BHS.S		H_OK
				MOVE.W		D3,INTER_H-VB(a4)

H_OK:			SWAP		D1
				SWAP		D3
				MOVE.W		D1,INTER_W-VB(a4)
				CMP.W		D1,D3
				BHS.S		W_OK
				MOVE.W		D3,INTER_W-VB(a4)

W_OK:			MOVEM.W 	INTER_X-VB(a4),D0-D1
				SUB.W		D0,INTER_W-VB(a4)
				BLE.S		NO_RETANGLE
				SUB.W		D1,INTER_H-VB(a4)
				BLE.S		NO_RETANGLE
				MOVEM.L 	(SP)+,#REGISTER
				MOVEM.L 	INTER_X-VB(a4),D0-D1
				MOVE.L		D1,D1
				RTS

NO_RETANGLE:	MOVEM.L 	(SP)+,#REGISTER
				MOVEQ		#0,D0
				RTS

*-------------------------------------------------------------------------------

WM_TOPPED:		MOVEQ		#10,D3
				BSR 		WIND_SET
				BSR 		CHANGE_TO_WINDOW
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

WM_CLOSED:		BSR 		CHANGE_TO_SCREEN
				MOVE.W		HANDLE-VB(a4),GINTIN-VB(a4)
				MOVE.L		#$66010100,D0		; WIND_CLOSE
				BSR 		AES_INIT
				MOVE.W		HANDLE-VB(a4),GINTIN-VB(a4)
				MOVE.L		#$67010100,D0		; WIND_DELETE
				BSR 		AES_INIT
				SF			WINDOW-VB(a4)
				BSR 		CHANGE_TO_SCREEN
				BSR 		SEARCH_PEACEBUG
				BNE.S		NO_BUG_1
				MOVEA.L 	24(A0),A0			; Screen_parameter
				CLR.B		102(A0) 			; SCREEN_LOCK freigeben
NO_BUG_1:		tst.b		_app-VB(a4)
				beq 		MAIN_DIALOG
				BRA 		ENDE_WINDOW

*-------------------------------------------------------------------------------

WM_FULLED:		LEA 		MAXBORDER-VB(a4),A0
				LEA 		BORDER-VB(a4),A1
				CMPM.L		(A0)+,(A1)+
				BNE.S		FULLEN
				CMPM.L		(A0)+,(A1)+
				BNE.S		FULLEN
				MOVEM.L 	BORDER_OLD-VB(a4),D0-D3
				MOVEM.L 	D0-D3,BORDER-VB(a4)
				BRA.S		OLD_ONE
FULLEN: 		MOVEM.L 	BORDER-VB(a4),D0-D3
				MOVEM.L 	D0-D3,BORDER_OLD-VB(a4)
				MOVEM.L 	MAXBORDER-VB(a4),D0-D3
				MOVEM.L 	D0-D3,BORDER-VB(a4)
OLD_ONE:		MOVEQ		#5,D3
				BSR 		WIND_SET
				BSR 		WINDOW_PUT_2
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

WM_MOVED_SIZED: MOVEM.L 	8(A0),D0-D1
				BSR 		CALC_WINDOW
				MOVEQ		#5,D3
				BSR 		WIND_SET
				BSR 		WINDOW_PUT_2
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

AC_CLOSE:		SF			WINDOW-VB(a4)
				BSR 		CHANGE_TO_SCREEN
				BSR.S		SEARCH_PEACEBUG
				BNE 		MAIN_DIALOG
				MOVEA.L 	24(A0),A0			; Screen_parameter
				CLR.B		102(A0) 			; SCREEN_LOCK freigeben
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

AC_OPEN:		TST.B		WINDOW-VB(a4)
				BNE 		WM_TOPPED
				BSR 		MAUS_PFEIL
				BSR 		WINDOW_OPEN
				TST.B		NICHT_GEFUNDEN-VB(a4)
				BNE 		MAIN_DIALOG
				BSR 		WINDOW_PUT
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

SEARCH_PEACEBUG:MOVEM.L 	#REGISTER,-(SP)
				PEA 		SUPERVISOR(PC)
				MOVE.W		#38,-(SP)
				TRAP		#14
				ADDQ.W		#6,SP
				MOVEM.L 	(SP)+,#REGISTER
				MOVEA.L 	COOKIE-VB(a4),A0
				TST.B		NICHT_GEFUNDEN-VB(a4)
				RTS

SUPERVISOR: 	MOVEA.L 	$000005A0.w,A0		; jetzt suchen wir den Cookie
				MOVE.L		A0,D0
				BEQ.S		SEARCH_FAIL
				SUBQ.W		#8,A0
COOKIE_SUCHEN:	ADDQ.W		#8,A0
				TST.L		(A0)
				BEQ.S		SEARCH_FAIL
				CMPI.L		#'PBUG',(A0)
				BNE.S		COOKIE_SUCHEN
				MOVE.L		4(A0),COOKIE
				SF			NICHT_GEFUNDEN
				RTS
SEARCH_FAIL:	ST			NICHT_GEFUNDEN
				RTS

*-------------------------------------------------------------------------------

INSTALL_ROUTINE:MOVEA.L 	COOKIE-VB(a4),A0
				MOVEA.L 	24(A0),A1
				MOVE.L		4(A1),MFDB_SOURCE-VB(a4)
				MOVEA.L 	44(A0),A1
				BSR.S		TEST_VEKTOR
				BEQ.S		NO_ENTER
				MOVE.L		44(A0),OLD_ENTER-VB(a4)
				MOVE.L		#ENTER,44(A0)

NO_ENTER:		MOVEA.L 	48(A0),A1
				BSR.S		TEST_VEKTOR
				BEQ.S		NO_QUIT
				MOVE.L		48(A0),OLD_QUIT-VB(a4)
				MOVE.L		#QUIT,48(A0)

NO_QUIT:		SF			NICHT_GEFUNDEN-VB(a4)
				RTS

TEST_VEKTOR:	CMPI.L		#'XBRA',-12(A1)
				BNE.S		FALSE
				CMPI.L		#'PWIN',-8(A1)
				BNE.S		FALSE
				MOVE.L		-4(A1),D0
				BEQ.S		FALSE
				MOVEA.L 	D0,A1
				MOVEQ		#0,D0
				RTS
FALSE:			MOVEQ		#-1,D0
				RTS

*-------------------------------------------------------------------------------

* berechnet die maximalen Aussenmasse und ”ffnet dann das Fenster (Debugger wird
* aber noch nicht umgelenkt
WINDOW_OPEN:	BSR 		SEARCH_PEACEBUG
				BNE 		KEIN_DEBUGGER
				BSR.S		INSTALL_ROUTINE

				MOVEA.L 	COOKIE-VB(a4),A0
				MOVEA.L 	24(A0),A0			; Screen_parameter
				TST.B		102(A0) 			; SCREEN_LOCK testen
				BNE 		SCREEN_LOCKED
				ST			102(A0)

				MOVEA.L 	COOKIE-VB(a4),A0
				MOVE.L		4(A0),-(SP)
				MOVE.W		#38,-(SP)
				TRAP		#14 				; GET_PARAMETER
				ADDQ.W		#6,SP

				MOVEM.L 	DESKTOP_MASSE-VB(a4),D0-D1
				BSR 		CALC_WINDOW
				BEQ 		KEIN_WINDOW

BORDER_CHECK:	MOVE.W		DESKTOP_MASSE-VB(a4),D0
				ADD.W		DESKTOP_MASSE+4-VB(a4),D0
				MOVE.W		BORDER-VB(a4),D1
				ADD.W		BORDER+4-VB(a4),D1
				CMP.W		D0,D1
				BLS.S		BORDER_IO
				SUBQ.W		#8,BORDER+4-VB(a4)
				BRA.S		BORDER_CHECK
BORDER_IO:		MOVEM.L 	BORDER-VB(a4),D0-D1
				MOVEQ		#1,D3
				BSR 		WIND_CALC
				MOVEM.L 	D0-D1,WORK-VB(a4)

				MOVE.W		#$002F,GINTIN-VB(a4)
				MOVEM.L 	BORDER-VB(a4),D0-D1
				MOVEM.L 	D0-D1,GINTIN+2-VB(a4)
				MOVE.L		#$64050100,D0
				BSR 		AES_INIT			; WIND_CREATE 100
				MOVE.W		GINTOUT-VB(a4),HANDLE-VB(a4)
				BMI.S		KEIN_WINDOW

				BSR 		SET_TITLE
				BEQ.S		KEIN_WINDOW

				MOVE.W		HANDLE-VB(a4),GINTIN-VB(a4)
				MOVEM.L 	BORDER-VB(a4),D0-D1
				MOVEM.L 	D0-D1,GINTIN+2-VB(a4)
				MOVE.L		#$65050100,D0		; WIND_OPEN 101
				BSR 		AES_INIT
				TST.W		GINTOUT-VB(a4)
				BEQ.S		KEIN_WINDOW

				MOVEM.L 	BORDER-VB(a4),D0-D3
				MOVEM.L 	D0-D3,BORDER_OLD-VB(a4)
				MOVEM.L 	D0-D3,MAXBORDER-VB(a4)
				ST			WINDOW-VB(a4)
				RTS

KEIN_WINDOW:	MOVEA.L 	COOKIE-VB(a4),A0
				MOVEA.L 	24(A0),A0			; Screen_parameter
				CLR.B		102(A0) 			; SCREEN_LOCK freigeben
				LEA 		WINDOW_FAIL-VB(a4),A3
				BRA.S		NO_WAY
SCREEN_LOCKED:	LEA 		SCREEN_LOCK(PC),A3
				BRA.S		NO_WAY
KEIN_DEBUGGER:	LEA 		NO_PEACEBUG-VB(a4),A3
NO_WAY: 		BSR 		FORM_ALERT
				tst.b		_app-VB(a4)
				bne 		ENDE_WINDOW
				RTS

*-------------------------------------------------------------------------------

* Diese Routine schaut nur, dass der Workspace ganz auf dem Desktop liegt
* ---> D0-D1 = X/Y/W/H Aussenmasse
* <--- Border = X/Y/W/H Aussenmasse korrigiert
* <--- Word   = X/Y/W/H  Innenmasse korrigiert
CALC_WINDOW:	MOVEM.L 	D0-D1,BORDER-VB(a4)
				MOVEQ		#1,D3
				BSR 		WIND_CALC			; Wind_calc Innenmasse
				TST.W		GINTOUT-VB(a4)
				BEQ 		FEHLER_CALC
				MOVEM.L 	D0-D1,WORK-VB(a4)

			 	SWAP		D0					; auf die n„chste 8er
				ADDQ.W		#7,d0				; Grenze aufrunden
				LSR.W		#3,D0
				LSL.W		#3,D0
			 	MOVE.W		D0,WORK-VB(a4)		; Innenmasse runden X

				MOVEQ		#3,D1
				BSR 		CHECK_FONT
				BGT.S		SMALL_FONT_2
				MOVEQ		#4,D1
SMALL_FONT_2:	MOVE.L		WORK+4-VB(a4),D0
				ASR.W		D1,D0
				CMP.W		#6,D0
				BGE.S		HOEHE_OK
				MOVE.W		#6,D0				; H
HOEHE_OK:		LSL.W		D1,D0
				SWAP		D0
				ASR.W		#3,D0
				CMP.W		#10,D0
				BGE.S		BREITE_OK
				MOVE.W		#10,D0				; W
BREITE_OK:		LSL.W		#3,D0
				SWAP		D0
				MOVE.L		D0,WORK+4-VB(a4)	; Innenmasse runden W/H

			 	MOVEM.L 	WORK-VB(a4),D0-D1
				MOVEQ		#0,D3
				BSR 		WIND_CALC			; Wind_calc neue Aussenmasse
				TST.W		GINTOUT-VB(a4)
				BEQ.S		FEHLER_CALC
				MOVEM.L 	D0-D1,BORDER-VB(a4)
				MOVEQ		#-1,D0
				RTS

FEHLER_CALC:	MOVEQ		#0,D0
				RTS

*-------------------------------------------------------------------------------

* berechnet die Variablen fr den Debugger aus den Fenstermassen
* und wechselt dann auf das Window, ohne zu zeichnen (das macht der REDRAW)
* wird nur am Anfang benutzt, beim ersten Aufruf
WINDOW_PUT: 	TST.B		WINDOW-VB(a4)
				BEQ 		RTS
				MOVE.W		#3,-(SP)
				TRAP		#14
				ADDQ.W		#2,SP
				MOVE.L		D0,BILDSCHIRM_ADRESSE-VB(a4)
				LEA 		WORK-VB(a4),A2
				MOVE.W		(A2)+,D0
				LSR.W		#3,D0
				MOVE.W		D0,OFFSET_X-VB(a4)		; Offset_x
				MOVE.W		(A2)+,OFFSET_Y-VB(a4)	; Offset_y
				MOVE.W		(A2)+,D0
				LSR.W		#3,D0
				MOVE.W		D0,BILD_BREITE-VB(a4)	; Bild_breite
				MOVE.W		(A2)+,BILD_HOEHE-VB(a4)	; Bild_h”he

				TST.B		IN_WINDOW-VB(a4)
				BEQ 		CHANGE_IT
				RTS

* berechnet die Variablen fr den Debugger aus den Fenstermassen
* bergibt sie dem Debugger und ruft dann NEW_FORMAT auf
* wird benutzt, wenn das Fenster schon offen ist
WINDOW_PUT_2:	TST.B		WINDOW-VB(a4)
				BEQ 		RTS

				BSR 		SEARCH_PEACEBUG
				BNE 		RTS
				MOVEA.L 	24(A0),A1

				LEA 		WORK-VB(a4),A2
				MOVE.W		(A2)+,D0
				LSR.W		#3,D0
				MOVE.W		D0,-(SP)
				MOVE.W		(A2)+,-(SP)
				MOVE.W		(A2)+,D0
				LSR.W		#3,D0
				MOVE.W		D0,-(SP)
				MOVE.W		(A2)+,-(SP)

				TST.B		IN_WINDOW-VB(a4)
				BEQ.S		NOT_INSIDE

				MOVE.W		(SP)+,50(A1)		; Bild_h”he
				MOVE.W		(SP)+,46(A1)		; Bild_breite
				MOVE.W		(SP)+,44(A1)		; Offset_y
				MOVE.W		(SP)+,42(A1)		; Offset_x
				MOVE.L		16(A0),-(SP)
				MOVE.W		#38,-(SP)
				TRAP		#14 				; NEW_FORMAT
				ADDQ.W		#6,SP
				RTS

NOT_INSIDE: 	MOVE.W		(SP)+,BILD_HOEHE-VB(a4)
				MOVE.W		(SP)+,BILD_BREITE-VB(a4)
				MOVE.W		(SP)+,OFFSET_Y-VB(a4)
				MOVE.W		(SP)+,OFFSET_X-VB(a4)
				RTS

*-------------------------------------------------------------------------------

* wechselt auf den Debuggerschirm, berechnet und zeichnet alles neu
CHANGE_TO_SCREEN:TST.B		IN_WINDOW-VB(a4)
				BEQ.S		RTS
				BSR.S		CHANGE_IT
				BSR 		BEGIN_UPDATE
				BSR 		MOUSE_OFF
				BSR 		SEARCH_PEACEBUG
				BNE.S		NO_BUG_3
				MOVE.L		20(A0),-(SP)		; PRINT_SCREEN
				MOVE.W		#38,-(SP)
				TRAP		#14
				ADDQ.W		#6,SP
NO_BUG_3:		BSR 		MOUSE_ON
				BRA 		END_UPDATE

* wechselt auf das Window, berechnet aber zeichnet nichts (das macht der REDRAW)
CHANGE_TO_WINDOW:
				TST.B		IN_WINDOW-VB(a4)
				BNE.S		RTS

CHANGE_IT:		BSR 		SEARCH_PEACEBUG
				BNE.S		NO_BUG_4
				PEA 		SUPER(PC)
				MOVE.W		#38,-(SP)
				TRAP		#14
				ADDQ.W		#6,SP
NO_BUG_4:		NOT.B		IN_WINDOW-VB(a4)
				bra.s		SET_TITLE
RTS:			RTS
SUPER:			LEA 		VB(PC),A4
				MOVEA.L 	COOKIE-VB(a4),A0
				MOVEA.L 	24(A0),A1
				MOVE.L		4(A1),D0
				MOVE.L		BILDSCHIRM_ADRESSE-VB(a4),4(A1)
				MOVE.L		D0,BILDSCHIRM_ADRESSE-VB(a4)
				MOVE.W		42(A1),D0
				MOVE.W		OFFSET_X-VB(a4),42(A1)
				MOVE.W		D0,OFFSET_X-VB(a4)
				MOVE.W		44(A1),D0
				MOVE.W		OFFSET_Y-VB(a4),44(A1)
				MOVE.W		D0,OFFSET_Y-VB(a4)
				MOVE.W		46(A1),D0
				MOVE.W		BILD_BREITE-VB(a4),46(A1)
				MOVE.W		D0,BILD_BREITE-VB(a4)
				MOVE.W		50(A1),D0
				MOVE.W		BILD_HOEHE-VB(a4),50(A1)
				MOVE.W		D0,BILD_HOEHE-VB(a4)
				MOVEA.L 	16(A0),A0			; NEW_FORMAT
				JMP 		(A0)

*-------------------------------------------------------------------------------

SET_TITLE:		MOVEM.L 	#REGISTER,-(SP)
				LEA 		TITEL_ZEILE+22-VB(a4),A1
				tst.b		IN_WINDOW-VB(a4)
				beq.s		.cont
				LEA 		TITEL_ZEILE2+23-VB(a4),A1
.cont:			CLR.B		(A1)

				BSR 		CHECK_FONT
				BEQ.S		DONT_SET
				MOVE.B		#'[',(A1)+

				MOVE.W		WORK+4-VB(a4),D0
				LSR.W		#3,D0
				BSR.S		PRINT_DEZIMAL
				MOVE.B		#'*',(A1)+
				MOVE.W		WORK+6-VB(a4),D0
				LSR.W		#3,D0
				BSR			CHECK_FONT
				BGT.S		SMALL_FONT_1
				LSR.W		#1,D0
SMALL_FONT_1:	BSR.S		PRINT_DEZIMAL
				MOVE.B		#']',(A1)+
				tst.b		IN_WINDOW-VB(a4)
				beq.s		.cont
				move.b		#'*',(a1)+
.cont:			move.b		#32,(a1)+
				CLR.B		(A1)+

DONT_SET:		MOVE.W		HANDLE-VB(a4),GINTIN-VB(a4)
				MOVE.W		#2,GINTIN+2-VB(a4)
				MOVE.L		#TITEL_ZEILE,GINTIN+4-VB(a4)
				tst.b		IN_WINDOW-VB(a4)
				beq.s		.cont
				MOVE.L		#TITEL_ZEILE2,GINTIN+4-VB(a4)
.cont:			MOVE.L		#$69060100,D0
				BSR 		AES_INIT			; WIND_SET 105
				MOVEM.L 	(SP)+,#REGISTER
				TST.W		GINTOUT-VB(a4)
				RTS

PRINT_DEZIMAL:	MOVEQ		#0,D1
				CMP.W		#9,D0
				BLS.S		CONT_DEZIMAL
				MOVEQ		#1,D1
				CMP.W		#99,D0
				BLS.S		CONT_DEZIMAL
				MOVEQ		#2,D1
CONT_DEZIMAL:	LEA 		1(A1,D1.w),A1
				MOVEA.L 	A1,A2
DEZIMAL_LOOP:	AND.L		#$0000FFFF,D0
				DIVU		#10,D0
				MOVE.L		D0,D2
				SWAP		D2
				ADD.B		#48,D2
				MOVE.B		D2,-(A2)
				DBRA		D1,DEZIMAL_LOOP
				RTS

*-------------------------------------------------------------------------------

* <--- flag.eq = kein Debugger installiert
*	   flag.mi = 8*16 Font
*	   flag.gt =  8*8 Font
CHECK_FONT: 	MOVEM.L 	#REGISTER,-(SP)
				BSR 		SEARCH_PEACEBUG
				BNE.S		NO_DEBUGGER
				MOVEA.L 	24(A0),A0
				CMPI.W		#3,40(A0)
				BEQ.S		SMALL_FONT
				MOVEM.L 	(SP)+,#REGISTER
				ST			-(SP)
				TST.B		(SP)+
				RTS
SMALL_FONT: 	MOVEM.L 	(SP)+,#REGISTER
				MOVE.B		#1,-(SP)
				TST.B		(SP)+
				RTS
NO_DEBUGGER:	MOVEM.L 	(SP)+,#REGISTER
				clr.b		-(SP)
				TST.B		(SP)+
				RTS

*-------------------------------------------------------------------------------

MAUS_PFEIL: 	CLR.W		GINTIN-VB(a4)
				BRA.S		GRAF_MOUSE
MOUSE_OFF:		MOVE.W		#256,GINTIN-VB(a4)
				BRA.S		GRAF_MOUSE
MOUSE_ON:		MOVE.W		#257,GINTIN-VB(a4)
GRAF_MOUSE: 	MOVE.L		#$4E010101,D0		; GRAF_MOUSE
				BRA 		AES_INIT

*-------------------------------------------------------------------------------

* ---> w_field
* <--- D0-D1=X/Y/W/H
WIND_GET:		MOVE.W		HANDLE-VB(a4),GINTIN-VB(a4)
				MOVE.W		D3,GINTIN+2-VB(a4)
				MOVE.L		#$68020500,D0
				BSR.S		AES_INIT			; WIND_GET 104
				MOVEM.L 	GINTOUT+2-VB(a4),D0-D1
				RTS

*-------------------------------------------------------------------------------

WIND_SET:		CMP.W		#5,D3
				BNE.S		NO_SET_SIZE
				BSR 		SET_TITLE
NO_SET_SIZE:	MOVE.W		HANDLE-VB(a4),GINTIN-VB(a4)
				MOVE.W		D3,GINTIN+2-VB(a4)
				MOVEM.L 	BORDER-VB(a4),D0-D1
				MOVEM.L 	D0-D1,GINTIN+4-VB(a4)
				MOVE.L		#$69060100,D0
				BRA.S		AES_INIT			; WIND_SET 105

*-------------------------------------------------------------------------------

* ---> D0-D1 = X/Y/W/H Innen- /Aussenmasse
* <--- D0-D1 = X/Y/W/H Aussen-/Innenmasse
WIND_CALC:		MOVE.W		D3,GINTIN-VB(a4)
				MOVE.W		#$002F,GINTIN+2-VB(a4)
				MOVEM.L 	D0-D1,GINTIN+4-VB(a4)
				MOVE.L		#$6C060500,D0
				BSR.S		AES_INIT			; WIND_CALC 108
				MOVEM.L 	GINTOUT+2-VB(a4),D0-D1
				RTS

*-------------------------------------------------------------------------------

FORM_ALERT: 	MOVE.W		#1,GINTIN-VB(a4)
				MOVE.L		A3,ADDRIN-VB(a4)
				MOVE.L		#$34010101,D0
				BSR.S		AES_INIT			; FORM_ALERT 52
				MOVE.W		GINTOUT-VB(a4),D0
				RTS

*-------------------------------------------------------------------------------

BEGIN_UPDATE:	MOVE.W		#1,GINTIN-VB(a4)
				BRA.S		WIND_UPDATE
END_UPDATE: 	CLR.W		GINTIN-VB(a4)
WIND_UPDATE:	MOVE.L		#$6B010100,D0		; WIND_UPDATE 107
;				*
;				*
AES_INIT:		MOVEM.L 	#REGISTER,-(SP)
				CLR.L		CONTROL-VB(a4)
				CLR.L		CONTROL+4-VB(a4)
				MOVEP.L 	D0,CONTROL+1-VB(a4)
				MOVE.L		#AES_PB,D1
				MOVE.W		#$00C8,D0
				TRAP		#2
				MOVEM.L 	(SP)+,#REGISTER
				RTS

*-------------------------------------------------------------------------------

VDI_INIT:		MOVEM.L 	#REGISTER,-(SP)
				CLR.L		CONTRL-VB(a4)
				CLR.L		CONTRL+4-VB(a4)
				MOVEP.L 	D0,CONTRL+1-VB(a4)
				MOVE.W		V_HANDLE-VB(a4),CONTRL+12-VB(a4)
				MOVE.L		#VDI_PB,D1
				MOVEQ		#$73,D0
				TRAP		#2
				MOVEM.L 	(SP)+,#REGISTER
				RTS

******************	D A T A  -	S E G M E N T  *********************************

VB:
AES_PB: 				DC.L CONTROL,GLOBAL,GINTIN,GINTOUT,ADDRIN,ADDROUT
VDI_PB: 				DC.L CONTRL,INTIN,PTSIN,INTOUT,PTSOUT

ACCESSORY_NAME: 		DC.B '  Peacebug Window',0
TITEL_ZEILE:			DC.B ' Peacebug Window 1.10 [999*999] ',0
TITEL_ZEILE2:			DC.B ' *Peacebug Window 1.10 [999*999]* ',0
						IF GERMAN
NO_PEACEBUG:			DC.B '[3][Peacebug nicht gefunden.|][Abbruch]',0
WINDOW_FAIL:			DC.B '[3][Es kann kein weiteres Fenster|mehr ge”ffnet werden.|][Abbruch]',0
SCREEN_LOCK:			DC.B '[3][Im Moment darf nicht auf|Peacebugs Bildschirmschnitt-|stelle zugegriffen werden.|][Abbruch]',0
						ELSE
NO_PEACEBUG:			DC.B '[3][Peacebug not found.|][ Cancel ]',0
WINDOW_FAIL:			DC.B '[3][I could not open one more|window.|][ Cancel ]',0
SCREEN_LOCK:			DC.B '[3][At the moment Peacebug''s|screen interface is locked.|][ Cancel ]',0
						ENDC
						EVEN

******************	B S S  -  S E G M E N T  ***********************************

INTER_XYWH: 			DS.W 4
INTER_X:				DS.W 1
INTER_Y:				DS.W 1
INTER_W:				DS.W 1
INTER_H:				DS.W 1

*-------------------------------------------------------------------------------

MFDB_SOURCE:			DS.L 1					; Bildadresse
						DS.W 1					; Breite in Punkten
						DS.W 1					; H”he in Punkten
						DS.W 1					; Breite in Words
						DS.W 1					; Standardformat
						DS.W 1					; Anzahl Planes
						DS.W 3					; reserviert
MFDB_DEST:				DS.L 1					; Bildadresse
						DS.W 1					; Breite in Punkten
						DS.W 1					; H”he in Punkten
						DS.W 1					; Breite in Words
						DS.W 1					; Standardformat
						DS.W 1					; Anzahl Planes
						DS.W 3					; reserviert

BILDSCHIRM_ADRESSE: 	DS.L 1
OFFSET_X:				DS.W 1
OFFSET_Y:				DS.W 1
BILD_BREITE:			DS.W 1
BILD_HOEHE: 			DS.W 1

HANDLE: 				DS.W 1					; Window_handle
MAXBORDER:				DS.L 2					; maximale Aussenmasse
MAXWORK:				DS.L 2					; maximale Innenmasse
BORDER: 				DS.L 2					; aktuelle Aussenmasse
WORK:					DS.L 2					; aktuelle Innenmasse
BORDER_OLD: 			DS.L 2					; alte Aussenmasse
WORK_OLD:				DS.L 2					; alte Innenmasse
DESKTOP_MASSE:			DS.L 2					; Desktopmasse

* Aesparameter Block
CONTROL:				DS.W 5
GLOBAL: 				DS.W 15
GINTIN: 				DS.W 16
GINTOUT:				DS.W 7
ADDRIN: 				DS.L 2
ADDROUT:				DS.L 1

* Vdiparameter Block
V_HANDLE:				DS.W 1
CONTRL: 				DS.W 20
INTIN:					DS.W 20
PTSIN:					DS.W 20
INTOUT: 				DS.W 50
PTSOUT: 				DS.W 20

WINDOW: 				DS.B 1
IN_WINDOW:				DS.B 1
NICHT_GEFUNDEN: 		DS.B 1
_app:					DS.B 1
						.EVEN

COOKIE: 				DS.L 1

MESSAGE_BUFFER: 		DS.B 16

						DS.B 1024
OWN_STACK:				.END