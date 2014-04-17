********************************************************************************
*				  Peacebug, PBUGCONF V1.42							13.03.1995 *
*				  ------------------------									   *
*																			   *
* written by:	  Emanuel M”cklin											   *
*				  Rainfussweg 7												   *
*				  CH-8038 Zrich											   *
*				  peace@soziologie.unizh.ch									   *
*																			   *
* Konfigurationsprogramm zu Peacebug, l„uft als Accessory und als Programm	   *
********************************************************************************

GERMAN					EQU -1					  ; englische/deutsche Version?

VERSIONS_NUMMER			EQU '0142'				  ; never touch this
REGISTER				REG D0-A6

ANZAHL_WINDOWS			EQU 11
RECORD_LENGTH			EQU 34

WTREE					EQU 0					  ; Offsets
WTITEL					EQU 2
WOPEN					EQU 6
WCLOSE					EQU 10
WBUTTON 				EQU 14
WKEYBOARD				EQU 18
WOK 					EQU 22
WHANDLE 				EQU 26
WKEY_OBJ				EQU 28
WKEY_POS				EQU 30
WFLAG					EQU 32

*-------------------------------------------------------------------------------

PROGRAMM_ANFANG:bra			LETS_GO

*-------------------------------------------------------------------------------

RESOURCE:		.IF	GERMAN
					.INCLUDE 'GERMAN\GERMAN.S'
				.ELSE
					.INCLUDE 'ENGLISH\ENGLISH.S'
				.ENDIF

*-------------------------------------------------------------------------------

LETS_GO:		LEA 		VB(PC),A4

				MOVE.L		A0,D0
				SNE 		ACC_FLAG-VB(a4)
				BNE.S		ACC

				MOVEA.L 	4(SP),A0
				LEA 		USERSTACK-VB(a4),SP
				PEA 		PROGRAMM_ENDE-PROGRAMM_ANFANG+256
				MOVE.L		A0,-(SP)				; Basepage
				MOVE.L		#$004A0000,-(SP)
				TRAP		#1						; Speicher freigeben

ACC:			LEA 		USERSTACK-VB(a4),SP
				MOVE.W		#25,-(SP)				; DGETDRV 25
				TRAP		#1
				ADDQ.W		#2,SP
				ADD.B		#65,D0
				MOVE.B		D0,DRIVE_0-VB(a4)
				MOVE.B		#':',DRIVE_0+1-VB(a4)

				CLR.W		-(SP)
				PEA 		PATH_0-VB(a4)
				MOVE.W		#71,-(SP)				; DGETPATH 71
				TRAP		#1
				ADDQ.W		#8,SP

				LEA 		DRIVE_0-VB(a4),A0
				LEA 		DRIVE_1-VB(a4),A1
				LEA 		DRIVE_2-VB(a4),A2
				MOVEQ		#64,D0
PATH_COPY:		MOVE.L		(A0),(A1)+
				MOVE.L		(A0)+,(A2)+
				DBRA		D0,PATH_COPY

				MOVE.L		#$0A000100,D0			; APPL_INIT 10
				BSR			AES_INIT

				CMPI.W		#$0140,GLOBAL-VB(a4)	; (>=1.40 & <2.00) | >=3.00
				BLO.S		INPUT					; FSEL_EXINPUT bentzen?
				CMPI.W		#$0200,GLOBAL-VB(a4)
				BHS.S		INPUT
EXINPUT:		ST			USE_EXINPUT-VB(a4)
				BRA.S		TEST_COOKIE
INPUT:			CMPI.W		#$0300,GLOBAL-VB(a4)
				BHS.S		EXINPUT
				SF			USE_EXINPUT-VB(a4)
TEST_COOKIE:	MOVE.L		#'FSEL',D3				; oder gar FSEL-Cookie
				BSR 		SEARCH_COOKIE			; vorhanden?
				BEQ.S		NO_FSEL
				ST			USE_EXINPUT-VB(a4)

NO_FSEL:		TST.B		ACC_FLAG-VB(a4)
				BEQ.S		RSRC_OBFIX

				LEA 		FILE_2+9-VB(a4),A0
				MOVE.B		#'A',(A0)+
				MOVE.B		#'C',(A0)+
				MOVE.B		#'C',(A0)+
				MOVE.W		GLOBAL+4-VB(a4),GINTIN-VB(a4) ; Meneintrag erzeugen
				LEA 		ACCESSORY_NAME-VB(a4),A0
				MOVE.L		A0,ADDRIN-VB(a4)
				MOVE.L		#$23010101,D0			; MENU_REGISTER 35
				BSR 		AES_INIT

RSRC_OBFIX: 	MOVE.L		#rs_trindex,GLOBAL+10-VB(a4) ; Baum an Aufl”sung
				MOVE.W		#rs_nobs-1,D6			; anpassen
				MOVEQ		#0,D7
NEXT_OBJECT:	MOVE.L		#$72010101,D0			; RSRC_OBFIX 110
				MOVE.L		#rs_object,ADDRIN-VB(a4)
				MOVE.W		D7,GINTIN-VB(a4)
				ADDQ.W		#1,D7
				BSR 		AES_INIT
				DBRA		D6,NEXT_OBJECT

				BSR 		CONFIG
				TST.B		ACC_FLAG-VB(a4)			; wenn als Programm gestartet
				BEQ 		AC_OPEN					; dann gleich ”ffnen

******************	M E N U E S ************************************************

*-------------------------------------------------------------------------------
* folgende Register sind fest sobald der Maindialog verlassen wird:
* A1 = Zeiger auf Windowrecord
* A5 = Zeiger auf den Objektbaum
* D0 = Button, nur in den Routinen WBUTTON!
*-------------------------------------------------------------------------------

MAIN_DIALOG:	CLR.W		MESSAGE_BUFFER-VB(a4)
				MOVE.L		#$00130002,GINTIN-VB(a4)
				MOVE.L		#$00010001,GINTIN+4-VB(a4)
				MOVE.L		#MESSAGE_BUFFER,ADDRIN-VB(a4)
				MOVE.L		#$19100701,D0			; EVNT_MULTI 25
				BSR 		AES_INIT				; Key, Button, Message

				MOVE.W		GINTOUT-VB(a4),D7
				BTST		#0,D7					; Keyboard?
				BEQ.S		KEIN_KEY
				BSR 		KEYBOARD_EVENT
KEIN_KEY:		BTST		#1,D7					; Button?
				BEQ.S		KEIN_BUTTON
				BSR 		BUTTON_EVENT

KEIN_BUTTON:	LEA 		MESSAGE_BUFFER-VB(a4),A0
				CMPI.W		#40,(A0)				; AC_OPEN?
				BEQ 		AC_OPEN
				CMPI.W		#$4711,(A0)
				BEQ 		AC_OPEN
				CMPI.W		#41,(A0)				; AC_CLOSE?
				BEQ 		AC_CLOSE

				MOVE.W		6(A0),D0				; ist es mein Window?
				BSR 		FIND_WINDOW
				BEQ.S		MAIN_DIALOG

* ---> A0 = Messagebuffer, A1 = Record, A5 = Baumzeiger
				CMPI.W		#21,(A0)				; topped,redraw,closed,moved
				BEQ.S		WM_TOPPED
				CMPI.W		#20,(A0)
				BEQ.S		WM_REDRAW
				CMPI.W		#22,(A0)
				BEQ.S		WM_CLOSED
				CMPI.W		#28,(A0)
				BEQ 		WM_MOVED
				CMPI.W		#30,(A0)
				BEQ 		WM_UNTOPPED
				CMPI.W		#31,(A0)
				BEQ.S		WM_TOP
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

WM_TOPPED:		MOVEQ		#10,D3
				BSR 		WIND_SET				; toppen
WM_TOP: 		TST.W		WKEY_OBJ(A1)
				BEQ 		MAIN_DIALOG
				MOVEQ		#0,D3
				BSR 		OBJC_DRAW
				BSR 		CURSOR_ON
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

WM_REDRAW:		MOVEM.L 	8(A0),D0-D1
				MOVEM.L 	D0-D1,INTER_XYWH-VB(a4)
				TST.W		WKEY_OBJ(A1)
				SEQ 		INTERSECT-VB(a4)
				BEQ.S		NORMAL_REDRAW
				MOVEQ		#10,D3
				BSR 		WIND_GET				; Top Window
				SWAP		D0						; D0.w=Handle
				CMP.W		WHANDLE(A1),D0
				SNE 		INTERSECT-VB(a4)
				BNE.S		NORMAL_REDRAW
				MOVEQ		#0,D3
				BSR 		OBJC_DRAW
				BSR 		CURSOR_ON
				BRA 		MAIN_DIALOG

NORMAL_REDRAW:	MOVEQ		#0,D3
				BSR 		OBJC_DRAW
				SF			INTERSECT-VB(a4)
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

WM_CLOSED:		MOVE.L		WOK(A1),D0				; WCLOSE kann auch von WBUTTON
				BEQ 		MAIN_DIALOG				; aufgerufen werden, weshalb
				MOVEA.L 	D0,A0					; WFLAG nicht hier gel”scht
				JSR 		(A0)					; werden muss
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

WM_MOVED:		MOVE.L		8(A0),GINTIN+4-VB(a4)
				MOVE.L		12(A0),GINTIN+8-VB(a4)
				MOVEQ		#5,D3
				BSR 		WIND_SET				; neue Fensterposition
				MOVEQ		#4,D3
				MOVE.W		WHANDLE(A1),GINTIN-VB(a4)
				BSR 		WIND_GET
				MOVE.L		D0,16(A5)
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

WM_UNTOPPED:	TST.W		WKEY_OBJ(A1)
				BEQ 		MAIN_DIALOG
				MOVEQ		#0,D3
				BSR 		OBJC_DRAW
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

AC_CLOSE:		LEA 		RECORDS-VB(a4),A1
				MOVEQ		#ANZAHL_WINDOWS-1,D7
LOOP_1: 		SF			WFLAG(A1)
				LEA 		RECORD_LENGTH(A1),A1
				DBRA		D7,LOOP_1
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

AC_OPEN:		LEA 		WRECORD_0(PC),A1
				BSR 		RSRC_GADDR
				BSR 		SEARCH_PEACEBUG
				SEQ 		PATCH_MODUS-VB(a4)
				BSR 		MAUS_PFEIL
				TST.B		WFLAG(A1)
				BNE 		WM_TOPPED
				MOVE.L		WOPEN(A1),D0
				BEQ 		MAIN_DIALOG
				MOVEA.L 	D0,A0
				JSR 		(A0)
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

KEYBOARD_EVENT: MOVE.W		GINTOUT+10-VB(a4),D7	; D7=Scancode*256+asciicode

				MOVEQ		#10,D3
				BSR 		WIND_GET
				SWAP		D0						; D0.w=Handle oberstes Window
				BSR 		FIND_WINDOW
				BEQ 		RTS
				BSR 		RSRC_GADDR

*---------------

				CMP.B		#$11,D7					; Control Q?
				BNE.S		NO_CONTROL_Q
				LEA 		WRECORD_0-VB(a4),A1
				BRA 		WCLOSE_0
NO_CONTROL_Q:	CMP.B		#$17,D7					; Control W?
				BEQ 		WM_CLOSED
				CMP.W		#$6100,D7				; UNDO?
				BNE.S		NO_UNDO


				MOVEA.L 	A5,A2
				MOVEQ		#0,D0
SEARCH_ABBRUCH: BTST		#5,9(A2)
				BNE.S		NO_UNDO
				CMPI.W		#26,6(A2)
				BNE.S		NO_ABBRUCH
				MOVEA.L 	12(A2),A3
				LEA 		STRING_ABBRUCH-VB(a4),A6
TEST_STRING:	TST.B		(A6)
				BEQ.S		ABBRUCH_FOUND
				CMPM.B		(A3)+,(A6)+
				BEQ.S		TEST_STRING
NO_ABBRUCH: 	ADDQ.W		#1,D0
				LEA 		24(A2),A2
				BRA.S		SEARCH_ABBRUCH
ABBRUCH_FOUND:	MOVEQ		#1,D1
				MOVE.L		WBUTTON(A1),D2
				BEQ 		RTS
				MOVEA.L 	D2,A0
				JMP 		(A0)

*---------------

NO_UNDO:		MOVE.W		D7,D0
				BSR 		FORM_KEYBD
				BEQ.S		CALL_OK
				TST.W		GINTOUT+4-VB(a4)
				BEQ.S		TOGGLE
				TST.W		WKEY_OBJ(A1)
				BEQ.S		CALL_KEY
				MOVE.W		D7,D0
				MOVEQ		#2,D3
				BSR 		OBJC_EDIT
				BRA 		MAIN_DIALOG

CALL_KEY:		MOVE.L		WKEYBOARD(A1),D0
				BEQ 		MAIN_DIALOG
				MOVEA.L 	D0,A2
				JSR 		(A2)
				BRA 		MAIN_DIALOG

CALL_OK:		MOVE.L		WOK(A1),D0
				BEQ 		MAIN_DIALOG
				MOVEA.L 	D0,A2
				JSR 		(A2)
				BRA 		MAIN_DIALOG

TOGGLE: 		MOVE.W		GINTOUT+2-VB(a4),D0
				BSR 		CURSOR_OFF
				MOVE.W		D0,WKEY_OBJ(A1)
				BSR 		CURSOR_ON
				BRA 		MAIN_DIALOG

*-------------------------------------------------------------------------------

* Die Buttonroutinen werden mit Button=D0.w, Anzahl Klicks=D1.w aufgerufen
BUTTON_EVENT:	MOVE.W		GINTOUT+12-VB(a4),D1

				MOVE.L		#$4F000500,D0			; GRAF_MKSTATE
				BSR 		AES_INIT
				MOVEM.W 	GINTOUT+2-VB(a4),D6-D7

				MOVEM.W 	D6-D7,GINTIN-VB(a4)
				MOVE.L		#$6A020100,D0			; WIND_FIND 106
				BSR 		AES_INIT
				MOVE.W		GINTOUT-VB(a4),D0
				BSR.S		FIND_WINDOW
				BEQ 		RTS
				MOVEQ		#10,D3
				MOVE.L		D1,-(SP)
				BSR 		WIND_GET
				MOVE.L		(SP)+,D1
				SWAP		D0						; D0.w=Handle oberstes Window
				CMP.W		WHANDLE(A1),D0
				BNE 		RTS
				BSR 		RSRC_GADDR

				CLR.W		GINTIN-VB(a4)
				MOVE.W		#8,GINTIN+2-VB(a4)
				MOVEM.W 	D6-D7,GINTIN+4-VB(a4)
				MOVE.L		A5,ADDRIN-VB(a4)
				MOVE.L		#$2B040101,D0
				BSR 		AES_INIT				; OBJC_FIND 43
				MOVE.W		GINTOUT-VB(a4),D0
				BMI 		RTS

				MOVE.W		D0,D3					; editierbar?
				BSR 		CALCULATE_OBJECT
				BTST		#3,9(A0)
				BEQ.S		NOT_EDITABLE
				BSR 		CURSOR_OFF
				MOVE.W		D0,WKEY_OBJ(A1)
				BSR 		CURSOR_ON
NOT_EDITABLE:	BTST		#6,9(A0)				; touchexit?
				BNE.S		TOUCHEXIT
				BTST		#0,9(A0)				; selektierbar?
				BEQ 		RTS

TOUCHEXIT:		MOVE.L		WBUTTON(A1),D2
				BEQ 		RTS
				MOVEA.L 	D2,A0
				JMP 		(A0)

*-------------------------------------------------------------------------------

* ---> D0.w = Handle
* <--- flag.eq = nichts gefunden, A1 = Record, A5 = Baumadresse
FIND_WINDOW:	MOVEM.L 	D0-A0/A2-A3/A6,-(SP)
				LEA 		RECORDS-VB(a4),A1
				MOVEQ		#ANZAHL_WINDOWS-1,D7
LOOP_4: 		TST.B		WFLAG(A1)
				BEQ.S		NO_WINDOW_3
				CMP.W		WHANDLE(A1),D0
				BEQ.S		WINDOW_FOUND
NO_WINDOW_3:	LEA 		RECORD_LENGTH(A1),A1
				DBRA		D7,LOOP_4
				MOVEM.L 	(SP)+,D0-A0/A2-A3/A6
				SF			-(SP)
				TST.B		(SP)+
				RTS
WINDOW_FOUND:	BSR 		RSRC_GADDR
				MOVEM.L 	(SP)+,D0-A0/A2-A3/A6
				ST			-(SP)
				TST.B		(SP)+
				RTS

*-------------------------------------------------------------------------------

WOPEN_0:		LEA 		WRECORD_0(PC),A1
				BSR 		RSRC_GADDR
				BSR 		SET_MODUS
				MOVE.L		#$4F000500,D0			; GRAF_MKSTATE 79
				BSR 		AES_INIT
				MOVE.L		GINTOUT+2-VB(a4),16(A5)	; Objektbaumkoordinaten X/Y
				BRA 		WINDOW_OPEN

*-------------------------------------------------------------------------------

WCLOSE_0:		BSR 		CLOSE_WINDOW
				LEA 		RECORDS+RECORD_LENGTH-VB(a4),A1
				MOVEQ		#ANZAHL_WINDOWS-2,D7
LOOP:			TST.B		WFLAG(A1)
				BEQ.S		DONT_CLOSE_2
				MOVE.L		WCLOSE(A1),D0
				BEQ.S		DONT_CLOSE_2
				MOVEA.L 	D0,A0
				JSR 		(A0)
DONT_CLOSE_2:	LEA 		RECORD_LENGTH(A1),A1
				DBRA		D7,LOOP
				TST.B		ACC_FLAG-VB(a4)
				BNE 		RTS
				TST.B		STAY_RESIDENT-VB(a4)
				BNE.S		RESIDENT
				MOVE.L		#$13000100,D0			; APPL_EXIT 19
				BSR 		AES_INIT
				CLR.W		-(SP)
				TRAP		#1						; PTERM0

RESIDENT:		LEA 		RESIDENT_MESSAGE-VB(a4),A3
				BSR 		FORM_ALERT
				MOVE.L		#$13000100,D0			; APPL_EXIT 19
				BSR 		AES_INIT
				CLR.W		-(SP)					; Basepage resident halten
				PEA 		256.w
				MOVE.W		#49,-(SP)
				TRAP		#1

*-------------------------------------------------------------------------------

WBUTTON_0:		MOVE.W		D0,D3
				BSR 		SET_OB_STATE			; Invertieren
				BSR 		OBJC_DRAW

				MOVEM.L 	#REGISTER,-(SP)
				ADD.W		D3,D3
				MOVE.W		RECORD_TABELLE-2(PC,D3.w),D0
				BEQ.S		NO_WINDOW_2
				LEA 		RECORD_TABELLE(PC,D0.w),A1
				BSR 		RSRC_GADDR
				TST.B		WFLAG(A1)
				BNE.S		NUR_TOPPEN
				MOVE.L		#$4F000500,D0			; GRAF_MKSTATE
				BSR 		AES_INIT
				MOVE.L		GINTOUT+2-VB(a4),16(A5)  ; Objektbaumkoordinaten X/Y
NO_WINDOW_2:	MOVE.W		SPRUNG_TABELLE-2(PC,D3.w),D3
				JSR 		SPRUNG_TABELLE(PC,D3.w)

DONT_JUMP:		MOVEM.L 	(SP)+,#REGISTER
				BSR 		CLEAR_OB_STATE
				BRA 		OBJC_DRAW

NUR_TOPPEN: 	MOVEQ		#10,D3
				BSR 		WIND_SET				; toppen
				TST.W		WKEY_OBJ(A1)
				BEQ.S		DONT_JUMP
				MOVEQ		#0,D3
				BSR 		OBJC_DRAW
				BSR 		CURSOR_ON
				BRA.S		DONT_JUMP

*-------------------------------------------------------------------------------

SPRUNG_TABELLE: 		DC.W WOPEN_1-SPRUNG_TABELLE,RTS-SPRUNG_TABELLE
						DC.W WOPEN_2-SPRUNG_TABELLE,WOPEN_3-SPRUNG_TABELLE,WOPEN_4-SPRUNG_TABELLE
						DC.W WOPEN_5-SPRUNG_TABELLE,WOPEN_6-SPRUNG_TABELLE,WOPEN_7-SPRUNG_TABELLE
						DC.W WOPEN_8-SPRUNG_TABELLE,WOPEN_9-SPRUNG_TABELLE,RTS-SPRUNG_TABELLE
						DC.W PARAMETERLADEN-SPRUNG_TABELLE,PARAMETERSPEICHERN-SPRUNG_TABELLE
						DC.W RTS-SPRUNG_TABELLE,WOPEN_10-SPRUNG_TABELLE
						DC.W CHANGE_MODUS-SPRUNG_TABELLE,CHANGE_MODUS-SPRUNG_TABELLE

*-------------------------------------------------------------------------------

RECORD_TABELLE: 		DC.W WRECORD_1-RECORD_TABELLE,0,WRECORD_2-RECORD_TABELLE
						DC.W WRECORD_3-RECORD_TABELLE,WRECORD_4-RECORD_TABELLE
						DC.W WRECORD_5-RECORD_TABELLE,WRECORD_6-RECORD_TABELLE
						DC.W WRECORD_7-RECORD_TABELLE,WRECORD_8-RECORD_TABELLE
						DC.W WRECORD_9-RECORD_TABELLE,0,0,0,0
						DC.W WRECORD_10-RECORD_TABELLE,0,0

*-------------------------------------------------------------------------------

WKEYBOARD_0:	TST.B		D7
				BLS 		RTS
				CMP.B		#22,D7
				BHI 		RTS
				MOVEQ		#1,D1
				AND.W		#$00FF,D7
				ADD.W		D7,D7
				MOVE.W		WKEYBOARD_TABELLE-2(PC,D7.w),D0
				BNE 		WBUTTON_0
				RTS

; Control A=ASCII 1, Control B=ASCII 2 etc.
WKEYBOARD_TABELLE:		DC.W 10,7,4,6,15,0,0,0,1,0,5,0,0,0,12,8,0,9,13,17,0,3

*-------------------------------------------------------------------------------

WOPEN_1:		MOVE.L		#'0000',D0
				TST.B		PATCH_MODUS-VB(a4)
				BNE.S		NO_VERSION
				BSR 		SEARCH_PEACEBUG
				BEQ.S		NO_VERSION

				MOVE.L		32(A0),D0				; Versionsnummer eintragen
NO_VERSION: 	MOVEQ		#_VERSION,D3
				BSR 		CALCULATE_OBJECT
				MOVEA.L 	12(A0),A0
				LEA 		10(A0),A0
				ROL.L		#8,D0
				MOVE.B		D0,(A0)
				CMP.B		#'0',D0
				BEQ.S		A_ZERO
				ADDQ.W		#1,A0
A_ZERO: 		ROL.L		#8,D0
				MOVE.B		D0,(A0)+
				MOVE.B		#'.',(A0)+
				ROL.L		#8,D0
				MOVE.B		D0,(A0)+
				ROL.L		#8,D0
				MOVE.B		D0,(A0)+
				CLR.B		(A0)+
				BRA 		WINDOW_OPEN

*-------------------------------------------------------------------------------

WOPEN_2:		BSR 		GET_FLAGS
				BSR 		PUTBOX_FLAGS
				BRA 		WINDOW_OPEN

*-------------------------------------------------------------------------------

WBUTTON_2:		MOVE.W		D0,D3
				BSR 		FORM_BUTTON

				CMP.B		#_OK2,D0
				BEQ 		OK2
				CMP.B		#_SETZEN2,D0
				BEQ 		SETZEN2
				CMP.B		#_ABBRUCH2,D0
				BEQ 		CLOSE_WINDOW
				CMP.B		#_DEBUGGER,D0
				BEQ 		RTS
				CMP.B		#_ORIGINAL,D0
				BEQ 		RTS
				CMP.B		#_IGNORE,D0
				BEQ 		RTS
				CMP.B		#_AUSHAENG,D0
				BEQ 		AUS_ON
				CMP.B		#_EINHAENG,D0
				BEQ 		AUS_OFF
				CMP.B		#_POS1ST,D0
				BEQ 		AUS_OFF
				CMP.B		#_SR_EA,D0
				BEQ 		SR_CCR
				CMP.B		#_CCR_EA,D0
				BEQ 		CCR_SR
				CMP.B		#_ALWAYS,D0
				BEQ 		ALWAYS
				CMP.B		#_ONCEASEC,D0
				BEQ 		ONCEASEC

				CMP.B		FLAGS_CHOOSE-VB(a4),D0
				BEQ 		RTS
				BSR 		GET_FLAG
				MOVE.B		D0,FLAGS_CHOOSE-VB(a4)
				BSR 		PUT_FLAG
				MOVEQ		#_DEBUGGER,D3
				BSR 		OBJC_DRAW
				MOVEQ		#_ORIGINAL,D3
				BSR 		OBJC_DRAW
				MOVEQ		#_IGNORE,D3
				BSR 		OBJC_DRAW
				MOVEQ		#_AUSHAENG,D3
				BSR 		OBJC_DRAW
				MOVEQ		#_EINHAENG,D3
				BSR 		OBJC_DRAW
				MOVEQ		#_POS1ST,D3
				BSR 		OBJC_DRAW
				MOVEQ		#_BOX_3,D3
				BRA 		OBJC_DRAW

*-------------------------------------------------------------------------------

OK2:			PEA 		CLOSE_WINDOW(PC)
COMMON2:		MOVEM.L 	#REGISTER,-(SP)
				BSR 		GET_FLAG
				LEA 		FLAGS-VB(a4),A3
				LEA 		LOCAL_FLAGS-VB(a4),A2
				BSR 		COPY_FLAGS
				BSR 		PUT_FLAGS
				MOVEM.L 	(SP)+,#REGISTER
				RTS

*-------------------------------------------------------------------------------

SETZEN2:		MOVEM.L 	#REGISTER,-(SP)
				BSR.S		COMMON2
				MOVEQ		#_SETZEN2,D3
TERMINATE_SETZEN:BSR		CLEAR_OB_STATE
				BSR 		OBJC_DRAW
				MOVEM.L 	(SP)+,#REGISTER
				RTS

*-------------------------------------------------------------------------------

AUS_ON: 		MOVEQ		#_POS1ST,D3
				BSR 		CLEAR_OB_STATE
				BSR 		OBJC_DRAW
				MOVEQ		#_EINHAENG,D3
				BSR 		CLEAR_OB_STATE
				BRA 		OBJC_DRAW

*-------------------------------------------------------------------------------

AUS_OFF:		MOVEQ		#_AUSHAENG,D3
				BSR 		CLEAR_OB_STATE
				BRA 		OBJC_DRAW

*-------------------------------------------------------------------------------

SR_CCR: 		MOVEQ		#_CCR_EA,D3
				BRA.S		CLEAR_
CCR_SR: 		MOVEQ		#_SR_EA,D3
				BRA.S		CLEAR_
ALWAYS: 		MOVEQ		#_ONCEASEC,D3
				BRA.S		CLEAR_
ONCEASEC:		MOVEQ		#_ALWAYS,D3
CLEAR_: 		BSR 		CLEAR_OB_STATE
				BRA 		OBJC_DRAW

*-------------------------------------------------------------------------------

PUTBOX_FLAGS:	MOVEM.L 	#REGISTER,-(SP)
				BSR 		CLEAR_BUTTONS
				LEA 		FLAGS-VB(a4),A2
				LEA 		LOCAL_FLAGS-VB(a4),A3
				BSR 		COPY_FLAGS
				MOVEQ		#0,D3
				MOVE.B		FLAGS_CHOOSE-VB(a4),D3
				BSR 		SET_OB_STATE
				BSR 		PUT_FLAG
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

GET_FLAG:		MOVEM.L 	#REGISTER,-(SP)

				MOVEQ		#0,D0
				MOVEQ		#_DEBUGGER,D3
				BSR 		GET_OB_STATE
				BEQ.S		NOT_FIRST
				MOVEQ		#1,D0
NOT_FIRST:		MOVEQ		#_IGNORE,D3
				BSR 		GET_OB_STATE
				BEQ.S		NOT_SECOND
				MOVEQ		#2,D0

NOT_SECOND: 	CMPI.B		#_PRIVILEG,FLAGS_CHOOSE-VB(a4)
				BNE.S		NOT_PRIVILEG
				MOVEQ		#_SR_EA,D3
				BSR 		GET_OB_STATE
				BEQ.S		NOT_SR_EA
				BSET		#4,D0
NOT_SR_EA:		MOVEQ		#_CCR_EA,D3
				BSR 		GET_OB_STATE
				BEQ.S		NOT_RESET
				BSET		#5,D0

NOT_PRIVILEG:	CMPI.B		#_RESETFLAG,FLAGS_CHOOSE-VB(a4)
				BNE.S		NOT_RESET
				MOVEQ		#_ALWAYS,D3
				BSR 		GET_OB_STATE
				BEQ.S		NOT_ALWAYS
				BSET		#4,D0
NOT_ALWAYS: 	MOVEQ		#_ONCEASEC,D3
				BSR 		GET_OB_STATE
				BEQ.S		NOT_RESET
				BSET		#5,D0

NOT_RESET:		BSR 		FLAG_ADRESS
				MOVE.B		D0,1(A0)

				MOVEQ		#_AUSHAENG,D3
				BSR 		GET_OB_STATE
				BEQ.S		NOT_AUSHAENG
				MOVEQ		#0,D0
				BRA.S		CONT_VEKTOR
NOT_AUSHAENG:	MOVEQ		#2,D0
				MOVEQ		#_EINHAENG,D3
				BSR 		GET_OB_STATE
				BEQ.S		NO_EINHAENG
				MOVEQ		#1,D0
NO_EINHAENG:	MOVEQ		#_POS1ST,D3
				BSR 		GET_OB_STATE
				BEQ.S		CONT_VEKTOR
				NEG.B		D0
CONT_VEKTOR:	BSR 		FLAG_ADRESS
				MOVE.B		D0,(A0)
				BRA 		RTS_REG

*----------------------------------------------------------------------------- --

PUT_FLAG:		MOVEM.L 	#REGISTER,-(SP)

				MOVEQ		#_SR_EA,D3
				BSR 		CALCULATE_OBJECT
				BSET		#7,9(A0)
				MOVEQ		#_CCR_EA,D3
				BSR 		CALCULATE_OBJECT
				BSET		#7,9(A0)
				CMPI.B		#_PRIVILEG,FLAGS_CHOOSE-VB(a4)
				BNE.S		NO_PRIVILEG
				MOVEQ		#_SR_EA,D3
				BSR 		CALCULATE_OBJECT
				BCLR		#7,9(A0)
				MOVEQ		#_CCR_EA,D3
				BSR 		CALCULATE_OBJECT
				BCLR		#7,9(A0)

NO_PRIVILEG:	MOVEQ		#_ALWAYS,D3
				BSR 		CALCULATE_OBJECT
				BSET		#7,9(A0)
				MOVEQ		#_ONCEASEC,D3
				BSR 		CALCULATE_OBJECT
				BSET		#7,9(A0)
				CMPI.B		#_RESETFLAG,FLAGS_CHOOSE-VB(a4)
				BNE.S		NO_RESET
				MOVEQ		#_ALWAYS,D3
				BSR 		CALCULATE_OBJECT
				BCLR		#7,9(A0)
				MOVEQ		#_ONCEASEC,D3
				BSR 		CALCULATE_OBJECT
				BCLR		#7,9(A0)

NO_RESET:		MOVEQ		#_DEBUGGER,D3
				BSR			CLEAR_OB_STATE
				MOVEQ		#_ORIGINAL,D3
				BSR			CLEAR_OB_STATE
				MOVEQ		#_IGNORE,D3
				BSR			CLEAR_OB_STATE
				MOVEQ		#_AUSHAENG,D3
				BSR			CLEAR_OB_STATE
				MOVEQ		#_EINHAENG,D3
				BSR			CLEAR_OB_STATE
				MOVEQ		#_POS1ST,D3
				BSR			CLEAR_OB_STATE

				BSR 		FLAG_ADRESS
				MOVE.B		1(A0),D0
				BTST		#0,D0
				BEQ.S		NO_DEBUGGER
				MOVEQ		#_DEBUGGER,D3
				BSR 		SET_OB_STATE
				BRA.S		CONT_FLAGS
NO_DEBUGGER:	BTST		#1,D0
				BEQ.S		NO_IGNORE
				MOVEQ		#_IGNORE,D3
				BSR 		SET_OB_STATE
				BRA.S		CONT_FLAGS
NO_IGNORE:		MOVEQ		#_ORIGINAL,D3
				BSR 		SET_OB_STATE

CONT_FLAGS: 	CMPI.B		#_PRIVILEG,FLAGS_CHOOSE-VB(a4)
				BNE.S		KEIN_PRIVILEG
				BTST		#4,D0
				BEQ.S		NO_SR_EA
				MOVEQ		#_SR_EA,D3
				BSR 		SET_OB_STATE
NO_SR_EA:		BTST		#5,D0
				BEQ.S		KEIN_RESET
				MOVEQ		#_CCR_EA,D3
				BSR 		SET_OB_STATE
				BRA.S		KEIN_RESET

KEIN_PRIVILEG:	CMPI.B		#_RESETFLAG,FLAGS_CHOOSE-VB(a4)
				BNE.S		KEIN_RESET
				BTST		#4,D0
				BEQ.S		NO_ALWAYS
				MOVEQ		#_ALWAYS,D3
				BSR 		SET_OB_STATE
NO_ALWAYS:		BTST		#5,D0
				BEQ.S		KEIN_RESET
				MOVEQ		#_ONCEASEC,D3
				BSR 		SET_OB_STATE

KEIN_RESET: 	MOVE.B		(A0),D0
				BEQ.S		ZERO
				BMI.S		NEGATIV

CHECK_EINHAENG: SUBQ.B		#1,D0
				BNE.S		RTS_REG
				MOVEQ		#_EINHAENG,D3
				BSR 		SET_OB_STATE
				BRA.S		RTS_REG

NEGATIV:		MOVEQ		#_POS1ST,D3
				BSR 		SET_OB_STATE
				NEG.B		D0
				BRA.S		CHECK_EINHAENG

ZERO:			MOVEQ		#_AUSHAENG,D3
				BSR 		SET_OB_STATE
				BRA.S		RTS_REG

*-------------------------------------------------------------------------------

FLAG_ADRESS:	MOVEQ		#0,D3
				MOVE.B		FLAGS_CHOOSE-VB(a4),D3
				CMP.B		#_FLAG12,D3
				BLS.S		ROW_1ST
				CMP.B		#_FLAG22,D3
				BLS.S		ROW_2ST
				SUB.B		#_FLAG31-32,D3
				BRA.S		CONT_FLAG
ROW_2ST:		SUB.B		#_FLAG21-16,D3
				BRA.S		CONT_FLAG
ROW_1ST:		SUB.B		#_FLAG11,D3
CONT_FLAG:		ADD.W		D3,D3
				LEA 		LOCAL_FLAGS(PC),A0
				ADDA.W		D3,A0
				RTS

*-------------------------------------------------------------------------------

GET_FLAGS:		MOVEM.L 	#REGISTER,-(SP)
				TST.B		PATCH_MODUS-VB(a4)
				BNE.S		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ.S		RTS_REG
				MOVEA.L 	64(A0),A2
				LEA 		FLAGS-VB(a4),A3
				BSR.S		COPY_FLAGS
RTS_REG:		MOVEM.L 	(SP)+,#REGISTER
RTS:			RTS

*-------------------------------------------------------------------------------

PUT_FLAGS:		MOVEM.L 	#REGISTER,-(SP)
				TST.B		PATCH_MODUS-VB(a4)
				BNE.S		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		WO_ISSER_REG
				MOVEA.L 	64(A0),A3
				LEA 		FLAGS-VB(a4),A2
				BSR.S		COPY_FLAGS
				MOVE.L		68(A0),-(SP)			; Routine VEKTOR
				BSR 		CALL_SUPER
				BRA.S		RTS_REG

*-------------------------------------------------------------------------------

COPY_FLAGS: 	moveq		#95,d0
.copy:			move.b		(a2)+,(a3)+
				dbra		d0,.copy
				rts

*-------------------------------------------------------------------------------

WOPEN_3:		BSR 		GET_CACHE
				BSR.S		PUTBOX_CACHE
				BRA 		WINDOW_OPEN

*-------------------------------------------------------------------------------

WBUTTON_3:		MOVE.W		D0,D3
				BSR 		FORM_BUTTON
				LEA 		GINTOUT-VB(a4),A0
				CMP.B		#_OK3,D0
				BEQ.S		OK3
				CMP.B		#_SETZEN3,D0
				BEQ.S		SETZEN3
				CMP.B		#_ABBRUCH3,D0
				BEQ 		CLOSE_WINDOW
				RTS

*-------------------------------------------------------------------------------

OK3:			PEA 		CLOSE_WINDOW(PC)
COMMON3:		BSR 		GETBOX_CACHE
				BRA 		PUT_CACHE

*-------------------------------------------------------------------------------

SETZEN3:		MOVEM.L 	#REGISTER,-(SP)
				BSR 		CURSOR_OFF
				BSR.S		COMMON3
				BSR 		GET_CACHE
				BSR.S		PUTBOX_CACHE
				MOVEQ		#_SETZEN3,D3
TERMINATE_SETZEN_2:BSR		CLEAR_OB_STATE
				MOVEQ		#0,D3
				BSR 		CLEAR_OB_STATE
				BSR 		OBJC_DRAW
				BSR 		CURSOR_ON
				MOVEM.L 	(SP)+,#REGISTER
				RTS

*-------------------------------------------------------------------------------

PUTBOX_CACHE:	MOVEM.L 	#REGISTER,-(SP)
				BSR 		CLEAR_BUTTONS

				MOVEQ		#_LENGTH1,D3
				MOVEQ		#0,D4
				MOVE.W		LENGTH1-VB(a4),D4
				MOVEQ		#5,D5
				MOVEQ		#19,D6
				BSR 		PUT_STRING
				MOVEQ		#_LENGTH2,D3
				MOVE.W		LENGTH2-VB(a4),D4
				BSR 		PUT_STRING
				MOVEQ		#_LENGTH,D3
				MOVE.W		LENGTH-VB(a4),D4
				BSR 		PUT_STRING
				MOVEQ		#_HIST_KB,D3
				MOVE.L		HIST_KB-VB(a4),D4
				BSR 		PUT_STRING
				MOVEQ		#_HIST_NR,D3
				MOVE.L		HIST_NR-VB(a4),D4
				BSR 		PUT_STRING

				MOVEQ		#_ADD1,D3
				MOVE.W		ADD1-VB(a4),D4
				BSR 		PUT_EDIT
				MOVEQ		#_ADD2,D3
				MOVE.W		ADD2-VB(a4),D4
				BSR 		PUT_EDIT
				MOVEQ		#_HISTORY,D3
				MOVE.L		HISTORY-VB(a4),D4
				BSR 		PUT_EDIT
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

GETBOX_CACHE:	MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#_ADD1,D3
				BSR 		GET_EDIT
				CMP.L		#$0000FFFF,D0
				BLS.S		ADD_1_IO
				MOVEQ		#-1,D0
ADD_1_IO:		MOVE.W		D0,ADD1-VB(a4)
				MOVEQ		#_ADD2,D3
				BSR 		GET_EDIT
				CMP.L		#$0000FFFF,D0
				BLS.S		ADD_2_IO
				MOVEQ		#-1,D0
ADD_2_IO:		MOVE.W		D0,ADD2-VB(a4)
				MOVEQ		#_HISTORY,D3
				BSR 		GET_EDIT
				MOVE.L		D0,HISTORY-VB(a4)
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

GET_CACHE:		MOVEM.L 	#REGISTER,-(SP)
				LEA 		LENGTH1-VB(a4),A0
				CLR.L		(A0)+
				CLR.L		(A0)+
				CLR.L		(A0)+
				CLR.W		(A0)
				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		RTS_REG
				MOVEA.L 	24(A0),A1
				MOVEA.L 	36(A0),A2
				LEA 		LENGTH1-VB(a4),A3
				MOVE.W		148(A2),(A3)+
				MOVE.W		154(A2),(A3)+
				MOVE.W		142(A2),(A3)+
				MOVE.L		126(A2),D0
				MOVE.L		D0,(A3)+
				DIVU		48(A1),D0
				AND.L		#$0000FFFF,D0
				MOVE.L		D0,(A3)+
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

PUT_CACHE:		pea			SUPER_CACHE(pc)
				bsr			CALL_SUPER
				rts
SUPER_CACHE:	MOVEM.L 	#REGISTER,-(SP)
				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		WO_ISSER_REG
				MOVEQ		#0,D6
				MOVEQ		#0,D7
				MOVEA.L 	36(A0),A0
				MOVE.W		ADD1-VB(a4),-(SP)
				MOVE.W		ADD2-VB(a4),-(SP)
				MOVEA.L	 	138(A0),a1			; CACHE_INIT
				jsr			(a1)
				TST.L		(SP)+
				SEQ 		D6
				MOVEQ		#0,D7
				MOVE.L		HISTORY-VB(a4),D0
				CMP.L		HIST_KB-VB(a4),D0
				BLS.S		NO_MALLOC
				MOVE.L		D0,-(SP)
				MOVEA.L	 	118(A0),a1			; NEW_HISTORY
				jsr			(a1)
				TST.L		(SP)+
				SEQ 		D7
NO_MALLOC:		ADD.B		D6,D7
				BEQ 		RTS_REG
				LEA 		MALLOC_ERROR-VB(a4),A3
				BSR 		FORM_ALERT
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

WOPEN_4:		BSR 		GET_KEYBOARD
				BSR 		PUTBOX_KEYBOARD
				BRA 		WINDOW_OPEN

*-------------------------------------------------------------------------------

WBUTTON_4:		MOVE.W		D0,D3
				BSR 		GET_OB_STATE
				SNE 		D7
				BSR 		FORM_BUTTON

				CMP.B		#_OK4,D0
				BEQ.S		OK4
				CMP.B		#_SETZEN4,D0
				BEQ.S		SETZEN4
				CMP.B		#_ABBRUCH4,D0
				BEQ 		CLOSE_WINDOW
				CMP.B		#_JUMPIN1,D0
				BEQ.S		JUMPIN1
				CMP.B		#_JUMPIN2,D0
				BEQ.S		JUMPIN2

				TST.B		D7
				BEQ 		RTS
				BSR 		CLEAR_OB_STATE
				BRA 		OBJC_DRAW

*-------------------------------------------------------------------------------

OK4:			PEA 		CLOSE_WINDOW(PC)
COMMON4:		BSR 		GETBOX_KEYBOARD
				BRA 		PUT_KEYBOARD

*-------------------------------------------------------------------------------

SETZEN4:		MOVEM.L 	#REGISTER,-(SP)
				BSR.S		COMMON4
				BSR 		GETBOX_KEYBOARD
				BSR 		PUT_KEYBOARD
				MOVEQ		#_SETZEN4,D3
				BRA 		TERMINATE_SETZEN

*-------------------------------------------------------------------------------

JUMPIN1:		CMPI.B		#_JUMPIN1,KEYBOARD_CHOOSE-VB(a4)
				BEQ 		RTS
				BSR 		GETBOX_KEYBOARD
				MOVE.B		#_JUMPIN1,KEYBOARD_CHOOSE-VB(a4)

				BRA.S		JUMPIN
JUMPIN2:		CMPI.B		#_JUMPIN2,KEYBOARD_CHOOSE-VB(a4)
				BEQ 		RTS
				BSR 		GETBOX_KEYBOARD
				MOVE.B		#_JUMPIN2,KEYBOARD_CHOOSE-VB(a4)
JUMPIN: 		BSR.S		PUTBOX_KEYBOARD
				MOVEQ		#_KEYS,D3
				BRA 		OBJC_DRAW

*-------------------------------------------------------------------------------

PUTBOX_KEYBOARD:MOVEM.L 	#REGISTER,-(SP)
				BSR 		CLEAR_BUTTONS

				MOVEQ		#0,D3
				MOVE.B		KEYBOARD_CHOOSE-VB(a4),D3
				BSR 		SET_OB_STATE

				MOVEQ		#$7F,D0
				CMPI.B		#_JUMPIN2,KEYBOARD_CHOOSE-VB(a4)
				BEQ.S		EINSPRUNG_2
				AND.B		KEY_CODE_1-VB(a4),D0
				MOVE.B		SWITCH_CODE_1-VB(a4),D1
				BRA.S		CONT_EINSPRUNG
EINSPRUNG_2:	AND.B		KEY_CODE_2-VB(a4),D0
				MOVE.B		SWITCH_CODE_2-VB(a4),D1

CONT_EINSPRUNG: MOVEQ		#0,D3
				MOVE.B		KEYBOARD_TABELLE(PC,D0.w),D3
				BEQ.S		NOT_SET
				BSR 		SET_OB_STATE

NOT_SET:		ADD.B		D1,D1
				ADD.B		D1,D1
				BCC.S		NO_MAUS_LEFT
				MOVEQ		#M1,D3
				BSR 		SET_OB_STATE
NO_MAUS_LEFT:	ADD.B		D1,D1
				BCC.S		NO_MAUS_RIGHT
				MOVEQ		#M2,D3
				BSR 		SET_OB_STATE
NO_MAUS_RIGHT:	ADD.B		D1,D1
				ADD.B		D1,D1
				BCC.S		NO_ALTERNATE
				MOVEQ		#K56,D3
				BSR 		SET_OB_STATE
NO_ALTERNATE:	ADD.B		D1,D1
				BCC.S		NO_CONTROL
				MOVEQ		#K29,D3
				BSR 		SET_OB_STATE
NO_CONTROL: 	ADD.B		D1,D1
				BCC.S		NO_SHIFT_LEFT
				MOVEQ		#K42,D3
				BSR 		SET_OB_STATE
NO_SHIFT_LEFT:	ADD.B		D1,D1
				BCC.S		NO_SHIFT_RIGHT
				MOVEQ		#K54,D3
				BSR 		SET_OB_STATE
NO_SHIFT_RIGHT: BRA 		RTS_REG

*-------------------------------------------------------------------------------

KEYBOARD_TABELLE:		DC.B 0,K1,K2,K3,K4,K5,K6,K7,K8,K9,K10,K11
						DC.B K12,K13,K14,K15,K16,K17,K18,K19,K20,K21
						DC.B K22,K23,K24,K25,K26,K27,K28,K29,K30,K31
						DC.B K32,K33,K34,K35,K36,K37,K38,K39,K40,K41
						DC.B K42,K43,K44,K45,K46,K47,K48,K49,K50,K51
						DC.B K52,K53,K54,0,K56,K57,0,K59,K60,K61,K62
						DC.B K63,K64,K65,K66,K67,K68,0,0,K71,K72
						DC.B 0,K74,K75,0,K77,K78,0,K80,0,K82
						DC.B K83,0,0,0,0,0,0,0,0,0
						DC.B 0,0,0,K96,K97,K98,K99,K100,K101,K102
						DC.B K103,K104,K105,K106,K107,K108,K109,K110
						DC.B K111,K112,K113,K114
						EVEN

*-------------------------------------------------------------------------------

GETBOX_KEYBOARD:MOVEM.L 	#REGISTER,-(SP)
				LEA 		KEYBOARD_TABELLE(PC),A3
				MOVEQ		#0,D3
				MOVEQ		#-1,D4
				MOVEQ		#114,D7
GET_LOOP:		ADDQ.W		#1,D4
				MOVE.B		(A3)+,D3
				DBNE		D7,GET_LOOP
				BSR 		CALCULATE_OBJECT
				BTST		#4,9(A0)
				DBNE		D7,GET_LOOP
				BSR 		GET_OB_STATE
				DBNE		D7,GET_LOOP
				BNE.S		ITS_SET
				MOVEQ		#0,D4

ITS_SET:		CMPI.B		#_JUMPIN1,KEYBOARD_CHOOSE-VB(a4)
				BEQ.S		EINSPRUNG_1
				MOVE.B		D4,KEY_CODE_2-VB(a4)
				BSR.S		SWITCH_TASTEN_2
				MOVE.B		D0,SWITCH_CODE_2-VB(a4)
				BRA 		RTS_REG
EINSPRUNG_1:	MOVE.B		D4,KEY_CODE_1-VB(a4)
				BSR.S		SWITCH_TASTEN_2
				MOVE.B		D0,SWITCH_CODE_1-VB(a4)
				BRA 		RTS_REG

*---------------

SWITCH_TASTEN_2:MOVEQ		#0,D0
				MOVEQ		#M1,D3
				BSR 		GET_OB_STATE
				BEQ.S		NO_MAUS_LEFT2
				BSET		#6,D0
NO_MAUS_LEFT2:	MOVEQ		#M2,D3
				BSR 		GET_OB_STATE
				BEQ.S		NO_MAUS_RIGHT2
				BSET		#5,D0
NO_MAUS_RIGHT2: MOVEQ		#K56,D3
				BSR 		GET_OB_STATE
				BEQ.S		NO_ALTERNATE2
				BSET		#3,D0
NO_ALTERNATE2:	MOVEQ		#K29,D3
				BSR 		GET_OB_STATE
				BEQ.S		NO_CONTROL2
				BSET		#2,D0
NO_CONTROL2:	MOVEQ		#K42,D3
				BSR 		GET_OB_STATE
				BEQ.S		NO_SHIFT_LEFT2
				BSET		#1,D0
NO_SHIFT_LEFT2: MOVEQ		#K54,D3
				BSR 		GET_OB_STATE
				BEQ.S		NO_SHIFT_RIGHT2
				BSET		#0,D0
NO_SHIFT_RIGHT2:RTS

*-------------------------------------------------------------------------------

GET_KEYBOARD:	MOVEM.L 	#REGISTER,-(SP)
				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		RTS_REG
				MOVEA.L 	36(A0),A0
				MOVE.L		(A0),KEYS-VB(a4)
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

PUT_KEYBOARD:	MOVEM.L 	#REGISTER,-(SP)
				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		WO_ISSER_REG
				MOVEA.L 	36(A0),A0
				MOVE.L		KEYS-VB(a4),(A0)
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

WOPEN_5:		BSR 		GET_PARAM
				BSR.S		PUTBOX_PARAM
				BRA 		WINDOW_OPEN

*-------------------------------------------------------------------------------

WBUTTON_5:		MOVE.W		D0,D3
				BSR 		FORM_BUTTON
				CMP.B		#_ABBRUCH8,D0
				BEQ 		CLOSE_WINDOW
				CMP.B		#_OK8,D0
				BEQ.S		OK8
				CMP.B		#_SETZEN8,D0
				BEQ.S		SETZEN8
				RTS

*-------------------------------------------------------------------------------

OK8:			PEA 		CLOSE_WINDOW(PC)
COMMON8:		BSR.S		GETBOX_PARAM
				BRA 		PUT_PARAM

*-------------------------------------------------------------------------------

SETZEN8:		MOVEM.L 	#REGISTER,-(SP)
				BSR.S		COMMON8
				MOVEQ		#_SETZEN8,D3
				BRA 		TERMINATE_SETZEN

*-------------------------------------------------------------------------------

PUTBOX_PARAM:	MOVEM.L 	#REGISTER,-(SP)
				BSR 		CLEAR_BUTTONS

				LEA 		KEY_REPEAT-VB(a4),A0
				MOVEQ		#_KREPEAT,D3
				MOVEQ		#3,D7
PUT_PARAM_LOOP1:MOVE.L		(A0)+,D4
				BSR 		PUT_EDIT
				ADDQ.W		#1,D3
				DBRA		D7,PUT_PARAM_LOOP1
				MOVEQ		#_PARALLEL,D3
				MOVEQ		#2,D7
				ADDQ.W		#4,A0
PUT_PARAM_LOOP2:MOVE.L		(A0)+,D4
				BSR 		PUT_EDIT
				ADDQ.W		#1,D3
				DBRA		D7,PUT_PARAM_LOOP2

				moveq		#_CHEAT,d3
				tst.b		CHEAT_MODE-VB(a4)
				beq.s		.no_cheat
				bsr			SET_OB_STATE
.no_cheat:		MOVEQ		#_INSERT,D3
				TST.B		INSERT_FLAG-VB(a4)
				BNE.S		INS
				MOVEQ		#_OVERWRIT,D3
INS:			BSR 		SET_OB_STATE
				MOVEQ		#_ALL,D3
				TST.B		SYMBOL_FLAG-VB(a4)
				BMI.S		SET_SYMBOL
				MOVEQ		#_TEILS,D3
				TST.B		SYMBOL_FLAG-VB(a4)
				BGT.S		SET_SYMBOL
				MOVEQ		#_NONE,D3
SET_SYMBOL: 	BSR 		SET_OB_STATE

				BRA 		RTS_REG

*-------------------------------------------------------------------------------

GETBOX_PARAM:	MOVEM.L 	#REGISTER,-(SP)
				BSR 		GET_PRIORITY

				LEA 		KEY_REPEAT-VB(a4),A0
				MOVEQ		#_KREPEAT,D3
				MOVEQ		#3,D7
GET_PARAM_LOOP1:BSR 		GET_EDIT
				MOVE.L		D0,(A0)+
				ADDQ.W		#1,D3
				DBRA		D7,GET_PARAM_LOOP1
				MOVEQ		#2,D7
				MOVEQ		#_PARALLEL,D3
				ADDQ.W		#4,A0
GET_PARAM_LOOP2:BSR 		GET_EDIT
				MOVE.L		D0,(A0)+
				ADDQ.W		#1,D3
				DBRA		D7,GET_PARAM_LOOP2

				MOVEQ		#_CHEAT,D3
				BSR 		GET_OB_STATE
				SNE 		CHEAT_MODE-VB(a4)
				MOVEQ		#_INSERT,D3
				BSR 		GET_OB_STATE
				SNE 		INSERT_FLAG-VB(a4)
				MOVEQ		#_ALL,D3
				BSR 		GET_OB_STATE
				SNE 		SYMBOL_FLAG-VB(a4)
				BNE.S		ALL_SYMBOLS
				MOVEQ		#_NONE,D3
				BSR 		GET_OB_STATE
				BNE.S		ALL_SYMBOLS
				MOVE.B		#1,SYMBOL_FLAG-VB(a4)
ALL_SYMBOLS:	BRA 		RTS_REG

*-------------------------------------------------------------------------------

GET_PARAM:		MOVEM.L 	#REGISTER,-(SP)
				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		RTS_REG
				movea.l		-16(a0),a1
				jsr			(a1)
				sne			CHEAT_MODE-VB(a4)
				MOVEA.L 	36(A0),A0
				LEA 		KEY_REPEAT-VB(a4),A1
				MOVEM.L 	62(A0),D0-D7
				MOVEM.L 	D0-D7,(A1)
				MOVE.W		156(A0),INSERT_FLAG-VB(a4)
				MOVE.B		158(A0),SYMBOL_FLAG-VB(a4)
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

PUT_PARAM:		MOVEM.L 	#REGISTER,-(SP)
				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		WO_ISSER_REG
				movea.l		-20(a0),a1
				tst.b		CHEAT_MODE-VB(a4)
				beq.s		.off
				movea.l		-24(a0),a1
.off:			jsr			(a1)
				MOVEA.L 	36(A0),A0
				LEA 		KEY_REPEAT-VB(a4),A1
				MOVEM.L 	(A1),D0-D7
				MOVEM.L 	D0-D7,62(A0)
				MOVE.W		INSERT_FLAG-VB(a4),156(A0)
				MOVE.B		SYMBOL_FLAG-VB(a4),158(A0)
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

WOPEN_6:		BSR 		GET_SCRPARAM
				BSR 		PUTBOX_SCRPARAM
				BRA 		WINDOW_OPEN

*-------------------------------------------------------------------------------

SET_EDIT:		MOVE.W		#_OFFSETX2,WKEY_OBJ(A1)
				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS
				BSR 		SEARCH_PEACEBUG
				BEQ 		RTS
				MOVE.W		#_OFFSETX,WKEY_OBJ(A1)
				RTS

*-------------------------------------------------------------------------------

WBUTTON_6:		MOVE.W		D0,D3
				BSR 		FORM_BUTTON

				CMP.B		#_ST,D0
				BEQ.S		ST
				CMP.B		#_F030,D0
				BEQ.S		F030
				CMP.B		#_TT,D0
				BEQ.S		TT
				CMP.B		#_FONT16,D0
				BEQ			FONT16
				CMP.B		#_FONT8,D0
				BEQ 		FONT8
				CMP.B		#_OK1,D0
				BEQ.S		OK1
				CMP.B		#_SETZEN1,D0
				BEQ.S		SETZEN1
				CMP.B		#_ABBRUCH1,D0
				BEQ 		CLOSE_WINDOW
				RTS

*-------------------------------------------------------------------------------

OK1:			PEA 		CLOSE_WINDOW(PC)
COMMON1:		BSR 		GETBOX_SCRPARAM
				BRA 		PUT_SCRPARAM

*-------------------------------------------------------------------------------

SETZEN1:		MOVEM.L 	#REGISTER,-(SP)
				BSR.S		COMMON1
				BSR 		GET_SCRPARAM
				BSR 		PUTBOX_SCRPARAM
				MOVEQ		#_SETZEN1,D3
				BRA 		TERMINATE_SETZEN_2

*-------------------------------------------------------------------------------

ST:				movem.l		ST_VALUES(PC),d0-d2
				bra.s		SET_VALUES
F030:			movem.l		F030_VALUES(PC),d0-d2
				bra.s		SET_VALUES
TT:				movem.l		TT_VALUES(PC),d0-d2
SET_VALUES:		movem.l		d0-d2,_BILDSCHIRM_LENGTH-VB(a4)
				MOVEQ		#_SLENGTH,D3
				MOVEQ		#2,D7
				LEA 		_BILDSCHIRM_LENGTH-VB(a4),A0
.loop:			MOVEQ		#0,D4
				MOVE.L		(A0)+,D4
				BSR 		PUT_EDIT
				bsr			OBJC_DRAW
				ADDQ.W		#1,D3
				DBRA		D7,.loop
				rts

ST_VALUES:		dc.l		32000,4000,256
F030_VALUES:	dc.l		307200,4800,512
TT_VALUES:		dc.l		153600,19200,512

*-------------------------------------------------------------------------------

FONT16: 		MOVEM.L 	#REGISTER,-(SP)
				LEA 		DRIVE_1-VB(a4),A1
				LEA 		FILE_4-VB(a4),A2
				LEA 		TITEL_4-VB(a4),A3
				MOVE.L		#'.FNT',D3
				BSR 		FSEL_EXINPUT
				TST.W		GINTOUT+2-VB(a4)
				BEQ.S		ENDE_FONT16

				MOVE.L		#4096,D3
				LEA 		FREAD-VB(a4),A2
				LEA 		PATH_1-VB(a4),A3
				LEA 		FILE_4-VB(a4),A5
				LEA 		FONT_16_8-VB(a4),A6
				BSR 		LADEN_SPEICHERN
				BEQ.S		ENDE_FONT16

				LEA 		FONT_ERROR-VB(a4),A3
				BSR 		FORM_ALERT
				BSR 		GET_FONTS

ENDE_FONT16:	MOVEM.L 	(SP)+,#REGISTER
				MOVEQ		#_FONT16,D3
				BSR 		CLEAR_OB_STATE
				BRA 		OBJC_DRAW

*-------------------------------------------------------------------------------

FONT8:			MOVEM.L 	#REGISTER,-(SP)
				LEA 		DRIVE_1-VB(a4),A1
				LEA 		FILE_5-VB(a4),A2
				LEA 		TITEL_5-VB(a4),A3
				MOVE.L		#'.FNT',D3
				BSR 		FSEL_EXINPUT
				TST.W		GINTOUT+2-VB(a4)
				BEQ.S		ENDE_FONT8

				MOVE.L		#2048,D3
				LEA 		FREAD-VB(a4),A2
				LEA 		PATH_1-VB(a4),A3
				LEA 		FILE_5-VB(a4),A5
				LEA 		FONT_8_8-VB(a4),A6
				BSR 		LADEN_SPEICHERN
				BEQ.S		ENDE_FONT8

				LEA 		FONT_ERROR-VB(a4),A3
				BSR 		FORM_ALERT
				BSR 		GET_FONTS

ENDE_FONT8: 	MOVEM.L 	(SP)+,#REGISTER
				MOVEQ		#_FONT8,D3
				BSR 		CLEAR_OB_STATE
				BRA 		OBJC_DRAW

*-------------------------------------------------------------------------------

PUTBOX_SCRPARAM:MOVEM.L 	#REGISTER,-(SP)
				BSR 		CLEAR_BUTTONS

				MOVEQ		#_TITLE,D3
				BSR 		CALCULATE_OBJECT
				BCLR		#7,9(A0)
				MOVEQ		#_BOX,D3
				BSR 		CALCULATE_OBJECT
				BCLR		#7,9(A0)
				MOVEQ		#_OFFSETX,D3
				MOVEQ		#7,D7
EDIT_LOOP_1:	BSR 		CALCULATE_OBJECT
				BSET		#3,9(A0)
				ADDQ.W		#1,D3
				DBRA		D7,EDIT_LOOP_1

				TST.B		PATCH_MODUS-VB(a4)
				BNE.S		HIDE_PART
				BSR 		SEARCH_PEACEBUG
				BNE.S		NORMAL_MODUS

HIDE_PART:		MOVEQ		#_TITLE,D3
				BSR 		CALCULATE_OBJECT
				BSET		#7,9(A0)
				MOVEQ		#_BOX,D3
				BSR 		CALCULATE_OBJECT
				BSET		#7,9(A0)
				MOVEQ		#_OFFSETX,D3
				MOVEQ		#7,D7
EDIT_LOOP_2:	BSR 		CALCULATE_OBJECT
				BCLR		#3,9(A0)
				ADDQ.W		#1,D3
				DBRA		D7,EDIT_LOOP_2

NORMAL_MODUS:	MOVEQ		#_F_8_16,D3
				CMPI.W		#4,FONT_FLAG-VB(a4)
				BEQ.S		FONT_IO
				MOVEQ		#_F_8_8,D3
FONT_IO:		BSR 		SET_OB_STATE

				MOVEQ		#_OFFSETX,D3
				MOVEQ		#7,D7
				LEA 		OFFSET_X-VB(a4),A0
PUT_SCR_LOOP1:	MOVEQ		#0,D4
				MOVE.W		(A0)+,D4
				BSR 		PUT_EDIT
				ADDQ.W		#1,D3
				DBRA		D7,PUT_SCR_LOOP1

				MOVEQ		#_OFFSETX2,D3
				MOVEQ		#4,D7
				LEA 		_OFFSET_X-VB(a4),A0
PUT_SCR_LOOP2:	MOVEQ		#0,D4
				MOVE.W		(A0)+,D4
				BSR 		PUT_EDIT
				ADDQ.W		#1,D3
				DBRA		D7,PUT_SCR_LOOP2

				MOVEQ		#_SLENGTH,D3
				MOVEQ		#2,D7
				LEA 		_BILDSCHIRM_LENGTH-VB(a4),A0
PUT_SCR_LOOP3:	MOVEQ		#0,D4
				MOVE.L		(A0)+,D4
				BSR 		PUT_EDIT
				ADDQ.W		#1,D3
				DBRA		D7,PUT_SCR_LOOP3

				MOVEQ		#_PALETTE,D3
				tst.b		SWITCH_PALETTE-VB(a4)
				beq.s		.no_palette
				BSR			SET_OB_STATE

.no_palette:	MOVEQ		#_REGISTER,D3
				tst.b		SWITCH_REGISTER-VB(a4)
				beq.s		.no_register
				BSR			SET_OB_STATE

.no_register:	BSR 		SET_EDIT
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

GETBOX_SCRPARAM:MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#4,D0
				MOVEQ		#_F_8_16,D3
				BSR 		GET_OB_STATE
				BNE.S		BIG_ONE
				MOVEQ		#3,D0
BIG_ONE:		MOVE.W		D0,FONT_FLAG-VB(a4)

				MOVEQ		#_PALETTE,D3
				BSR 		GET_OB_STATE
				sne			SWITCH_PALETTE-VB(a4)

				MOVEQ		#_REGISTER,D3
				BSR 		GET_OB_STATE
				sne			SWITCH_REGISTER-VB(a4)

				MOVEQ		#_OFFSETX,D3
				MOVEQ		#7,D7
				LEA 		OFFSET_X-VB(a4),A0
GET_SCR_LOOP1:	BSR 		GET_EDIT
				MOVE.W		D0,(A0)+
				ADDQ.W		#1,D3
				DBRA		D7,GET_SCR_LOOP1

				MOVEQ		#_OFFSETX2,D3
				MOVEQ		#4,D7
				LEA 		_OFFSET_X-VB(a4),A0
GET_SCR_LOOP2:	BSR 		GET_EDIT
				MOVE.W		D0,(A0)+
				ADDQ.W		#1,D3
				DBRA		D7,GET_SCR_LOOP2

				MOVEQ		#_SLENGTH,D3
				MOVEQ		#2,D7
				LEA 		_BILDSCHIRM_LENGTH-VB(a4),A0
GET_SCR_LOOP3:	BSR 		GET_EDIT
				MOVE.L		D0,(A0)+
				ADDQ.W		#1,D3
				DBRA		D7,GET_SCR_LOOP3
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

GET_SCRPARAM:	MOVEM.L 	#REGISTER,-(SP)

				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		RTS_REG
				MOVEA.L 	24(A0),A1
				LEA 		40(A1),A1
				LEA 		FONT_FLAG-VB(a4),A2
				MOVEQ		#55,D0
SCRPARAM_LOOP1: MOVE.B		(A1)+,(A2)+
				DBRA		D0,SCRPARAM_LOOP1
				addq.w		#7,a1
				move.b		(a1)+,SWITCH_PALETTE-VB(a4)
				lea			512(a1),a1
				move.b		(a1),SWITCH_REGISTER-VB(a4)
				BRA 		RTS_REG

GET_FONTS:		BSR 		SEARCH_PEACEBUG
				BEQ.S		NO_FONTS
				MOVEA.L 	24(A0),A1
				LEA 		32(A1),A1
				MOVEA.L 	(A1)+,A2
				LEA 		FONT_16_8-VB(a4),A3
				MOVE.W		#1023,D7
COPY_FONT_1:	MOVE.L		(A2)+,(A3)+
				DBRA		D7,COPY_FONT_1
				MOVEA.L 	(A1)+,A2
				LEA 		FONT_8_8-VB(a4),A3
				MOVE.W		#511,D7
COPY_FONT_2:	MOVE.L		(A2)+,(A3)+
				DBRA		D7,COPY_FONT_2
NO_FONTS:		RTS

*-------------------------------------------------------------------------------

PUT_SCRPARAM:	MOVEM.L 	#REGISTER,-(SP)

				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		WO_ISSER_REG
				MOVEA.L 	24(A0),A6
				TST.B		102(A6)
				BNE 		LOCKED_REG
				ST			102(A6)

				MOVEA.L 	(A0),A1					; CLEAR_SCREEN
				PEA 		(A1)
				BSR 		CALL_SUPER
				MOVEA.L 	24(A0),A1
				LEA 		32(A1),A1
				MOVEA.L 	(A1)+,A2
				LEA 		FONT_16_8-VB(a4),A3
				MOVE.W		#1023,D7
COPY_FONT_3:	MOVE.L		(A3)+,(A2)+
				DBRA		D7,COPY_FONT_3
				MOVEA.L 	(A1)+,A2
				LEA 		FONT_8_8-VB(a4),A3
				MOVE.W		#511,D7
COPY_FONT_4:	MOVE.L		(A3)+,(A2)+
				DBRA		D7,COPY_FONT_4
				LEA 		FONT_FLAG-VB(a4),A2
				MOVEQ		#55,D7
SCRPARAM_LOOP2: MOVE.B		(A2)+,(A1)+
				DBRA		D7,SCRPARAM_LOOP2
				addq.w		#7,a1
				move.b		SWITCH_PALETTE-VB(a4),(a1)+
				lea			512(a1),a1
				move.b		SWITCH_REGISTER-VB(a4),(a1)
				MOVEA.L 	16(A0),A1				; NEW_FORMAT
				PEA 		(A1)
				BSR 		CALL_SUPER
				MOVEA.L 	20(A0),A1				; PRINT_SCREEN
				PEA 		(A1)
				BSR 		CALL_SUPER

				SF			102(A6)					; SCREEN_LOCK freigeben
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

WOPEN_7:		BSR 		GET_PRIORITY
				BSR 		PUTBOX_PRIORITY
				BRA 		WINDOW_OPEN

*-------------------------------------------------------------------------------

WBUTTON_7:		MOVE.W		D0,D3
				BSR 		FORM_BUTTON
				CMP.B		#_OK6,D0
				BEQ.S		OK6
				CMP.B		#_SETZEN6,D0
				BEQ.S		SETZEN6
				CMP.B		#_ABBRUCH6,D0
				BEQ 		CLOSE_WINDOW
				CMP.B		#_UP,D0
				BEQ.S		UP
				CMP.B		#_DOWN,D0
				BEQ.S		DOWN
				RTS

*-------------------------------------------------------------------------------

OK6:			PEA 		CLOSE_WINDOW(PC)
COMMON6:		BSR 		GETBOX_PRIORITY
				BRA 		PUT_PRIORITY

*-------------------------------------------------------------------------------

SETZEN6:		MOVEM.L 	#REGISTER,-(SP)
				BSR.S		COMMON6
				MOVEQ		#_SETZEN6,D3
				BRA 		TERMINATE_SETZEN

*-------------------------------------------------------------------------------

UP: 			MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#1,D7
				BRA.S		CONT_PRIORITY
DOWN:			MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#-1,D7
CONT_PRIORITY:	CMP.W		#1,D1
				BEQ.S		ONE_STEP
				MULS		#10,D7
ONE_STEP:		MOVEQ		#_PLUS-1,D3
				MOVEQ		#12,D0
PRIORITY_SEARCH:ADDQ.L		#1,D3
				BSR 		GET_OB_STATE
				DBNE		D0,PRIORITY_SEARCH
				BEQ 		RTS_REG
				MOVE.B		D3,PRIORITY_CHOOSE-VB(a4)
				MOVEQ		#5,D5
				MOVEQ		#10,D6
				BSR 		GET_TEXT
				ADD.W		D7,D0
				MOVE.W		D0,D4
				BSR 		PUT_TEXT
				BSR 		OBJC_DRAW
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

PUTBOX_PRIORITY:MOVEM.L 	#REGISTER,-(SP)
				BSR 		CLEAR_BUTTONS

				MOVEQ		#0,D3
				MOVE.B		PRIORITY_CHOOSE-VB(a4),D3
				BSR 		SET_OB_STATE

				LEA 		PRIORITY-VB(a4),A0
				MOVEQ		#_PLUS,D3
				MOVEQ		#0,D4
				MOVEQ		#5,D5
				MOVEQ		#10,D6
				MOVEQ		#12,D7
PRIORITY_TEXT:	MOVE.W		(A0)+,D4
				BSR 		PUT_TEXT
				ADDQ.W		#1,D3
				DBRA		D7,PRIORITY_TEXT
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

GETBOX_PRIORITY:MOVEM.L 	#REGISTER,-(SP)
				LEA 		PRIORITY-VB(a4),A0
				MOVEQ		#_PLUS,D3
				MOVEQ		#5,D5
				MOVEQ		#10,D6
				MOVEQ		#12,D7
PRIORITY_LOOP1: BSR 		GET_TEXT
				MOVE.W		D0,(A0)+
				ADDQ.W		#1,D3
				DBRA		D7,PRIORITY_LOOP1
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

GET_PRIORITY:	MOVEM.L 	#REGISTER,-(SP)
				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		RTS_REG
				MOVEA.L 	36(A0),A0
				LEA 		PRIORITY-VB(a4),A1
				MOVE.W		26(A0),(A1)+
				MOVEM.L 	28(A0),D1-D6
				MOVEM.L 	D1-D6,(A1)
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

PUT_PRIORITY:	MOVEM.L 	#REGISTER,-(SP)
				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		WO_ISSER_REG
				MOVEA.L 	36(A0),A0
				LEA 		PRIORITY-VB(a4),A1
				MOVE.W		(A1)+,26(A0)
				MOVEM.L 	(A1),D1-D6
				MOVEM.L 	D1-D6,28(A0)
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

WOPEN_8:		TST.B		PATCH_MODUS-VB(a4)
				BEQ.S		PBUG_SUCHEN
				LEA 		PATCHMODUS_MESSAGE-VB(a4),A3
				BRA 		FORM_ALERT
PBUG_SUCHEN:	BSR 		SEARCH_PEACEBUG
				BEQ 		WO_ISSER
				BSR 		PUTBOX_USER
				BRA 		WINDOW_OPEN

*-------------------------------------------------------------------------------

WBUTTON_8:		MOVE.W		D0,D3
				BSR 		FORM_BUTTON

				CMP.B		#_OK7,D0
				BEQ 		CLOSE_WINDOW
				TST.B		PATCH_MODUS-VB(a4)
				BNE.S		DONT_DO_THAT
				BSR 		SEARCH_PEACEBUG
				BNE.S		STILL_THERE
				BSR 		WO_ISSER
DONT_DO_THAT:	BSR 		CLEAR_OB_STATE
				BRA 		OBJC_DRAW

STILL_THERE:	CMP.B		#_ENTER,D0
				BEQ.S		ENTER
				CMP.B		#_QUIT,D0
				BEQ.S		QUIT
				CMP.B		#_SWITCH1,D0
				BEQ.S		SWITCH1
				CMP.B		#_SWITCH2,D0
				BEQ.S		SWITCH2
				CMP.B		#_RESET,D0
				BEQ.S		RESET
				CMP.B		#_TRACE,D0
				BEQ.S		TRACE
				RTS

*-------------------------------------------------------------------------------

TRACE:			MOVEM.L 	#REGISTER,-(SP)
				LEA 		FILE_6-VB(a4),A2
				LEA 		TITEL_6-VB(a4),A3
				LEA 		40(A0),A0
				LEA 		TRACE_BASEPAGE-VB(a4),A6
				BRA.S		ROUTINE_LADEN

*-------------------------------------------------------------------------------

ENTER:			MOVEM.L 	#REGISTER,-(SP)
				LEA 		FILE_7-VB(a4),A2
				LEA 		TITEL_7-VB(a4),A3
				LEA 		44(A0),A0
				LEA 		ENTER_BASEPAGE-VB(a4),A6
				BRA.S		ROUTINE_LADEN

*-------------------------------------------------------------------------------

QUIT:			MOVEM.L 	#REGISTER,-(SP)
				LEA 		FILE_8-VB(a4),A2
				LEA 		TITEL_8-VB(a4),A3
				LEA 		48(A0),A0
				LEA 		QUIT_BASEPAGE-VB(a4),A6
				BRA.S		ROUTINE_LADEN

*-------------------------------------------------------------------------------

SWITCH1:		MOVEM.L 	#REGISTER,-(SP)
				LEA 		FILE_9-VB(a4),A2
				LEA 		TITEL_9-VB(a4),A3
				LEA 		52(A0),A0
				LEA 		SWITCH1_BASEPAGE-VB(a4),A6
				BRA.S		ROUTINE_LADEN

*-------------------------------------------------------------------------------

SWITCH2:		MOVEM.L 	#REGISTER,-(SP)
				LEA 		FILE_10-VB(a4),A2
				LEA 		TITEL_10-VB(a4),A3
				LEA 		56(A0),A0
				LEA 		SWITCH2_BASEPAGE-VB(a4),A6
				BRA.S		ROUTINE_LADEN

*-------------------------------------------------------------------------------

RESET:			MOVEM.L 	#REGISTER,-(SP)
				LEA 		FILE_11-VB(a4),A2
				LEA 		TITEL_11-VB(a4),A3
				LEA 		60(A0),A0
				LEA 		RESET_BASEPAGE-VB(a4),A6
*				 BRA.S		 ROUTINE_LADEN

*-------------------------------------------------------------------------------

* ---> A2 = Filename, A0 = hier einh„ngen, A3 = Titel, A6 = Basepage
ROUTINE_LADEN:	MOVE.L		A0,D5
				LEA 		DRIVE_2-VB(a4),A1
				MOVE.L		#'.USR',D3
				BSR 		FSEL_EXINPUT
				MOVE.W		GINTOUT+2-VB(a4),D0
				BEQ 		ROUTINE_ENDE

				BSR 		MAUS_BUSY

				MOVEQ		#0,D0
				MOVE.B		(A1),D0
				SUB.B		#65,D0
				MOVE.W		D0,-(SP)
				MOVE.W		#14,-(SP)			  ;DSETDRV
				TRAP		#1
				ADDQ.W		#4,SP

				PEA 		PATH_2-VB(a4)
				MOVE.W		#59,-(SP)			  ;DSETPATH 59
				TRAP		#1
				ADDQ.W		#6,SP
				TST.W		D0
				BMI.S		ROUTINE_ERROR

				PEA 		0.w
				PEA 		0.w
				PEA 		(A2)
				MOVE.L		#$004B0003,-(SP)	  ; PEXEC 3
				TRAP		#1
				LEA 		16(SP),SP

				BSR 		MAUS_PFEIL

				TST.L		D0
				BMI.S		ROUTINE_ERROR
				SUBQ.B		#1,STAY_RESIDENT-VB(a4)

				MOVE.L		D0,-(SP)
				MOVEA.L 	D0,A0
				MOVE.L		12(A0),D0			  ; L„nge TEXT-Segment
				ADD.L		20(A0),D0			  ; L„nge DATA-Segment
				ADD.L		28(A0),D0			  ; L„nge BSS-Segment
				ADD.L		#256,D0 			  ; L„nge Basepage
				MOVE.L		D0,-(SP)
				MOVE.L		A0,-(SP)
				MOVE.L		#$004A0000,-(SP)
				TRAP		#1					  ; MSHRINK
				LEA 		12(SP),SP

				MOVEA.L 	(SP)+,A0
				MOVEA.L 	8(A0),A0			  ; TEXT-Segment
				ADDQ.W		#6,A0
				CMPI.L		#'XBRA',(A0)+
				BNE.S		ROUTINE_ERROR

				MOVE.L		D0,(A6)+			  ; Basepage
				MOVE.L		(A0)+,(A6)+ 		  ; XBRA-Kennung
				MOVEA.L 	D5,A1
				MOVE.L		(A1),(A0)+			  ; alte Routine sichern
				MOVE.L		A0,(A1) 			  ; und einh„ngen

				SUBQ.B		#1,STAY_RESIDENT-VB(a4)
				BRA.S		ROUTINE_ENDE

ROUTINE_ERROR:	LEA 		ROUTINEN_ERROR-VB(a4),A3
				BSR 		FORM_ALERT
ROUTINE_ENDE:	MOVEM.L 	(SP),#REGISTER
				MOVE.W		D0,D3
				BSR.S		PUTBOX_USER
				MOVEM.L 	(SP)+,#REGISTER
				BSR 		CLEAR_OB_STATE
				MOVEQ		#0,D3
				BRA 		OBJC_DRAW

*-------------------------------------------------------------------------------

PUTBOX_USER:	MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#_OK7,D3
				BSR 		CLEAR_OB_STATE
				BSR 		SEARCH_PEACEBUG
				BEQ 		RTS_REG
				LEA 		40(A0),A1
				MOVEQ		#_TRACE_X,D3
				MOVEQ		#5,D7
PUTUSER_LOOP:	BSR 		CALCULATE_OBJECT
				MOVEA.L 	12(A0),A0
				MOVEA.L 	(A0),A0
				MOVEA.L 	(A1)+,A2
				MOVE.L		#'----',D6
				CMPI.L		#'XBRA',-12(A2)
				BNE.S		KEIN_XBRA
				MOVE.L		-8(A2),D6
				MOVE.B		D6,4(A0)
				LSR.W		#8,D6
				MOVE.B		D6,3(A0)
				SWAP		D6
				MOVE.B		D6,2(A0)
				LSR.W		#8,D6
				MOVE.B		D6,1(A0)
KEIN_XBRA:		ADDQ.W		#1,D3
				DBRA		D7,PUTUSER_LOOP
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

WOPEN_9:		BSR 		GET_SPEED
				BSR 		PUTBOX_SPEED
				BRA 		WINDOW_OPEN

*-------------------------------------------------------------------------------

WBUTTON_9:		MOVE.W		D0,D3
				BSR 		FORM_BUTTON

				CMP.B		#_OK5,D0
				BEQ.S		OK5
				CMP.B		#_SETZEN5,D0
				BEQ.S		SETZEN5
				CMP.B		#_ABBRUCH5,D0
				BEQ 		CLOSE_WINDOW

				MOVEM.L 	#REGISTER,-(SP)
				MOVE.W		D0,D3
				MOVEQ		#1,D7
				ADD.W		#_S1-_UP1,D3
				CMP.W		#_DOWN6,D0
				BHI.S		AUF
				MOVEQ		#-1,D7
				ADD.W		#_UP1-_DOWN1,D3
AUF:			CMP.W		#1,D1
				BEQ.S		EINFACH_KLICK
				MULU		#10,D7
EINFACH_KLICK:	MOVEQ		#3,D5
				MOVEQ		#2,D6
				BSR 		GET_TEXT
				BSR 		CALCULATE_OBJECT
				MOVEA.L 	12(A0),A0
				MOVEA.L 	(A0),A0
				CMPI.B		#'-',(A0)
				BNE.S		PLUS_SPEED_1
				NEG.W		D0
PLUS_SPEED_1:	ADD.W		D7,D0
				CMP.W		#999,D0
				BLE.S		ZAHL_OK_1
				MOVE.W		#999,D0
ZAHL_OK_1:		CMP.W		#-999,D0
				BGE.S		ZAHL_OK_2
				MOVE.W		#-999,D0
ZAHL_OK_2:		MOVE.B		#'+',(A0)
				MOVE.W		D0,D4
				BPL.S		PLUS_SPEED_2
				MOVE.B		#'-',(A0)+
				NEG.W		D4
PLUS_SPEED_2:	BSR 		PUT_TEXT
				BSR 		OBJC_DRAW
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

OK5:			PEA 		CLOSE_WINDOW(PC)
COMMON5:		BSR.S		GETBOX_SPEED
				BRA 		PUT_SPEED

*-------------------------------------------------------------------------------

SETZEN5:		MOVEM.L 	#REGISTER,-(SP)
				BSR.S		COMMON5
				MOVEQ		#_SETZEN5,D3
				BRA 		TERMINATE_SETZEN

*-------------------------------------------------------------------------------

PUTBOX_SPEED:	MOVEM.L 	#REGISTER,-(SP)
				BSR 		CLEAR_BUTTONS

				LEA 		MAUS_PARAMETER+2*6(PC),A1
				MOVEQ		#_S1,D3
				MOVEQ		#5,D7
PUT_LOOP:		BSR 		CALCULATE_OBJECT
				MOVEA.L 	12(A0),A3
				MOVEA.L 	(A3),A3
				MOVE.B		#'+',(A3)
				MOVEQ		#0,D4
				MOVE.W		-(A1),D4
				BPL.S		PLUS_SPEED_3
				MOVE.B		#'-',(A3)
				NEG.W		D4
PLUS_SPEED_3:	MOVEQ		#3,D5
				MOVEQ		#2,D6
				BSR 		PUT_TEXT
				ADDQ.W		#1,D3
				DBRA		D7,PUT_LOOP
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

GETBOX_SPEED:	MOVEM.L 	#REGISTER,-(SP)
				LEA 		MAUS_PARAMETER+12-VB(a4),A1
				MOVEQ		#_S1,D3
				MOVEQ		#3,D5
				MOVEQ		#2,D6
				MOVEQ		#5,D7
GET_SPEED_LOOP: BSR 		GET_TEXT
				BSR 		CALCULATE_OBJECT
				MOVEA.L 	12(A0),A0
				MOVEA.L 	(A0),A0
				CMPI.B		#'-',(A0)
				BNE.S		PLUS_SPEED_4
				NEG.W		D0
PLUS_SPEED_4:	MOVE.W		D0,-(A1)
				ADDQ.W		#1,D3
				DBRA		D7,GET_SPEED_LOOP
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

GET_SPEED:		MOVEM.L 	#REGISTER,-(SP)
				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		RTS_REG
				MOVEA.L 	36(A0),A0
				LEA 		12(A0),A0
				LEA 		MAUS_PARAMETER-VB(a4),A1
				MOVE.L		(A0)+,(A1)+
				MOVE.L		(A0)+,(A1)+
				MOVE.L		(A0)+,(A1)+
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

PUT_SPEED:		MOVEM.L 	#REGISTER,-(SP)
				TST.B		PATCH_MODUS-VB(a4)
				BNE 		RTS_REG
				BSR 		SEARCH_PEACEBUG
				BEQ 		WO_ISSER_REG
				MOVEA.L 	36(A0),A0
				LEA 		12(A0),A0
				LEA 		MAUS_PARAMETER-VB(a4),A1
				MOVE.L		(A1)+,(A0)+
				MOVE.L		(A1)+,(A0)+
				MOVE.L		(A1)+,(A0)+
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

PARAMETERLADEN: MOVEM.L 	#REGISTER,-(SP)
				LEA 		DRIVE_0-VB(a4),A1
				LEA 		FILE_2-VB(a4),A2
				LEA 		TITEL_2-VB(a4),A3
				MOVE.L		#'.ACC',D3
				TST.B		ACC_FLAG-VB(a4)
				BNE.S		ITS_ACC_1
				MOVE.L		#'.PRG',D3
ITS_ACC_1:		BSR 		FSEL_EXINPUT
				TST.W		GINTOUT+2-VB(a4)
				BEQ.S		NICHT_LADEN

				MOVE.L		#PARAMETER_ENDE-PARAMETER_ANFANG,D3
				LEA 		FREAD-VB(a4),A2
				LEA 		PATH_0-VB(a4),A3
				LEA 		FILE_2-VB(a4),A5
				LEA 		PARAMETER_ANFANG-VB(a4),A6
				ST			CHECK_KENNUNG-VB(a4)
				BSR 		LADEN_SPEICHERN
				SF			CHECK_KENNUNG-VB(a4)
				BEQ.S		READ_IO

				LEA 		FREAD(PC),A6
				BSR 		PBUG_READ_WRITE
				BEQ.S		READ_IO

				LEA 		LADEN_ERROR-VB(a4),A3
				TST.B		WRONG_KENNUNG_1-VB(a4)
				BEQ.S		MESSAGE_LOAD
				LEA 		WRONG_FILE_LADEN-VB(a4),A3
				BRA.S		MESSAGE_LOAD

READ_IO:		LEA 		LADEN_MESSAGE-VB(a4),A3
MESSAGE_LOAD:	BSR 		FORM_ALERT
NICHT_LADEN:	BRA 		RTS_REG

*-------------------------------------------------------------------------------

PARAMETERSPEICHERN:
				MOVEM.L 	#REGISTER,-(SP)
				LEA 		DRIVE_0-VB(a4),A1
				LEA 		FILE_2-VB(a4),A2
				LEA 		TITEL_3-VB(a4),A3
				MOVE.L		#'.ACC',D3
				TST.B		ACC_FLAG-VB(a4)
				BNE.S		ITS_ACC_2
				MOVE.L		#'.PRG',D3
ITS_ACC_2:		BSR 		FSEL_EXINPUT
				TST.W		GINTOUT+2-VB(a4)
				BEQ.S		NICHT_SPEICHERN

				MOVE.L		#PARAMETER_ENDE-PARAMETER_ANFANG,D3

				LEA 		FWRITE-VB(a4),A2
				LEA 		PATH_0-VB(a4),A3
				LEA 		FILE_2-VB(a4),A5
				LEA 		PARAMETER_ANFANG-VB(a4),A6
				ST			CHECK_KENNUNG-VB(a4)
				BSR 		LADEN_SPEICHERN
				SF			CHECK_KENNUNG-VB(a4)
				BEQ.S		WRITE_IO

				LEA 		FWRITE(PC),A6
				BSR 		PBUG_READ_WRITE
				BEQ.S		WRITE_IO

				LEA 		SPEICHERN_ERROR-VB(a4),A3
				TST.B		WRONG_KENNUNG_1-VB(a4)
				BEQ.S		MESSAGE_SAVE
				LEA 		WRONG_FILE_SPEICHERN-VB(a4),A3
				BRA.S		MESSAGE_SAVE

WRITE_IO:		LEA 		SAVE_MESSAGE-VB(a4),A3
MESSAGE_SAVE:	BSR 		FORM_ALERT
NICHT_SPEICHERN:BRA 		RTS_REG

*-------------------------------------------------------------------------------

WOPEN_10:		BSR.S		PUTBOX_KONFIG
				BRA 		WINDOW_OPEN

*-------------------------------------------------------------------------------

WBUTTON_10: 	MOVE.W		D0,D3
				BSR 		FORM_BUTTON
				CMP.B		#_OK9,D0
				BEQ.S		OK9
				CMP.B		#_SETZEN9,D0
				BEQ.S		SETZEN9
				CMP.B		#_ABBRUCH9,D0
				BEQ 		CLOSE_WINDOW
				RTS

*-------------------------------------------------------------------------------

OK9:			PEA 		CLOSE_WINDOW(PC)
COMMON9:		TST.B		PATCH_MODUS-VB(a4)
				BEQ.S		EXEC
				BRA.S		GETBOX_KONFIG

*-------------------------------------------------------------------------------

SETZEN9:		MOVEM.L 	#REGISTER,-(SP)
				BSR.S		COMMON9
				MOVEQ		#_SETZEN9,D3
				BRA 		TERMINATE_SETZEN

*-------------------------------------------------------------------------------

EXEC:			MOVEM.L 	#REGISTER,-(SP)
				BSR.S		GETBOX_KONFIG
				BSR 		SEARCH_PEACEBUG
				BEQ.S		KEIN_BUG
				BSR 		CONFIG
				MOVEM.L 	(SP)+,#REGISTER
				RTS
KEIN_BUG:		BSR 		WO_ISSER
				MOVEM.L 	(SP)+,#REGISTER
				RTS

*-------------------------------------------------------------------------------

PUTBOX_KONFIG:	MOVEM.L 	#REGISTER,-(SP)
				BSR 		CLEAR_BUTTONS
				MOVEQ		#_SET1,D3
				MOVEQ		#6,D7
				LEA 		CACHE_FLAG-VB(a4),A0
PUTBOX_LOOP:	TST.B		(A0)+
				BEQ.S		ITS_ZERO
				BSR 		SET_OB_STATE
ITS_ZERO:		ADDQ.W		#1,D3
				DBRA		D7,PUTBOX_LOOP
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

GETBOX_KONFIG:	MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#_SET1,D3
				MOVEQ		#6,D7
				LEA 		CACHE_FLAG-VB(a4),A0
GETBOX_LOOP:	BSR 		GET_OB_STATE
				SNE 		(A0)+
				ADDQ.W		#1,D3
				DBRA		D7,GETBOX_LOOP
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

CHANGE_MODUS:	TST.B		PATCH_MODUS-VB(a4)
				BNE.S		SWITCH_TO_FIRST

				ADDQ.B		#1,PEACEBUG_NUMBER-VB(a4)
SWITCH: 		CMPI.B		#9,PEACEBUG_NUMBER-VB(a4)
				BHI.S		SWITCH_TO_PATCH
				BSR 		SEARCH_PEACEBUG
				SEQ 		PATCH_MODUS-VB(a4)
				BNE.S		SWITCH_PEACEBUG
SWITCH_TO_PATCH:ST			PATCH_MODUS-VB(a4)
				CLR.B		PEACEBUG_NUMBER-VB(a4)
				BRA.S		SWITCH_PEACEBUG

SWITCH_TO_FIRST:CLR.B		PEACEBUG_NUMBER-VB(a4)
				BSR 		SEARCH_PEACEBUG
				SEQ 		PATCH_MODUS-VB(a4)
				BNE.S		SWITCH_PEACEBUG
				BSR 		WO_ISSER

SWITCH_PEACEBUG:BSR 		SET_MODUS
				MOVEQ		#CONF,D3
				BSR 		OBJC_DRAW
				MOVEQ		#PATCH,D3
				BRA 		OBJC_DRAW

******************	D I V E R S E	R O U T I N E N ****************************

* ---> D3.l = L„nge
* ---> A2.l = FREAD oder FWRITE
* ---> A3.l = Pfad
* ---> A5.l = Dateiname
* ---> A6.l = Adresse zum Laden/Speichern
* ---> Pfad.l, Dateiname.l, speichern ab .l, L„nge.l
* <--- flag.eq = alles io, flag.ne = Fehler aufgetreten
* setzt WRONG_KENNUNG_1 (wenn CHECK_KENNUNG=-1)
LADEN_SPEICHERN:MOVEM.L 	#REGISTER,-(SP)
				BSR 		MAUS_BUSY

				MOVEQ		#2,D4
				BSR 		OPEN_DATEI
				BMI.S		FILE_ERROR

				TST.B		CHECK_KENNUNG-VB(a4)
				BEQ.S		NO_KENNUNG

				MOVEM.L 	#REGISTER,-(SP) 	   ; Kennung prfen
				ST			WRONG_KENNUNG_1-VB(a4)
				MOVE.L		#KENNUNG_2-PROGRAMM_ANFANG+28,D3
				BSR 		FSEEK
				BNE.S		KENNUNG_FAIL
				MOVEQ		#8,D3
				LEA 		KENNUNG_1-VB(a4),A3
				BSR 		FREAD
				BNE.S		KENNUNG_FAIL
				MOVE.L		KENNUNG_1-VB(a4),D3
				CMP.L		KENNUNG_2-VB(a4),D3
				BNE.S		KENNUNG_FAIL
				MOVE.L		KENNUNG_1+4-VB(a4),D3
				CMP.L		KENNUNG_2+4-VB(a4),D3
				BNE.S		KENNUNG_FAIL
				SF			WRONG_KENNUNG_1-VB(a4)
KENNUNG_FAIL:	MOVEM.L 	(SP)+,#REGISTER
				TST.B		WRONG_KENNUNG_1-VB(a4)
				BNE.S		FILE_ERROR

NO_KENNUNG: 	MOVEA.L 	A6,A3
				JSR 		(A2)
				BNE.S		FILE_ERROR
				BSR 		FCLOSE
				BSR 		MAUS_PFEIL
				MOVEM.L 	(SP)+,#REGISTER
				SF			-(SP)
				TST.B		(SP)+
				RTS

FILE_ERROR: 	BSR 		FCLOSE
				BSR 		MAUS_PFEIL
				MOVEM.L 	(SP)+,#REGISTER
				ST			-(SP)
				TST.B		(SP)+
				RTS

*-------------------------------------------------------------------------------

* ---> A6.l = FWRITE oder FREAD
* <--- flag.eq = alles io, flag.ne = Fehler aufgetreten
* setzt WRONG_KENNUNG_2
PBUG_READ_WRITE:MOVEM.L 	#REGISTER,-(SP)
				BSR 		MAUS_BUSY
				LEA 		PATH_0-VB(a4),A3
				LEA 		FILE_2-VB(a4),A5
				MOVEQ		#2,D4
				BSR 		OPEN_DATEI			  ; Datei ”ffnen
				BMI.S		RW_FAIL

				MOVEQ		#30,D3
				BSR 		FSEEK				  ; Fseek 30
				BNE.S		RW_FAIL

				MOVEQ		#24,D3
				LEA 		BUFFER-VB(a4),A3
				BSR 		FREAD				  ; Offsets lesen
				BNE.S		RW_FAIL

				CMPI.L		#'PBUG',BUFFER-VB(a4)	 ; Kennung prfen
				SNE 		WRONG_KENNUNG_2-VB(a4)
				BNE.S		RW_FAIL

				LEA 		OFFSET_TABELLE(PC),A0
				MOVE.W		(A0)+,D7
RW_LOOP:		LEA 		BUFFER-VB(a4),A1
				ADDA.W		(A0)+,A1
				MOVE.W		(A0)+,D3			  ; Offset in der Struktur
				ext.l		d3
				ADD.L		(A1),D3 			  ; + Offset der Struktur
				BSR 		FSEEK
				BNE.S		RW_FAIL
				MOVEQ		#0,D3
				MOVE.W		(A0)+,D3			  ; L„nge des Bereichs
				LEA 		OFFSET_TABELLE(PC),A3
				ADDA.W		(A0)+,A3			  ; Anfang des Bereichs
				JSR 		(A6)				  ; FREAD oder FWRITE
				BNE.S		RW_FAIL
				DBRA		D7,RW_LOOP

				BSR 		FCLOSE
				BSR 		MAUS_PFEIL
				MOVEM.L 	(SP)+,#REGISTER
				SF			-(SP)
				TST.B		(SP)+
				RTS

RW_FAIL:		BSR 		FCLOSE
				BSR 		MAUS_PFEIL
				MOVEM.L 	(SP)+,#REGISTER
				ST			-(SP)
				TST.B		(SP)+
				RTS

*-------------------------------------------------------------------------------

* Anzahl Strukturen-1
OFFSET_TABELLE: 		DC.W 13
* Offset der Struktur (Debuggerheader)
* Offset in der Struktur (Debuggerdata)
* L„nge des Bereichs
* Anfang des Bereichs als Offset zum Tabellenanfang
						DC.W 4,58,38,_BILDSCHIRM_LENGTH-OFFSET_TABELLE
						DC.W 4,103,1,SWITCH_PALETTE-OFFSET_TABELLE
						DC.W 4,616,1,SWITCH_REGISTER-OFFSET_TABELLE
						DC.W 8,0,4,KEYS-OFFSET_TABELLE
						DC.W 8,12,12,MAUS_PARAMETER-OFFSET_TABELLE
						DC.W 8,26,26,PRIORITY-OFFSET_TABELLE
						DC.W 8,62,32,KEY_REPEAT-OFFSET_TABELLE
						DC.W 8,126,4,HISTORY-OFFSET_TABELLE
						DC.W 8,148,2,ADD1-OFFSET_TABELLE
						DC.W 8,154,2,ADD2-OFFSET_TABELLE
						DC.W 8,156,2,INSERT_FLAG-OFFSET_TABELLE
						DC.W 12,-1,2*48+1,FLAGS-OFFSET_TABELLE-1
						DC.W 16,0,4096,FONT_16_8-OFFSET_TABELLE
						DC.W 20,0,2048,FONT_8_8-OFFSET_TABELLE

*-------------------------------------------------------------------------------

* ---> D4.w = File_modus
* ---> A3.l = Pfad
* ---> A5.l = Dateiname
* <--- flag.eq = alles io, flag.ne = Fehler aufgetreten
OPEN_DATEI: 	MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#0,D0
				MOVE.B		-2(A3),D0
				SUB.B		#65,D0
				MOVE.W		D0,-(SP)
				MOVE.W		#14,-(SP)			  ;DSETDRV
				TRAP		#1
				ADDQ.W		#4,SP

				MOVEA.L 	A3,A0
				BSR 		PUT_BACKSLASH
				PEA 		(A3)
				MOVE.W		#59,-(SP)			  ;DSETPATH 59
				TRAP		#1
				ADDQ.W		#6,SP
				TST.W		D0
				BMI.S		OPEN_ERROR

				MOVE.W		D4,-(SP)
				PEA 		(A5)
				MOVE.W		#61,-(SP)			  ;FOPEN 61
				TRAP		#1
				ADDQ.W		#8,SP
				TST.W		D0
				BMI.S		OPEN_ERROR

				MOVE.W		D0,DISK_HANDLE-VB(a4)
				MOVEM.L 	(SP)+,#REGISTER
				SF			-(SP)
				TST.B		(SP)+
				RTS
OPEN_ERROR: 	MOVEM.L 	(SP)+,#REGISTER
				ST			-(SP)
				TST.B		(SP)+
				RTS

*-------------------------------------------------------------------------------

* ---> D3.l = Anzahl Bytes vom Dateianfang
* <--- D0.w = Error
FSEEK:			MOVEM.L 	D1-A6,-(SP)
				CLR.W		-(SP)
				MOVE.W		DISK_HANDLE-VB(a4),-(SP)
				MOVE.L		D3,-(SP)
				MOVE.W		#66,-(SP)
				TRAP		#1
				LEA 		10(SP),SP
				MOVEM.L 	(SP)+,D1-A6
				CMP.L		D3,D0
				RTS

*-------------------------------------------------------------------------------

* ---> D3.l = Anzahl Bytes, A3.l = Bufferadresse
* <--- D0.w = Error
FWRITE: 		MOVEM.L 	D1-A6,-(SP)
				PEA 		(A3)
				MOVE.L		D3,-(SP)
				MOVE.W		DISK_HANDLE-VB(a4),-(SP)
				MOVE.W		#64,-(SP)
				TRAP		#1
				LEA 		12(SP),SP
				MOVEM.L 	(SP)+,D1-A6
				CMP.L		D0,D3
				RTS

*-------------------------------------------------------------------------------

* ---> D3.l = Anzahl Bytes, A3.l = Bufferadresse
* <--- D0.w = Error
FREAD:			MOVEM.L 	D1-A6,-(SP)
				PEA 		(A3)
				MOVE.L		D3,-(SP)
				MOVE.W		DISK_HANDLE-VB(a4),-(SP)
				MOVE.W		#63,-(SP)
				TRAP		#1
				LEA 		12(SP),SP
				MOVEM.L 	(SP)+,D1-A6
				CMP.L		D0,D3
				RTS

*-------------------------------------------------------------------------------

FCLOSE: 		MOVEM.L 	D1-A6,-(SP)
				MOVE.W		DISK_HANDLE-VB(a4),-(SP)
				MOVE.W		#62,-(SP)			  ;FCLOSE 62
				TRAP		#1
				ADDQ.W		#4,SP
				MOVEM.L 	(SP)+,D1-A6
				TST.W		D0
				RTS

*-------------------------------------------------------------------------------

PUT_STRING: 	MOVEM.L 	#REGISTER,-(SP)
				BSR 		CALCULATE_OBJECT
				MOVEA.L 	12(A0),A3
				ADDA.W		D6,A3
				MOVE.W		D5,D0
				BRA.S		EINSTIEG

*-------------------------------------------------------------------------------

PUT_TEXT:		MOVEM.L 	#REGISTER,-(SP)
				BSR 		CALCULATE_OBJECT
				MOVEA.L 	12(A0),A3
				MOVEA.L 	(A3),A3
				ADDA.W		D6,A3
				MOVE.W		D5,D0
				BRA.S		EINSTIEG

*-------------------------------------------------------------------------------

PUT_EDIT:		MOVEM.L 	#REGISTER,-(SP)
				BSR 		CALCULATE_OBJECT
				MOVEA.L 	12(A0),A3
				MOVE.W		24(A3),D0
				SUBQ.W		#1,D0
				MOVEA.L 	(A3),A3

EINSTIEG:		ADDA.W		D0,A3
				MOVE.L		D4,D3

				TST.L		D3
				BNE.S		ZAHL_EINSTIEG
				MOVE.B		#48,-(A3)
				SUBQ.W		#1,D0
				BRA.S		ZAHL_EINSTIEG
ZAHL_SCHLEIFE_1:
				MOVEQ		#0,D1				  ; Rest auf Null setzen
				MOVEQ		#31,D2				  ; 32 Bit Division
DIVISION:		ADD.L		D3,D3				  ; Operand und Rest
				ADDX.L		D1,D1
				CMP.L		#10,D1				  ; Rest > 10?
				DBCC		D2,DIVISION 		  ; Wenn ja, dann springen
				BLO.S		DIVISION_ENDE
				SUB.L		#10,D1				  ; Rest = Rest - Dividend
				ADDQ.L		#1,D3				  ; Ergebnis 1 erh”hen
				DBRA		D2,DIVISION
DIVISION_ENDE:	MOVE.L		D1,D2
				ADD.L		D3,D2
				BEQ.S		ZAHL_SCHLEIFE_2
				ADD.B		#48,D1
				MOVE.B		D1,-(A3)
ZAHL_EINSTIEG:	DBRA		D0,ZAHL_SCHLEIFE_1
				BRA 		RTS_REG
ZAHL_SCHLEIFE_2:MOVE.B		#32,-(A3)
				DBRA		D0,ZAHL_SCHLEIFE_1
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

* <--- D0.l
GET_TEXT:		MOVEM.L 	D1/D5/A0/A3,-(SP)
				BSR 		CALCULATE_OBJECT
				MOVEA.L 	12(A0),A3
				MOVEA.L 	(A3),A3
				ADDA.W		D6,A3
				MOVEQ		#0,D0
				BRA.S		STRING_EINSTIEG
STRING_LOOP:	SUB.B		#16,D1
				MULU		#10,D0
				ADD.W		D1,D0
STRING_EINSTIEG:MOVEQ		#0,D1
				MOVE.B		(A3)+,D1
				SUB.B		#32,D1
				DBNE		D5,STRING_EINSTIEG
				BEQ.S		ENDE
				DBRA		D5,STRING_LOOP
ENDE:			MOVEM.L 	(SP)+,D1/D5/A0/A3
				RTS

*-------------------------------------------------------------------------------

GET_EDIT:		MOVEM.L 	D1/A0/A3,-(SP)
				BSR.S		CALCULATE_OBJECT
				MOVEA.L 	12(A0),A3
				MOVEA.L 	(A3),A3
				MOVEQ		#0,D0
				BRA.S		TEXT_EINSTIEG
TEXT_LOOP:		MULU		#10,D0
				ADD.L		D1,D0
TEXT_EINSTIEG:	MOVEQ		#0,D1
				MOVE.B		(A3)+,D1
				SUB.B		#32,D1
				BEQ.S		TEXT_EINSTIEG
				SUB.B		#16,D1
				BGE.S		TEXT_LOOP
				MOVEM.L 	(SP)+,D1/A0/A3
				RTS

*-------------------------------------------------------------------------------

* <--- flag.eq = nicht gesetzt, flag.ne = gesetzt
GET_OB_STATE:	MOVE.L		A0,-(SP)
				BSR.S		CALCULATE_OBJECT
				BTST		#0,11(A0)
				BNE.S		SET
				MOVEA.L 	(SP)+,A0
				SF			-(SP)
				TST.B		(SP)+
				RTS
SET:			MOVEA.L 	(SP)+,A0
				ST			-(SP)
				TST.B		(SP)+
				RTS

*-------------------------------------------------------------------------------

SET_OB_STATE:	MOVE.L		A0,-(SP)
				BSR.S		CALCULATE_OBJECT
				ORI.W		#1,10(A0)
				MOVEA.L 	(SP)+,A0
				RTS

*-------------------------------------------------------------------------------

CLEAR_OB_STATE: MOVE.L		A0,-(SP)
				BSR.S		CALCULATE_OBJECT
				ANDI.W		#$FFFE,10(A0)
				MOVEA.L 	(SP)+,A0
				RTS

*-------------------------------------------------------------------------------

* ---> D3.w = Objektnummer
* <--- A0.l = Objektadresse
CALCULATE_OBJECT:MOVE.L 	D3,-(SP)
				MULU		#24,D3
				LEA 		0(A5,D3.l),A0
				MOVE.L		(SP)+,D3
				RTS

*-------------------------------------------------------------------------------

MAUS_PFEIL: 	CLR.W		GINTIN-VB(a4)
				BRA.S		GRAF_MOUSE
MAUS_BUSY:		MOVE.W		#2,GINTIN-VB(a4)
				BRA.S		GRAF_MOUSE
MOUSE_OFF:		MOVE.W		#256,GINTIN-VB(a4)
				BRA.S		GRAF_MOUSE
MOUSE_ON:		MOVE.W		#257,GINTIN-VB(a4)
GRAF_MOUSE: 	MOVEM.L 	#REGISTER,-(SP)
				MOVE.L		#$4E010101,D0
				BSR 		AES_INIT
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

* ---> D3.l = Extension
* ---> A1.l = *Pfad
* ---> A2.l = *Dateiname
* ---> A3.l = *Titel
FSEL_EXINPUT:	MOVEM.L 	#REGISTER,-(SP)
				MOVE.L		A1,ADDRIN-VB(a4)
				MOVE.L		A2,ADDRIN+4-VB(a4)
				MOVE.L		A3,ADDRIN+8-VB(a4)

				MOVEA.L 	A1,A0
				BSR 		PUT_BACKSLASH
				MOVE.B		#'*',(A0)+
				MOVE.B		#'.',(A0)
				CLR.B		4(A0)
				MOVE.B		D3,3(A0)
				LSR.W		#8,D3
				MOVE.B		D3,2(A0)
				SWAP		D3
				MOVE.B		D3,1(A0)

				MOVE.L		#$5A000202,D0
				TST.B		USE_EXINPUT-VB(a4)
				BEQ.S		DONT_USE_IT
				MOVE.L		#$5B000203,D0
DONT_USE_IT:	BSR 		AES_INIT

				LEA 		255(A1),A0
				MOVEQ		#-1,D0
SCHLEIFE:		MOVE.B		(A1)+,D1
				BEQ.S		FSEL_ENDE
				CMP.B		#'\',D1
				BNE.S		FSEL_WEITER_2
				LEA 		-1(A1),A0
FSEL_WEITER_2:	DBRA		D0,SCHLEIFE
FSEL_ENDE:		MOVE.B		#'\',(A0)+
				CLR.B		(A0)+
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

LOCKED: 		MOVEM.L 	#REGISTER,-(SP)
LOCKED_REG: 	LEA 		SCREEN_LOCK-VB(a4),A3
				BSR.S		FORM_ALERT
				MOVEM.L 	(SP)+,#REGISTER
				RTS

*-------------------------------------------------------------------------------

WO_ISSER:		MOVEM.L 	#REGISTER,-(SP)
WO_ISSER_REG:	LEA 		WO_ISSER_ERROR-VB(a4),A3
				MOVEQ		#'0',D0
				ADD.B		PEACEBUG_NUMBER-VB(a4),D0
				MOVE.B		D0,13(A3)
				BSR.S		FORM_ALERT
				MOVEM.L 	(SP)+,#REGISTER
				ST			-(SP)
				TST.B		(SP)+
				RTS

* ---> A3.l = Alertboxstring
FORM_ALERT: 	MOVEM.L 	#REGISTER,-(SP)
				MOVE.W		GINTIN-VB(a4),-(SP)
				MOVE.W		#1,GINTIN-VB(a4)
				MOVE.L		A3,ADDRIN-VB(a4)
				MOVE.L		#$34010101,D0		  ;FORM_ALERT 52
				BSR 		AES_INIT
				MOVE.W		(SP)+,GINTIN-VB(a4)
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

* ---> D3.w = Object
OBJC_DRAW:		MOVEM.L 	#REGISTER,-(SP)
				MOVE.W		D3,-(SP)

				BSR 		BEG_UPDATE
				BSR 		MOUSE_OFF

				MOVEQ		#11,D3
				BRA.S		DRAW_EINSTIEG
NEXT_DRAW:		MOVEQ		#12,D3
DRAW_EINSTIEG:	BSR 		RSRC_GADDR
				MOVE.L		A5,ADDRIN-VB(a4)
				MOVE.W		WHANDLE(A1),GINTIN-VB(a4)
				BSR 		WIND_GET			  ; 1st/next retangle
				TST.L		D1
				BEQ.S		ENDE_DRAW
				LEA 		GINTIN-VB(a4),A0
				MOVE.W		(SP),(A0)+			  ; Objekt
				MOVE.W		#8,(A0)+			  ; Tiefe
				TST.B		INTERSECT-VB(a4)
				BEQ.S		KEIN_INTERSECT
				MOVEM.L 	INTER_XYWH-VB(a4),D2-D3
				BSR.S		RC_INTERSECT
				BEQ.S		NEXT_DRAW
KEIN_INTERSECT: MOVE.L		D0,(A0)+			  ; Clipping X,Y
				MOVE.L		D1,(A0)+			  ; Clipping W,H
				MOVE.L		#$2A060101,D0		  ; OBJC_DRAW 42
				BSR 		AES_INIT
				BRA.S		NEXT_DRAW

ENDE_DRAW:		ADDQ.W		#2,SP
				BSR 		MOUSE_ON
				BSR 		END_UPDATE
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

* ---> D0.l=X1/Y1, D1.l=W1/H1
* ---> D2.l=X2/Y2, D3.l=W2/H2
* <--- D0.l=X/Y, D1.l=W/H
RC_INTERSECT:	MOVEM.L 	#REGISTER,-(SP)

				ADD.L		D0,D1
				ADD.L		D2,D3

				MOVE.W		D0,INTER_Y-VB(a4)			; INTER_Y=max(y1,y2)
				CMP.W		D0,D2
				BLS.S		.y_io
				MOVE.W		D2,INTER_Y-VB(a4)

.y_io:			SWAP		D0
				SWAP		D2
				MOVE.W		D0,INTER_X-VB(a4)			; INTER_X=max(x1,x2)
				CMP.W		D0,D2
				BLS.S		.x_io
				MOVE.W		D2,INTER_X-VB(a4)

.x_io:			MOVE.W		D1,INTER_H-VB(a4)			; INTER_H=min(y1+h1,y2+h2)
				CMP.W		D1,D3
				bge.s		.h_io
				MOVE.W		D3,INTER_H-VB(a4)

.h_io:			SWAP		D1
				SWAP		D3
				MOVE.W		D1,INTER_W-VB(a4)			; INTER_W=min(x1+w1,x2+w2)
				CMP.W		D1,D3
				bge.s		.w_io
				MOVE.W		D3,INTER_W-VB(a4)

.w_io:			MOVEM.W 	INTER_X-VB(a4),D0-D1
				sub.w		d0,INTER_W-VB(a4)
				sub.w		d1,INTER_H-VB(a4)
				tst.w		INTER_W-VB(a4)
				ble.s		.no_retangle
				tst.w		INTER_H-VB(a4)
				ble.s		.no_retangle
				MOVEM.L 	(SP)+,#REGISTER
				MOVEM.L 	INTER_X-VB(a4),D0-D1
				MOVE.L		D1,D1
				RTS

.no_retangle:	MOVEM.L 	(SP)+,#REGISTER
				MOVEQ		#0,D0
				RTS

*-------------------------------------------------------------------------------

CURSOR_ON:		MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#0,D0
				MOVEQ		#1,D3
				BSR.S		OBJC_EDIT
				BRA 		RTS_REG

CURSOR_OFF: 	MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#0,D0
				MOVEQ		#3,D3
				BSR.S		OBJC_EDIT
				BRA 		RTS_REG

* ---> D0.w = Taste, Scan*256+Ascii
* ---> D3.w = Funktion (1=Cursor ein, 2=Zeichen eingeben, 3=Cursor aus)
OBJC_EDIT:		MOVEM.L 	#REGISTER,-(SP)
				MOVE.W		WKEY_OBJ(A1),GINTIN-VB(a4)
				MOVE.W		D0,GINTIN+2-VB(a4)
				MOVE.W		WKEY_POS(A1),GINTIN+4-VB(a4)
				MOVE.W		D3,GINTIN+6-VB(a4)
				MOVE.L		A5,ADDRIN-VB(a4)
				MOVE.L		#$2E040201,D0		  ; OBJC_EDIT 46
				BSR 		AES_INIT
				MOVE.W		GINTOUT+2-VB(a4),WKEY_POS(A1)
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

* ---> D0.w = Taste, Scan*256+Ascii
* <--- flag.eq = Ausgangsobjekt
FORM_KEYBD: 	MOVEM.L 	#REGISTER,-(SP)
				MOVE.W		WKEY_OBJ(A1),GINTIN-VB(a4)
				MOVE.W		D0,GINTIN+2-VB(a4)
				CLR.W		GINTIN+4-VB(a4)
				MOVE.L		A5,ADDRIN-VB(a4)
				MOVE.L		#$37030301,D0		  ; FORM_KEYBD 55
				BSR 		AES_INIT
				MOVEM.L 	(SP)+,#REGISTER
				TST.W		GINTOUT-VB(a4)
				RTS

*-------------------------------------------------------------------------------

* ---> D3.w = OBJEKT
* <--- flag.eq = Ausgangsobjekt
FORM_BUTTON:	MOVEM.L 	#REGISTER,-(SP)
				MOVE.W		D3,GINTIN-VB(a4)
				MOVE.W		#1,GINTIN+2-VB(a4)
				MOVE.L		A5,ADDRIN-VB(a4)
				MOVE.L		#$38020201,D0		  ; FORM_BUTTON 56
				BSR 		AES_INIT
				MOVEM.L 	(SP),#REGISTER
				BSR 		CALCULATE_OBJECT
				BTST		#0,9(A0)			  ; selektierbar?
				BEQ 		RTS_REG
				BTST		#2,9(A0)			  ; exit?
				BEQ 		RTS_REG
				TST.W		GINTOUT-VB(a4)			 ; oder Dialog beenden?
				BEQ 		RTS_REG
				MOVEM.L 	(SP)+,#REGISTER 	   ; andernfalls die Dialog-
				ADDQ.W		#4,SP				  ; routine ignorieren
				RTS

*-------------------------------------------------------------------------------

END_UPDATE: 	MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#0,D3
				BRA.S		WIND_UPDATE
BEG_UPDATE: 	MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#1,D3
WIND_UPDATE:	MOVE.W		D3,GINTIN-VB(a4)
				MOVE.L		#$6B010100,D0		  ; WIND_UPDATE 107
				BSR 		AES_INIT
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

* ---> D3.w = w_field
* <--- D0-D1 = X/Y/W/H
WIND_GET:		MOVEM.L 	#REGISTER,-(SP)
				MOVE.W		D3,GINTIN+2-VB(a4)
				MOVE.L		#$68020500,D0
				BSR.S		AES_INIT			  ; WIND_GET 104
				TST.L		GINTOUT+6-VB(a4)
				MOVEM.L 	(SP)+,#REGISTER
				MOVEM.L 	GINTOUT+2-VB(a4),D0-D1
				RTS

*-------------------------------------------------------------------------------

* ---> D3.w = w_field
WIND_SET:		MOVEM.L 	#REGISTER,-(SP)
				MOVE.W		WHANDLE(A1),GINTIN-VB(a4)
				MOVE.W		D3,GINTIN+2-VB(a4)
				MOVE.L		#$69060100,D0		  ; WIND_SET 105
				BSR.S		AES_INIT
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

CLOSE_WINDOW:	MOVEM.L 	#REGISTER,-(SP)
				MOVE.W		WHANDLE(A1),GINTIN-VB(a4)
				MOVE.L		#$66010100,D0		  ; WIND_CLOSE 102
				BSR.S		AES_INIT
				MOVE.W		WHANDLE(A1),GINTIN-VB(a4)
				MOVE.L		#$67010100,D0		  ; WIND_DELETE 103
				BSR.S		AES_INIT
				SF			WFLAG(A1)
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

* <--- A5 = Baumadresse
RSRC_GADDR: 	MOVEM.L 	#REGISTER,-(SP)
				CLR.W		GINTIN-VB(a4)
				MOVE.W		WTREE(A1),GINTIN+2-VB(a4)
				MOVE.L		#$70020100,D0		  ; RSRC_GADDR 112
				MOVE.W		#1,CONTROL+8-VB(a4)
				BSR.S		AES_INIT
				MOVEM.L 	(SP)+,#REGISTER
				MOVEA.L 	ADDROUT-VB(a4),A5
				RTS

*-------------------------------------------------------------------------------

AES_INIT:		MOVEM.L 	#REGISTER,-(SP)
				CLR.L		CONTROL-VB(a4)
				CLR.L		CONTROL+4-VB(a4)
				MOVEP.L 	D0,CONTROL+1-VB(a4)
				MOVE.L		#AES_PB,D1
				MOVE.W		#$00C8,D0
				TRAP		#2
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

CALL_SUPER:		MOVEM.L 	D0-A6,-(SP)
				MOVE.L		15*4+4(SP),-(SP)
				MOVE.W		#38,-(SP)
				TRAP		#14
				ADDQ.W		#6,SP
				MOVEM.L 	(SP)+,D0-A6
				MOVE.L		(SP)+,(SP)
				RTS

*-------------------------------------------------------------------------------

* ---> D3.w = Objekt
CLEAR_BUTTONS:	MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#0,D3
CLEAR_LOOP: 	BSR 		CLEAR_OB_STATE
				BSR 		CALCULATE_OBJECT
				ADDQ.W		#1,D3
				BTST		#5,9(A0)
				BEQ.S		CLEAR_LOOP
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

WINDOW_OPEN:	MOVEM.L 	#REGISTER,-(SP)
				LEA 		GINTIN-VB(a4),A0
				CLR.W		(A0)+
				MOVE.W		#11,(A0)+
				MOVE.L		16(A5),(A0)+
				MOVE.L		20(A5),(A0)+
				MOVE.L		#$6C060500,D0		; WIND_CALC 108
				BSR.S		AES_INIT
				TST.W		GINTOUT-VB(a4)
				BEQ 		NO_WINDOW_1
				MOVEM.L 	GINTOUT+2-VB(a4),D6-D7
* <--- D6-D7 = X/Y/W/H

				CLR.W		GINTIN-VB(a4)
				MOVEQ		#4,D3
				BSR 		WIND_GET			; Desktopmasse
* <--- D0-D1 = X/Y/W/H

				swap		d0
				swap		d1
				swap		d6
				swap		d7
				move.w		d0,d2				; x2 testen
				add.w		d1,d2
				move.w		d6,d3
				add.w		d7,d3
				sub.w		d2,d3
				ble.s		.x2_io
				sub.w		d3,d6
.x2_io:			swap		d0
				swap		d1
				swap		d6
				swap		d7
				move.w		d0,d2				; y2 testen
				add.w		d1,d2
				move.w		d6,d3
				add.w		d7,d3
				sub.w		d2,d3
				ble.s		.y2_io
				sub.w		d3,d6
.y2_io:			cmp.w		d0,d6				; x1 testen
				bge.s		.x1_io
				move.w		d0,d6
.x1_io:			swap		d0
				swap		d6
				cmp.w		d0,d6				; y1 testen
				bge.s		.y1_io
				move.w		d0,d6
.y1_io:			swap		d6

				MOVE.W		#11,GINTIN-VB(a4)
				MOVEM.L 	D0-D1,GINTIN+2-VB(a4)
				MOVE.L		#$64050100,D0		  ; WIND_CREATE 100
				BSR 		AES_INIT
				MOVE.W		GINTOUT-VB(a4),WHANDLE(A1)
				BMI.S		NO_WINDOW_1

				MOVEQ		#2,D3
				MOVE.L		WTITEL(A1),GINTIN+4-VB(a4)
				BSR 		WIND_SET
				TST.W		GINTOUT-VB(a4)
				BEQ.S		NO_WINDOW_1

				MOVEM.L 	D6-D7,GINTIN+2-VB(a4)
				MOVE.L		#$65050100,D0		  ; WIND_OPEN 101
				BSR 		AES_INIT
				TST.W		GINTOUT-VB(a4)
				BEQ.S		NO_WINDOW_1

				MOVEQ		#4,D3
				MOVE.W		WHANDLE(A1),GINTIN-VB(a4)
				BSR 		WIND_GET
				MOVE.L		D0,16(A5)

				ST			WFLAG(A1)
				BRA 		RTS_REG

NO_WINDOW_1:	SF			WFLAG(A1)
				LEA 		WINDOW_FAIL-VB(a4),A3
				BSR 		FORM_ALERT
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

SET_MODUS:		MOVEM.L 	#REGISTER,-(SP)
				MOVEQ		#CONF,D3
				BSR 		CALCULATE_OBJECT

				MOVEA.L 	12(A0),A1
				MOVEA.L 	(A1),A1
				MOVEQ		#'0',D0
				ADD.B		PEACEBUG_NUMBER-VB(a4),D0
				MOVE.B		D0,12(A1)

				BCLR		#7,9(A0)
				MOVEQ		#PATCH,D3
				BSR 		CALCULATE_OBJECT
				BSET		#7,9(A0)
				TST.B		PATCH_MODUS-VB(a4)
				BEQ 		RTS_REG
				MOVEQ		#CONF,D3
				BSR 		CALCULATE_OBJECT
				BSET		#7,9(A0)
				MOVEQ		#PATCH,D3
				BSR 		CALCULATE_OBJECT
				BCLR		#7,9(A0)
				BRA 		RTS_REG

*-------------------------------------------------------------------------------

PUT_BACKSLASH:	MOVEQ		#-1,D0
SLASH_LOOP: 	TST.B		(A0)+
				DBEQ		D0,SLASH_LOOP
				SUBQ.W		#1,A0
				CMPI.B		#'\',-1(A0)
				BEQ.S		SCHON_DA
				MOVE.B		#'\',(A0)+
SCHON_DA:		RTS

*-------------------------------------------------------------------------------

* ---> D3.l = Cookiekennung
* <--- A0.l = Zeiger auf den Cookie
* <--- flag.eq = nichts gefunden
SEARCH_COOKIE:	MOVEM.L 	#REGISTER,-(SP)
				MOVE.L		D3,COOKIE_TEMP-VB(a4)
				PEA 		COOKIE(PC)
				BSR 		CALL_SUPER
				MOVEM.L 	(SP)+,#REGISTER
				MOVEA.L 	COOKIE_POINTER_0-VB(a4),A0
				PEA 		(A0)
				TST.L		(SP)+
				RTS

*-------------------------------------------------------------------------------

* <--- A0.l = Zeiger auf den Cookie
* <--- flag.eq = nichts gefunden
SEARCH_PEACEBUG:MOVEM.L 	D0-D7/A1-A6,-(SP)
				MOVE.L		#'PBUG',COOKIE_TEMP-VB(a4)
				PEA 		COOKIE(PC)
				BSR 		CALL_SUPER
				LEA 		COOKIES-VB(a4),A0
				MOVEQ		#0,D0
				MOVE.B		PEACEBUG_NUMBER-VB(a4),D0
				ADD.W		D0,D0
				ADD.W		D0,D0
				MOVEA.L 	0(A0,D0.w),A0
				MOVEM.L 	(SP)+,D0-D7/A1-A6
				PEA 		(A0)
				TST.L		(SP)+
				RTS

*-------------------------------------------------------------------------------

COOKIE: 		MOVEM.L 	#REGISTER,-(SP)
				LEA 		VB(PC),A4
				MOVEQ		#9,D0					; Anzahl freier Cookies
				LEA 		COOKIES-VB(a4),A0		; Cookiearray

				MOVE.L		COOKIE_TEMP(PC),D3
				MOVEA.L 	$000005A0.w,A1
				MOVE.L		A1,D7
				BEQ.S		ENDE_COOKIE				; kein Cookiejar installiert
				SUBQ.W		#8,A1
COOKIE_SUCHEN:	ADDQ.W		#8,A1
				TST.L		(A1)
				BEQ.S		ENDE_COOKIE				; Ende des Cookie erreicht
				CMP.L		(A1),D3
				BNE.S		COOKIE_SUCHEN			; falsche Kennung
				MOVE.L		4(A1),(A0)+				; Cookie eintragen
				DBRA		D0,COOKIE_SUCHEN

ENDE_COOKIE:	MOVE.W		D0,COOKIE_ANZAHL-VB(a4)
				BMI.S		COOKIE_VOLL
COOKIE_LOOP:	CLR.L		(A0)+
				DBRA		D0,COOKIE_LOOP
COOKIE_VOLL:	SUBI.W		#9,COOKIE_ANZAHL-VB(a4)
				NEG.W		COOKIE_ANZAHL-VB(a4)
				MOVEM.L 	(SP)+,#REGISTER
				RTS

*-------------------------------------------------------------------------------

CONFIG: 		SF			LOCKED_FLAG-VB(a4)
				PEA 		SUPERVISOR(PC)
				BSR 		CALL_SUPER
				TST.B		LOCKED_FLAG-VB(a4)
				BNE 		LOCKED
				RTS

SUPERVISOR: 	BSR 		SEARCH_PEACEBUG
				BEQ 		RTS
				SF			NEW_FORMAT-VB(a4)
				MOVEQ		#0,D0
				MOVEQ		#6,D7
				LEA 		CACHE_FLAG-VB(a4),A6
CONFIG_LOOP:	TST.B		(A6)+
				BEQ.S		NO_JSR
				MOVEM.L 	#REGISTER,-(SP)
				MOVE.W		CONFIG_TABELLE(PC,D0.w),D1
				JSR 		CONFIG_TABELLE(PC,D1.w)
				MOVEM.L 	(SP)+,#REGISTER
NO_JSR: 		ADDQ.W		#2,D0
				DBRA		D7,CONFIG_LOOP
				TST.B		NEW_FORMAT-VB(a4)
				BEQ 		RTS
				MOVEA.L 	24(A0),A2
				TST.B		102(A2)
				SNE 		LOCKED_FLAG-VB(a4)
				BNE 		RTS
				ST			102(A2)
				MOVEA.L 	16(A0),A1
				JSR 		(A1)
				MOVEA.L 	20(A0),A1
				JSR 		(A1)
				CLR.B		102(A2)
				RTS

*-------------------------------------------------------------------------------

CONFIG_TABELLE: 		DC.W CACHE_CONF-CONFIG_TABELLE,HISTORY_CONF-CONFIG_TABELLE
						DC.W INVERT_CONF-CONFIG_TABELLE,GETREZ_CONF-CONFIG_TABELLE
						DC.W NEWFONT_CONF-CONFIG_TABELLE,NEWFORMAT_CONF-CONFIG_TABELLE
						DC.W NEWSCREEN_CONF-CONFIG_TABELLE

*-------------------------------------------------------------------------------

CACHE_CONF: 	MOVEA.L 	36(A0),A0
				MOVEA.L 	138(A0),A0
				MOVE.W		ADD1-VB(a4),-(SP)
				MOVE.W		ADD2-VB(a4),-(SP)
				JSR 		(A0)
				ADDQ.W		#4,SP
				RTS

*-------------------------------------------------------------------------------

HISTORY_CONF:	MOVEA.L 	36(A0),A0
				MOVEA.L 	118(A0),A0
				MOVE.L		HISTORY-VB(a4),-(SP)
				JSR 		(A0)
				ADDQ.W		#4,SP
				RTS

*-------------------------------------------------------------------------------

INVERT_CONF:	MOVEA.L 	24(A0),A0
				TST.B		102(A0)
				BNE.S		SET_NEWFORMAT
				ST			102(A0)
				MOVE.W		#1023,D7
				MOVEA.L 	32(A0),A1
INVERT_LOOP_1:	NOT.L		(A1)+
				DBRA		D7,INVERT_LOOP_1
				MOVE.W		#511,D7
				MOVEA.L 	36(A0),A1
INVERT_LOOP_2:	NOT.L		(A1)+
				DBRA		D7,INVERT_LOOP_2
				CLR.B		102(A0)
SET_NEWFORMAT:	ST			NEW_FORMAT-VB(a4)
				RTS

*-------------------------------------------------------------------------------

GETREZ_CONF:	MOVEA.L 	24(A0),A6
				TST.B		102(A6)
				BNE.S		SET_NEWFORMAT
				ST			102(A6)

				MOVEA.L 	4(A0),A1
				JSR 		(A1)
				MOVE.L		A0,-(SP)
				MOVE.W		#4,-(SP)
				TRAP		#14
				ADDQ.W		#2,SP
				MOVEA.L 	(SP)+,A0
				TST.W		D0
				BMI.S		NO_REZ
				CMP.W		#7,D0
				BHI.S		NO_REZ
				MULU		#6,D0
				LEA 		RESOLUTION(PC,D0.l),A5
				MOVEM.W 	(A5),D1-D3
				TST.W		D1
				BEQ.S		NO_REZ
				LEA 		42(A6),A5
				CLR.L		(A5)+
				MOVE.W		D1,(A5)+
				MOVE.W		D1,(A5)+
				MOVE.W		D2,(A5)+
				MULU		D3,D1
				MOVE.W		D1,(A5)+
				MOVE.W		D2,(A5)+
				MOVE.W		D3,(A5)+

NO_REZ: 		CLR.B		102(A6)
				ST			NEW_FORMAT-VB(a4)
				RTS

*-------------------------------------------------------------------------------

RESOLUTION: 	DC.W 320/8,200,4
				DC.W 640/8,200,2
				DC.W 640/8,400,1
				DC.W 0,0,0
				DC.W 640/8,480,4
				DC.W 0,0,0
				DC.W 1280/8,960,1
				DC.W 320/8,480,8

*-------------------------------------------------------------------------------

NEWFONT_CONF:	MOVEA.L 	24(A0),A0
				TST.B		102(A0)
				BNE.S		NO_FONT
				ST			102(A0)
				MOVEA.L 	32(A0),A1
				LEA 		FONT_16_8-VB(a4),A2
				MOVE.W		#1023,D7
COPY_FONT_5:	MOVE.L		(A2)+,(A1)+
				DBRA		D7,COPY_FONT_5
				MOVEA.L 	36(A0),A1
				LEA 		FONT_8_8-VB(a4),A2
				MOVE.W		#511,D7
COPY_FONT_6:	MOVE.L		(A2)+,(A1)+
				DBRA		D7,COPY_FONT_6
				CLR.B		102(A0)
NO_FONT:		ST			NEW_FORMAT-VB(a4)
				RTS

*-------------------------------------------------------------------------------

NEWFORMAT_CONF: MOVEA.L 	24(A0),A1
				TST.B		102(A1)
				BNE.S		NO_NEWFORMAT
				ST			102(A1)
				MOVEA.L 	4(A0),A0
				JSR 		(A0)
				CLR.B		102(A1)
NO_NEWFORMAT:	ST			NEW_FORMAT-VB(a4)
				RTS

*-------------------------------------------------------------------------------

NEWSCREEN_CONF: MOVEA.L 	24(A0),A2
				TST.B		102(A2)
				BNE.S		NO_NEWSCREEN
				ST			102(A2)
				MOVEA.L 	(A0)+,A1
				JSR 		(A1)
				MOVEA.L 	(A0)+,A1
				JSR 		(A1)
				MOVE.W		#%0000000000000111,-(SP)
				MOVEA.L 	(A0)+,A1
				JSR 		(A1)
				ADDQ.W		#2,SP
				MOVE.W		#%0000000000000111,-(SP)
				MOVEA.L 	(A0)+,A1
				JSR 		(A1)
				ADDQ.W		#2,SP
				CLR.B		102(A2)
NO_NEWSCREEN:	ST			NEW_FORMAT-VB(a4)
				RTS

******************	D A T A  -	S E G M E N T  *********************************

VB:

AES_PB: 				DC.L CONTROL,GLOBAL,GINTIN,GINTOUT,ADDRIN,ADDROUT

*-------------------------------------------------------------------------------

RECORDS:
		.EVEN
WRECORD_0:				DC.W MENUE
						DC.L WTITEL_0
						DC.L WOPEN_0
						DC.L WCLOSE_0
						DC.L WBUTTON_0
						DC.L WKEYBOARD_0
						DC.L WCLOSE_0
						DC.W 0
						DC.W 0
						DC.W 0
						DC.B 0
						DC.B 0

*-----------------------

		.EVEN
WRECORD_1:				DC.W INFO
						DC.L WTITEL_1
						DC.L WOPEN_1
						DC.L CLOSE_WINDOW
						DC.L 0
						DC.L 0
						DC.L CLOSE_WINDOW
						DS.W 1
						DS.W 1
						DS.W 1
						DS.B 1
						DS.B 1

*-----------------------

		.EVEN
WRECORD_2:				DC.W FLAGBOX
						DC.L WTITEL_2
						DC.L WOPEN_2
						DC.L CLOSE_WINDOW
						DC.L WBUTTON_2
						DC.L 0
						DC.L OK2
						DS.W 1
						DS.W 1
						DS.W 1
						DS.B 1
						DS.B 1

*-----------------------

		.EVEN
WRECORD_3:				DC.W CACHE
						DC.L WTITEL_3
						DC.L WOPEN_3
						DC.L CLOSE_WINDOW
						DC.L WBUTTON_3
						DC.L 0
						DC.L OK3
						DS.W 1
						DC.W _ADD1
						DS.W 1
						DS.B 1
						DS.B 1

*-----------------------

		.EVEN
WRECORD_4:				DC.W KEYBOARD
						DC.L WTITEL_4
						DC.L WOPEN_4
						DC.L CLOSE_WINDOW
						DC.L WBUTTON_4
						DC.L 0
						DC.L OK4
						DS.W 1
						DC.W 0
						DS.W 1
						DS.B 1
						DS.B 1

*-----------------------

		.EVEN
WRECORD_5:				DC.W PARAM
						DC.L WTITEL_5
						DC.L WOPEN_5
						DC.L CLOSE_WINDOW
						DC.L WBUTTON_5
						DC.L 0
						DC.L OK8
						DS.W 1
						DC.W _KREPEAT
						DS.W 1
						DS.B 1
						DS.B 1

*-----------------------

		.EVEN
WRECORD_6:				DC.W SCRPARAM
						DC.L WTITEL_6
						DC.L WOPEN_6
						DC.L CLOSE_WINDOW
						DC.L WBUTTON_6
						DC.L 0
						DC.L OK1
						DS.W 1
						DC.W _OFFSETX
						DS.W 1
						DS.B 1
						DS.B 1

*-----------------------

		.EVEN
WRECORD_7:				DC.W PRIORITA
						DC.L WTITEL_7
						DC.L WOPEN_7
						DC.L CLOSE_WINDOW
						DC.L WBUTTON_7
						DC.L 0
						DC.L OK6
						DS.W 1
						DS.W 1
						DS.W 1
						DS.B 1
						DS.B 1

*-----------------------

		.EVEN
WRECORD_8:				DC.W USER
						DC.L WTITEL_8
						DC.L WOPEN_8
						DC.L CLOSE_WINDOW
						DC.L WBUTTON_8
						DC.L 0
						DC.L CLOSE_WINDOW
						DS.W 1
						DS.W 1
						DS.W 1
						DS.B 1
						DS.B 1

*-----------------------

		.EVEN
WRECORD_9:				DC.W SPEED
						DC.L WTITEL_9
						DC.L WOPEN_9
						DC.L CLOSE_WINDOW
						DC.L WBUTTON_9
						DC.L 0
						DC.L OK5
						DS.W 1
						DS.W 1
						DS.W 1
						DS.B 1
						DS.B 1

*-----------------------

		.EVEN
WRECORD_10: 			DC.W KONFIG
						DC.L WTITEL_10
						DC.L WOPEN_10
						DC.L CLOSE_WINDOW
						DC.L WBUTTON_10
						DC.L 0
						DC.L OK9
						DS.W 1
						DS.W 1
						DS.W 1
						DS.B 1
						DS.B 1

*-----------------------

ACCESSORY_NAME: 		DC.B '  Peacebug Config ',0
WTITEL_0:				DC.B ' PBUGCONF V'
						IF VERSIONS_NUMMER<'1000'
						DC.B (VERSIONS_NUMMER>>16)&$00FF,'.',(VERSIONS_NUMMER>>8)&$00FF,VERSIONS_NUMMER&$00FF,32,0
						ELSE
						DC.B (VERSIONS_NUMMER>>24)&$00FF,(VERSIONS_NUMMER>>16)&$00FF,'.',(VERSIONS_NUMMER>>8)&$00FF,VERSIONS_NUMMER&$00FF,32,0
						ENDIF
						IF GERMAN
WTITEL_1:				DC.B ' Information ',0
WTITEL_2:				DC.B ' Vektoren ',0
WTITEL_3:				DC.B ' Cache ',0
WTITEL_4:				DC.B ' Tastatur ',0
WTITEL_5:				DC.B ' Diverses ',0
WTITEL_6:				DC.B ' Bildschirm ',0
WTITEL_7:				DC.B ' Priorit„ten ',0
WTITEL_8:				DC.B ' Userroutinen ',0
WTITEL_9:				DC.B ' Beschleuniger ',0
WTITEL_10:				DC.B ' Konfigurieren ',0
						ELSE
WTITEL_1:				DC.B ' Information ',0
WTITEL_2:				DC.B ' Vectors ',0
WTITEL_3:				DC.B ' Cache ',0
WTITEL_4:				DC.B ' Keyboard ',0
WTITEL_5:				DC.B ' Miscellaneous ',0
WTITEL_6:				DC.B ' Screen ',0
WTITEL_7:				DC.B ' Precedence ',0
WTITEL_8:				DC.B ' User Routines ',0
WTITEL_9:				DC.B ' Accelerator ',0
WTITEL_10:				DC.B ' Configurate ',0
						ENDIF

*-------------------------------------------------------------------------------

FLAGS_CHOOSE:			DC.B _FLAG11
PRIORITY_CHOOSE:		DC.B _PLUS
KEYBOARD_CHOOSE:		DC.B _JUMPIN1

*-------------------------------------------------------------------------------

						IF GERMAN
WINDOW_FAIL:			DC.B '[3][Es kann kein weiteres Fenster|mehr ge”ffnet werden.|][Abbruch]',0
SCREEN_LOCK:			DC.B '[3][Im Moment darf nicht auf|Peacebugs Bildschirmschnitt-|stelle zugegriffen werden.|][Abbruch]',0
WO_ISSER_ERROR: 		DC.B '[1][Peacebug 0 nicht gefunden!|][Abbruch]',0
PATCHMODUS_MESSAGE: 	DC.B '[3][Im Patchmodus k”nnen keine|Userroutinen installiert|werden.|][Abbruch]',0
RESIDENT_MESSAGE:		DC.B '[3][Die Basepage von PBUGCONF|bleibt resident, da ein|Programm nachgeladen wurde.|][  OK  ]',0
MALLOC_ERROR:			DC.B '[1][Fehler beim Reservieren|des Speichers.|][Abbruch]',0
LADEN_MESSAGE:			DC.B '[3][Parameter geladen.|][  OK  ]',0
SAVE_MESSAGE:			DC.B '[3][Parameter gespeichert.|][  OK  ]',0
LADEN_ERROR:			DC.B '[1][Fehler beim Laden der|Parameter.|][Abbruch]',0
SPEICHERN_ERROR:		DC.B '[1][Fehler beim Speichern der|Parameter.|][Abbruch]',0
WRONG_FILE_LADEN:		DC.B '[1][Parameter k”nnen nur von der|aktuellen Pbugconf-Version|oder von Peacebug geladen|werden.|][Abbruch]',0
WRONG_FILE_SPEICHERN:	DC.B '[1][Parameter k”nnen nur in der|aktuellen Pbugconf-Version|oder in Peacebug gespeichert|werden.|][Abbruch]',0
FONT_ERROR: 			DC.B '[1][Fehler beim Laden des|Fonts.|][Abbruch]',0
ROUTINEN_ERROR: 		DC.B '[1][Fehler beim Laden der|Userroutine.|][Abbruch]',0
						ELSE
WINDOW_FAIL:			DC.B '[3][I could not open one more|window.|][ Cancel ]',0
SCREEN_LOCK:			DC.B '[3][At the moment Peacebug''s|screen interface is locked.|][ Cancel ]',0
WO_ISSER_ERROR: 		DC.B '[3][Peacebug 0 not found.|][Cancel]',0
PATCHMODUS_MESSAGE: 	DC.B '[3][In patch mode no user|routines can be installed.|][Cancel]',0
RESIDENT_MESSAGE:		DC.B '[3][The basepage of PBUGCONF|remains resident, as a|program has been loaded.|][  OK  ]',0
MALLOC_ERROR:			DC.B '[1][Error allocating memory.|][Cancel]',0
LADEN_MESSAGE:			DC.B '[3][Parameters loaded.|][  OK  ]',0
SAVE_MESSAGE:			DC.B '[3][Parameters saved.|][  OK  ]',0
LADEN_ERROR:			DC.B '[1][Error loading the|parameters.|][Cancel]',0
SPEICHERN_ERROR:		DC.B '[1][Error saving the|parameters.|][Cancel]',0
WRONG_FILE_LADEN:		DC.B '[1][Parameters can only be loaded|from the actual Pbugconf version|or from Peacebug|][Cancel]',0
WRONG_FILE_SPEICHERN:	DC.B '[1][Parameters can only be saved|into the actual Pbugconf version|or into Peacebug|][Cancel]',0
FONT_ERROR: 			DC.B '[1][Error loading the font.|][Cancel]',0
ROUTINEN_ERROR: 		DC.B '[1][Error loading the user|routine.|][Cancel]',0
						ENDIF

*-----------------------

						IF GERMAN
TITEL_2:				DC.B 'Parameter laden',0
TITEL_3:				DC.B 'Parameter speichern',0
TITEL_4:				DC.B 'Font 8*16 laden',0
TITEL_5:				DC.B 'Font 8*8 laden',0
TITEL_6:				DC.B 'Usertrace laden',0
TITEL_7:				DC.B 'Userenter laden',0
TITEL_8:				DC.B 'Userquit laden',0
TITEL_9:				DC.B 'Userswitch-Enter laden',0
TITEL_10:				DC.B 'Userswitch-Quit laden',0
TITEL_11:				DC.B 'Userreset laden',0
						ELSE
TITEL_2:				DC.B 'Load Parameters',0
TITEL_3:				DC.B 'Save Parameters',0
TITEL_4:				DC.B 'Load Font 8*16',0
TITEL_5:				DC.B 'Load Font 8*8',0
TITEL_6:				DC.B 'Load Usertrace',0
TITEL_7:				DC.B 'Load Userenter',0
TITEL_8:				DC.B 'Load Userquit',0
TITEL_9:				DC.B 'Load Userswitch_enter',0
TITEL_10:				DC.B 'Load Userswitch_quit',0
TITEL_11:				DC.B 'Load Userreset',0
						ENDIF

*-----------------------

FILE_2: 				DC.B 'PBUGCONF.PRG',0
FILE_4: 				DC.B 'FONT16.FNT',0,0,0
FILE_5: 				DC.B 'FONT8.FNT',0,0,0,0
FILE_6: 				DC.B 'TRACE.USR',0,0,0,0
FILE_7: 				DC.B 'ENTER.USR',0,0,0,0
FILE_8: 				DC.B 'QUIT.USR',0,0,0,0,0
FILE_9: 				DC.B 'SWITCH_1.USR',0
FILE_10:				DC.B 'SWITCH_2.USR',0
FILE_11:				DC.B 'RESET.USR',0,0,0,0

*-----------------------

						IF GERMAN
STRING_ABBRUCH: 		DC.B 'Abbruch',0
						ELSE
STRING_ABBRUCH: 		DC.B 'Cancel',0
						ENDIF

*-------------------------------------------------------------------------------

		.EVEN
KENNUNG_1:				DC.L 0
						DC.L 0
KENNUNG_2:				DC.L 'PCON'
						DC.L VERSIONS_NUMMER

PARAMETER_ANFANG:
FONT_FLAG:				DC.W	4
OFFSET_X:				DC.W	0
OFFSET_Y:				DC.W	0
BILD_BREITE:			DC.W	80
ZEILEN_LAENGE:			DC.W	80
BILD_HOEHE: 			DC.W	400
SCREEN_BREITE:			DC.W	80
SCREEN_HOEHE:			DC.W	400
PLANES: 				DC.W	1
_BILDSCHIRM_LENGTH: 	DC.L	0
_ZEICHEN_LENGTH:		DC.L	0
_MAUS_LENGTH:			DC.L	0
						DS.L	4
_OFFSET_X:				DC.W	0
_OFFSET_Y:				DC.W	0
_BILD_BREITE:			DC.W	0
_BILD_HOEHE:			DC.W	0
_PLANES_:				DC.W	0


SWITCH_PALETTE: 	dc.b	-1					; r/w/p/l
SWITCH_REGISTER: 	dc.b	-1					; r/w/p/l

*-------------------------------------------------------------------------------

FONT_16_8:
    dc.b    0,6,9,11,13,9,6,96,144,176,208,144,96,0,0,0,0,0,0,24,60,102,195,129,231,36,36,36,60,0,0,0
    dc.b    0,0,0,60,36,36,36,231,129,195,102,60,24,0,0,0,0,0,48,56,44,230,131,131,230,44,56,48,0,0,0,0
    dc.b    0,0,12,28,52,103,193,193,103,52,28,12,0,0,0,0,0,0,124,56,186,146,214,198,214,146,186,56,124,0,0,0
    dc.b    0,0,254,254,254,252,252,248,250,242,246,230,238,0,0,0,0,0,238,198,214,146,186,56,186,146,214,198,238,0,0,0
    dc.b    0,0,1,1,3,3,6,6,140,140,216,88,112,48,32,0,0,0,0,60,102,195,145,145,157,129,195,102,60,0,0,0
    dc.b    0,0,0,0,24,60,60,60,60,60,126,255,16,56,16,0,0,0,8,14,15,9,8,8,120,248,112,0,0,0,0,0
    dc.b    0,0,120,64,112,64,64,0,30,16,28,16,16,0,0,0,0,0,56,64,64,64,56,0,28,18,28,20,18,0,0,0
    dc.b    0,5,5,5,5,13,13,29,57,121,113,113,97,65,0,0,0,160,160,160,160,176,176,184,156,158,142,142,134,130,0,0
    dc.b    0,124,186,198,198,198,130,0,130,198,198,198,186,124,0,0,0,0,2,6,6,6,2,0,2,6,6,6,2,0,0,0
    dc.b    0,124,58,6,6,6,58,124,184,192,192,192,184,124,0,0,0,124,58,6,6,6,58,124,58,6,6,6,58,124,0,0
    dc.b    0,0,130,198,198,198,186,124,58,6,6,6,2,0,0,0,0,124,184,192,192,192,184,124,58,6,6,6,58,124,0,0
    dc.b    0,124,184,192,192,192,184,124,186,198,198,198,186,124,0,0,0,124,186,198,198,198,130,0,2,6,6,6,2,0,0,0
    dc.b    0,124,186,198,198,198,186,124,186,198,198,198,186,124,0,0,0,124,186,198,198,198,186,124,58,6,6,6,58,124,0,0
    dc.b    0,0,0,0,0,124,126,6,6,126,102,102,126,60,0,0,0,0,120,64,112,64,120,0,14,16,12,2,28,0,0,0
    dc.b    0,0,0,0,0,0,0,0,7,15,31,24,24,16,30,23,0,0,0,0,0,0,0,0,240,248,236,4,4,4,60,84
    dc.b    17,11,13,6,7,46,57,56,0,0,0,0,0,0,0,0,0,0,252,252,252,255,225,225,225,225,33,33,63,0,0,0
    dc.b    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,24,60,60,60,24,24,0,24,24,0,0,0
    dc.b    0,0,0,102,102,102,36,0,0,0,0,0,0,0,0,0,0,0,0,0,108,108,254,108,108,108,254,108,108,0,0,0
    dc.b    0,0,24,24,124,198,194,192,124,6,134,198,124,24,24,0,0,0,0,0,0,0,194,198,12,24,48,102,198,0,0,0
    dc.b    0,0,0,0,56,108,108,56,118,220,204,204,118,0,0,0,0,0,0,48,48,48,96,0,0,0,0,0,0,0,0,0
    dc.b    0,0,0,0,12,24,48,48,48,48,48,24,12,0,0,0,0,0,0,0,48,24,12,12,12,12,12,24,48,0,0,0
    dc.b    0,0,0,0,0,0,102,60,255,60,102,0,0,0,0,0,0,0,0,0,0,0,24,24,126,24,24,0,0,0,0,0
    dc.b    0,0,0,0,0,0,0,0,0,0,24,24,24,48,0,0,0,0,0,0,0,0,0,0,126,0,0,0,0,0,0,0
    dc.b    0,0,0,0,0,0,0,0,0,0,0,24,24,0,0,0,0,0,0,0,2,6,12,24,48,96,192,128,0,0,0,0
    dc.b    0,0,0,0,124,198,206,222,246,230,198,198,124,0,0,0,0,0,0,0,48,112,240,48,48,48,48,48,252,0,0,0
    dc.b    0,0,0,0,124,198,6,12,24,48,96,198,254,0,0,0,0,0,0,0,124,198,6,6,60,6,6,198,124,0,0,0
    dc.b    0,0,0,0,12,28,60,108,204,254,12,12,30,0,0,0,0,0,0,0,254,192,192,192,252,6,6,198,124,0,0,0
    dc.b    0,0,0,0,56,96,192,192,252,198,198,198,124,0,0,0,0,0,0,0,254,198,134,12,24,24,24,24,24,0,0,0
    dc.b    0,0,0,0,124,198,198,198,124,198,198,198,124,0,0,0,0,0,0,0,124,198,198,198,126,6,6,12,120,0,0,0
    dc.b    0,0,0,0,0,24,24,0,0,0,24,24,0,0,0,0,0,0,0,0,0,24,24,0,0,0,24,24,48,0,0,0
    dc.b    0,0,0,0,6,12,24,48,96,48,24,12,6,0,0,0,0,0,0,0,0,0,126,0,0,0,126,0,0,0,0,0
    dc.b    0,0,0,0,96,48,24,12,6,12,24,48,96,0,0,0,0,0,0,0,124,198,198,12,24,24,0,24,24,0,0,0
    dc.b    0,0,56,124,230,194,218,214,214,220,192,226,126,60,0,0,0,0,0,0,16,56,108,198,198,254,198,198,198,0,0,0
    dc.b    0,0,0,0,252,102,102,102,124,102,102,102,252,0,0,0,0,0,0,0,60,102,194,192,192,192,194,102,60,0,0,0
    dc.b    0,0,0,0,248,108,102,102,102,102,102,108,248,0,0,0,0,0,0,0,254,102,98,104,120,104,98,102,254,0,0,0
    dc.b    0,0,0,0,254,102,98,104,120,104,96,96,240,0,0,0,0,0,0,0,60,102,194,192,192,222,198,102,58,0,0,0
    dc.b    0,0,0,0,198,198,198,198,254,198,198,198,198,0,0,0,0,0,0,0,60,24,24,24,24,24,24,24,60,0,0,0
    dc.b    0,0,0,0,30,12,12,12,12,12,204,204,120,0,0,0,0,0,0,0,230,102,108,108,120,108,108,102,230,0,0,0
    dc.b    0,0,0,0,240,96,96,96,96,96,98,102,254,0,0,0,0,0,0,0,198,238,254,254,214,198,198,198,198,0,0,0
    dc.b    0,0,0,0,198,230,246,222,206,198,198,198,198,0,0,0,0,0,0,0,56,108,198,198,198,198,198,108,56,0,0,0
    dc.b    0,0,0,0,252,102,102,102,124,96,96,96,240,0,0,0,0,0,0,0,56,108,198,198,198,214,222,124,12,14,0,0
    dc.b    0,0,0,0,252,102,102,102,124,108,102,102,230,0,0,0,0,0,0,0,124,198,198,96,56,12,198,198,124,0,0,0
    dc.b    0,0,0,0,126,126,90,24,24,24,24,24,60,0,0,0,0,0,0,0,198,198,198,198,198,198,198,198,124,0,0,0
    dc.b    0,0,0,0,198,198,198,198,198,198,108,56,16,0,0,0,0,0,0,0,198,198,198,198,214,214,254,124,108,0,0,0
    dc.b    0,0,0,0,198,198,108,56,56,56,108,198,198,0,0,0,0,0,0,0,102,102,102,102,60,24,24,24,60,0,0,0
    dc.b    0,0,0,0,254,198,140,24,48,96,194,198,254,0,0,0,0,0,0,0,60,60,48,48,48,48,48,60,60,0,0,0
    dc.b    0,0,0,0,128,192,224,112,56,28,14,6,2,0,0,0,0,0,0,0,60,60,12,12,12,12,12,60,60,0,0,0
    dc.b    0,0,16,56,108,198,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,254,0
    dc.b    0,0,0,48,48,24,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,120,12,124,204,204,118,0,0,0
    dc.b    0,0,0,0,224,96,96,124,102,102,102,102,124,0,0,0,0,0,0,0,0,0,0,124,198,192,192,198,124,0,0,0
    dc.b    0,0,0,0,28,12,12,124,204,204,204,204,118,0,0,0,0,0,0,0,0,0,0,124,198,254,192,198,124,0,0,0
    dc.b    0,0,0,0,28,54,50,48,124,48,48,48,120,0,0,0,0,0,0,0,0,0,0,118,204,204,204,124,12,204,120,0
    dc.b    0,0,0,0,224,96,96,108,118,102,102,102,230,0,0,0,0,0,0,0,24,24,0,56,24,24,24,24,60,0,0,0
    dc.b    0,0,0,0,0,12,12,0,12,12,12,12,204,204,120,0,0,0,0,0,224,96,96,102,108,120,108,102,230,0,0,0
    dc.b    0,0,0,0,56,24,24,24,24,24,24,24,60,0,0,0,0,0,0,0,0,0,0,236,254,214,214,214,214,0,0,0
    dc.b    0,0,0,0,0,0,0,220,102,102,102,102,102,0,0,0,0,0,0,0,0,0,0,124,198,198,198,198,124,0,0,0
    dc.b    0,0,0,0,0,0,0,220,102,102,102,124,96,96,240,0,0,0,0,0,0,0,0,118,204,204,204,124,12,12,30,0
    dc.b    0,0,0,0,0,0,0,220,118,102,96,96,240,0,0,0,0,0,0,0,0,0,0,124,198,112,12,198,124,0,0,0
    dc.b    0,0,0,0,16,48,48,252,48,48,48,54,28,0,0,0,0,0,0,0,0,0,0,204,204,204,204,204,118,0,0,0
    dc.b    0,0,0,0,0,0,0,102,102,102,102,60,24,0,0,0,0,0,0,0,0,0,0,198,198,214,214,254,108,0,0,0
    dc.b    0,0,0,0,0,0,0,198,108,56,56,108,198,0,0,0,0,0,0,0,0,0,0,198,198,198,198,126,6,12,120,0
    dc.b    0,0,0,0,0,0,0,254,204,24,48,102,254,0,0,0,0,0,0,0,14,24,24,24,112,24,24,24,14,0,0,0
    dc.b    0,0,0,0,24,24,24,24,0,24,24,24,24,0,0,0,0,0,0,0,112,24,24,24,14,24,24,24,112,0,0,0
    dc.b    0,0,0,0,118,220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,24,24,60,36,102,66,195,255,0,0,0
    dc.b    0,0,0,0,60,102,194,192,192,194,102,60,24,24,48,0,0,0,0,0,204,204,0,204,204,204,204,204,118,0,0,0
    dc.b    0,0,0,12,24,48,0,124,198,254,192,198,124,0,0,0,0,0,0,16,56,108,0,120,12,124,204,204,118,0,0,0
    dc.b    0,0,0,0,204,204,0,120,12,124,204,204,118,0,0,0,0,0,0,96,48,24,0,120,12,124,204,204,118,0,0,0
    dc.b    0,0,0,56,108,56,0,120,12,124,204,204,118,0,0,0,0,0,0,0,0,0,60,102,96,102,60,12,6,60,0,0
    dc.b    0,0,0,16,56,108,0,124,198,254,192,198,124,0,0,0,0,0,0,0,204,204,0,124,198,254,192,198,124,0,0,0
    dc.b    0,0,0,96,48,24,0,124,198,254,192,198,124,0,0,0,0,0,0,0,102,102,0,56,24,24,24,24,60,0,0,0
    dc.b    0,0,0,24,60,102,0,56,24,24,24,24,60,0,0,0,0,0,0,96,48,24,0,56,24,24,24,24,60,0,0,0
    dc.b    0,0,0,198,198,16,56,108,198,198,254,198,198,0,0,0,0,0,56,108,56,0,56,108,198,198,254,198,198,0,0,0
    dc.b    0,0,12,24,48,0,254,102,96,124,96,102,254,0,0,0,0,0,0,0,0,0,124,182,54,124,216,216,110,0,0,0
    dc.b    0,0,0,0,62,120,216,216,254,216,216,216,222,0,0,0,0,0,0,16,56,108,0,124,198,198,198,198,124,0,0,0
    dc.b    0,0,0,0,198,198,0,124,198,198,198,198,124,0,0,0,0,0,0,96,48,24,0,124,198,198,198,198,124,0,0,0
    dc.b    0,0,0,48,120,204,0,204,204,204,204,204,118,0,0,0,0,0,0,96,48,24,0,204,204,204,204,204,118,0,0,0
    dc.b    0,0,0,0,198,198,0,198,198,198,198,126,6,12,120,0,0,0,0,198,198,56,108,198,198,198,198,108,56,0,0,0
    dc.b    0,0,0,198,198,0,198,198,198,198,198,198,124,0,0,0,0,0,0,24,24,60,102,96,96,102,60,24,24,0,0,0
    dc.b    0,0,0,56,108,100,96,240,96,96,96,230,252,0,0,0,0,0,0,0,102,102,60,24,24,126,24,24,24,0,0,0
    dc.b    0,0,0,0,0,124,198,198,252,198,198,252,192,192,64,0,0,0,0,14,27,24,24,24,126,24,24,24,24,216,112,0
    dc.b    0,0,0,24,48,96,0,120,12,124,204,204,118,0,0,0,0,0,0,12,24,48,0,56,24,24,24,24,60,0,0,0
    dc.b    0,0,0,24,48,96,0,124,198,198,198,198,124,0,0,0,0,0,0,24,48,96,0,204,204,204,204,204,118,0,0,0
    dc.b    0,0,100,252,152,0,0,220,102,102,102,102,102,0,0,0,0,0,118,220,0,198,230,246,254,222,206,198,198,0,0,0
    dc.b    0,0,0,16,56,108,0,120,12,124,204,204,118,0,254,0,0,0,0,0,0,0,0,124,198,198,198,198,124,0,254,0
    dc.b    0,0,0,0,48,48,0,48,48,96,198,198,124,0,0,0,0,0,0,0,0,0,0,0,126,96,96,96,0,0,0,0
    dc.b    0,0,0,0,0,0,0,0,126,6,6,6,0,0,0,0,0,0,0,192,192,198,204,216,48,96,220,134,12,24,62,0
    dc.b    0,0,0,192,192,198,204,216,48,102,206,154,62,6,6,0,0,0,0,0,24,24,0,24,24,60,60,60,24,0,0,0
    dc.b    0,0,0,0,0,0,54,108,216,108,54,0,0,0,0,0,0,0,0,0,0,0,216,108,54,108,216,0,0,0,0,0
    dc.b    0,0,100,252,152,0,0,120,12,124,204,204,118,0,0,0,0,0,100,252,152,0,0,124,198,198,198,198,124,0,0,0
    dc.b    0,1,61,126,70,70,74,74,82,82,98,98,126,188,128,0,0,0,0,0,1,61,70,70,78,90,114,98,98,188,128,0
    dc.b    0,0,0,0,0,126,255,147,147,158,144,144,255,127,0,0,0,0,124,252,144,144,156,156,144,144,144,144,252,124,0,0
    dc.b    96,48,24,0,0,16,56,108,198,198,254,198,198,198,0,0,0,100,244,152,0,16,56,108,198,198,254,198,198,198,0,0
    dc.b    0,100,244,152,0,56,108,198,198,198,198,198,108,56,0,0,0,102,102,0,0,0,0,0,0,0,0,0,0,0,0,0
    dc.b    0,6,12,24,0,0,0,0,0,0,0,0,0,0,0,0,0,16,124,16,16,16,16,16,0,0,0,0,0,0,0,0
    dc.b    0,0,122,202,202,202,202,202,122,10,10,10,10,10,0,0,0,0,124,198,130,186,162,162,162,186,130,198,124,0,0,0
    dc.b    0,0,124,198,130,186,170,178,186,170,130,198,124,0,0,0,241,91,95,85,81,0,0,0,0,0,0,0,0,0,0,0
    dc.b    0,102,102,0,230,102,102,102,102,102,102,102,246,14,60,56,246,246,102,102,102,102,102,102,102,102,102,246,246,14,124,120
    dc.b    0,0,102,118,118,62,60,60,110,110,102,98,0,0,0,0,0,0,124,124,12,12,12,12,12,12,126,126,0,0,0,0
    dc.b    0,0,30,30,6,6,14,30,54,54,54,54,0,0,0,0,0,0,126,126,12,12,12,12,12,12,12,12,0,0,0,0
    dc.b    0,0,126,126,6,102,102,102,102,102,102,102,0,0,0,0,0,0,56,56,24,24,24,24,24,24,24,24,0,0,0,0
    dc.b    0,0,30,30,4,12,12,12,12,12,12,4,0,0,0,0,0,0,126,126,102,102,102,102,102,102,102,102,0,0,0,0
    dc.b    0,0,110,110,102,102,102,102,102,102,126,126,0,0,0,0,0,0,60,60,12,12,0,0,0,0,0,0,0,0,0,0
    dc.b    0,0,60,62,6,6,6,6,6,6,62,60,0,0,0,0,96,96,126,126,6,6,6,14,28,48,48,48,0,0,0,0
    dc.b    0,0,108,110,62,54,102,102,102,110,110,110,0,0,0,0,0,0,28,28,12,12,12,12,12,12,124,124,0,0,0,0
    dc.b    0,0,254,254,254,198,198,198,198,198,254,124,0,0,0,0,0,0,54,54,54,54,54,54,54,54,126,126,0,0,0,0
    dc.b    0,0,126,126,102,102,118,118,6,126,126,126,0,0,0,0,0,0,110,110,102,54,62,24,28,14,126,126,0,0,0,0
    dc.b    0,0,62,62,62,6,6,54,54,54,54,54,48,48,48,0,0,0,124,126,6,6,6,6,6,6,6,6,0,0,0,0
    dc.b    0,0,214,214,214,214,246,246,198,198,254,254,0,0,0,0,0,0,126,126,102,102,102,102,102,102,230,230,0,0,0,0
    dc.b    0,0,56,56,24,24,24,24,24,24,24,24,24,24,0,0,0,0,126,126,6,6,6,6,6,6,6,6,6,6,0,0
    dc.b    0,0,126,62,54,54,54,54,54,54,62,62,0,0,0,0,0,0,126,126,102,102,118,118,6,6,6,6,6,6,0,0
    dc.b    0,0,110,110,102,118,62,14,6,6,6,6,6,6,0,0,0,0,28,54,50,24,60,102,102,60,24,76,108,56,0,0
    dc.b    0,0,0,0,0,16,16,56,56,108,108,198,198,0,0,0,0,0,0,0,102,247,153,153,239,102,0,0,0,0,0,0
    dc.b    0,0,0,0,0,0,0,118,220,216,216,220,118,0,0,0,0,0,0,0,0,0,124,198,252,198,198,252,192,192,64,0
    dc.b    0,0,0,0,254,198,198,192,192,192,192,192,192,0,0,0,0,0,0,0,0,110,252,124,108,108,108,108,108,0,0,0
    dc.b    0,0,0,0,254,198,96,48,24,48,96,198,254,0,0,0,0,0,0,0,0,0,126,216,216,216,216,216,112,0,0,0
    dc.b    0,0,0,0,0,0,102,102,102,102,124,96,96,192,0,0,0,0,0,0,0,0,118,220,24,24,24,24,24,0,0,0
    dc.b    0,0,0,0,126,24,60,102,102,102,102,60,24,126,0,0,0,0,0,0,56,108,198,198,254,198,198,108,56,0,0,0
    dc.b    0,0,0,0,56,108,198,198,198,108,108,108,238,0,0,0,0,0,0,0,30,48,24,12,62,102,102,102,60,0,0,0
    dc.b    0,0,0,0,0,0,0,126,219,219,126,0,0,0,0,0,0,0,0,0,3,6,126,219,219,243,126,96,192,0,0,0
    dc.b    0,0,0,0,28,48,96,96,124,96,96,48,28,0,0,0,0,0,0,0,0,124,198,198,198,198,198,198,198,0,0,0
    dc.b    0,0,0,0,0,126,0,0,126,0,0,126,0,0,0,0,0,0,0,0,0,24,24,126,24,24,0,0,255,0,0,0
    dc.b    0,0,0,0,48,24,12,6,12,24,48,0,126,0,0,0,0,0,0,0,12,24,48,96,48,24,12,0,126,0,0,0
    dc.b    0,0,0,0,14,27,27,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,216,216,112,0,0,0
    dc.b    0,0,0,0,0,24,24,0,126,0,24,24,0,0,0,0,0,0,0,0,0,0,118,220,0,118,220,0,0,0,0,0
    dc.b    0,0,56,108,68,108,56,0,0,0,0,0,0,0,0,0,0,0,56,124,124,124,56,0,0,0,0,0,0,0,0,0
    dc.b    0,0,0,0,0,0,0,0,24,24,0,0,0,0,0,0,0,0,0,15,12,12,12,12,236,108,60,28,0,0,0,0
    dc.b    0,0,0,216,108,108,108,108,108,0,0,0,0,0,0,0,0,0,0,112,216,48,96,200,248,0,0,0,0,0,0,0
    dc.b    0,0,0,0,0,124,124,124,124,124,124,0,0,0,0,0,254,254,0,0,0,0,0,0,0,0,0,0,0,0,0,0

*-------------------------------------------------------------------------------

FONT_8_8:
    dc.b    6,9,9,6,96,144,144,96,24,36,66,129,231,36,36,60,60,36,36,231,129,66,36,24,24,20,242,129,129,242,20,24
    dc.b    24,40,79,129,129,79,40,24,60,153,195,231,195,153,60,0,255,255,254,252,249,243,231,0,231,195,153,60,153,195,231,0
    dc.b    0,1,2,4,136,80,32,0,124,130,146,146,154,130,130,124,24,36,36,36,126,16,40,16,24,20,18,16,16,112,240,96
    dc.b    240,128,254,144,156,16,16,0,112,128,156,146,124,20,18,0,5,5,5,13,13,25,121,113,160,160,160,176,176,152,158,142
    dc.b    60,66,66,0,66,66,60,0,2,2,2,0,2,2,2,0,60,2,2,60,64,64,60,0,60,2,2,60,2,2,60,0
    dc.b    66,66,66,60,2,2,2,0,60,64,64,60,2,2,60,0,60,64,64,60,66,66,60,0,60,2,2,0,2,2,2,0
    dc.b    60,66,66,60,66,66,60,0,60,66,66,60,2,2,60,0,0,0,60,2,126,66,60,0,120,64,112,64,126,16,14,0
    dc.b    7,8,23,24,24,16,30,23,240,24,236,4,4,4,60,84,17,11,13,6,7,46,57,56,4,40,216,40,208,16,224,0
    dc.b    0,0,0,0,0,0,0,0,16,16,16,16,16,0,16,0,68,68,68,0,0,0,0,0,0,72,252,72,72,252,72,0
    dc.b    8,62,64,60,2,124,8,0,0,66,4,8,16,32,66,0,48,72,80,32,84,72,52,0,16,16,16,0,0,0,0,0
    dc.b    4,8,8,8,8,8,4,0,16,8,8,8,8,8,16,0,0,36,24,126,24,36,0,0,0,16,16,124,16,16,0,0
    dc.b    0,0,0,0,0,16,16,32,0,0,0,124,0,0,0,0,0,0,0,0,0,16,16,0,0,2,4,8,16,32,64,0
    dc.b    56,68,76,84,100,68,56,0,16,48,16,16,16,16,124,0,56,68,4,8,16,32,124,0,124,8,16,8,4,68,56,0
    dc.b    8,24,40,72,124,8,8,0,124,64,120,4,4,68,56,0,56,64,64,120,68,68,56,0,124,4,8,16,32,32,32,0
    dc.b    56,68,68,56,68,68,56,0,56,68,68,60,4,8,48,0,0,16,16,0,16,16,0,0,0,16,16,0,16,16,32,0
    dc.b    4,8,16,32,16,8,4,0,0,0,124,0,0,124,0,0,32,16,8,4,8,16,32,0,56,68,4,8,16,0,16,0
    dc.b    56,68,92,84,92,64,60,0,16,40,68,68,124,68,68,0,120,68,68,120,68,68,120,0,56,68,64,64,64,68,56,0
    dc.b    112,72,68,68,68,72,112,0,124,64,64,120,64,64,124,0,124,64,64,120,64,64,64,0,60,64,64,76,68,68,60,0
    dc.b    68,68,68,124,68,68,68,0,56,16,16,16,16,16,56,0,4,4,4,4,4,68,56,0,68,72,80,96,80,72,68,0
    dc.b    64,64,64,64,64,64,124,0,68,68,108,108,84,84,68,0,68,68,100,84,76,68,68,0,56,68,68,68,68,68,56,0
    dc.b    120,68,68,120,64,64,64,0,56,68,68,68,84,72,52,0,120,68,68,120,80,72,68,0,56,68,64,56,4,68,56,0
    dc.b    124,16,16,16,16,16,16,0,68,68,68,68,68,68,60,0,68,68,68,68,68,40,16,0,68,68,68,68,84,108,68,0
    dc.b    68,68,40,16,40,68,68,0,68,68,68,40,16,16,16,0,124,4,8,16,32,64,124,0,28,16,16,16,16,16,28,0
    dc.b    64,32,16,8,4,2,0,0,56,8,8,8,8,8,56,0,16,40,68,130,0,0,0,0,0,0,0,0,0,0,254,0
    dc.b    0,64,32,16,0,0,0,0,0,0,56,4,60,68,60,0,64,64,120,68,68,68,120,0,0,0,56,64,64,64,56,0
    dc.b    4,4,60,68,68,68,60,0,0,0,56,68,124,64,60,0,12,16,60,16,16,16,16,16,0,0,60,68,68,60,4,120
    dc.b    64,64,120,68,68,68,68,0,16,0,48,16,16,16,56,0,16,0,16,16,16,16,16,96,64,64,68,72,112,72,68,0
    dc.b    48,16,16,16,16,16,56,0,0,0,104,84,84,84,84,0,0,0,120,68,68,68,68,0,0,0,56,68,68,68,56,0
    dc.b    0,0,120,68,68,68,120,64,0,0,60,68,68,68,60,4,0,0,120,68,64,64,64,0,0,0,60,64,56,4,120,0
    dc.b    0,16,124,16,16,16,12,0,0,0,68,68,68,68,60,0,0,0,68,68,68,40,16,0,0,0,68,68,84,108,68,0
    dc.b    0,0,68,40,16,40,68,0,0,0,68,68,68,60,4,120,0,0,124,8,16,32,124,0,12,16,16,32,16,16,12,0
    dc.b    16,16,16,16,16,16,16,16,48,8,8,4,8,8,48,0,0,96,146,12,0,0,0,0,0,16,16,40,40,68,124,0
    dc.b    56,68,64,64,68,56,8,48,68,0,0,68,68,68,60,0,8,16,0,56,124,64,60,0,16,40,0,56,4,124,60,0
    dc.b    68,0,56,4,60,68,60,0,16,8,0,56,4,124,60,0,24,24,0,56,4,124,60,0,0,0,28,32,32,28,8,16
    dc.b    16,40,0,56,124,64,60,0,68,0,56,68,124,64,60,0,32,16,0,56,124,64,60,0,68,0,0,48,16,16,56,0
    dc.b    16,40,0,48,16,16,56,0,32,16,0,48,16,16,56,0,68,0,16,40,68,124,68,0,16,40,16,40,68,124,68,0
    dc.b    8,16,124,64,120,64,124,0,0,0,124,18,126,208,126,0,62,80,144,156,240,144,158,0,16,40,0,56,68,68,56,0
    dc.b    68,0,0,56,68,68,56,0,32,16,0,56,68,68,56,0,16,40,0,68,68,68,60,0,32,16,0,68,68,68,60,0
    dc.b    68,0,68,68,68,60,4,120,68,0,56,68,68,68,56,0,68,0,68,68,68,68,60,0,8,8,28,32,32,28,8,8
    dc.b    24,36,32,120,32,32,124,0,68,68,40,16,124,16,16,0,56,68,68,88,68,68,88,64,14,16,60,16,16,16,32,0
    dc.b    8,16,0,56,4,124,60,0,8,16,0,48,16,16,56,0,8,16,0,56,68,68,56,0,8,16,0,68,68,68,60,0
    dc.b    36,88,0,120,68,68,68,0,36,88,0,100,84,76,68,0,0,56,4,60,68,60,0,124,0,56,68,68,68,56,0,124
    dc.b    0,16,0,16,32,64,68,56,0,0,0,62,32,32,32,0,0,0,0,124,4,4,4,0,66,68,72,20,42,68,136,14
    dc.b    66,68,72,20,44,84,158,4,0,16,0,16,16,16,16,16,18,36,72,144,72,36,18,0,144,72,36,18,36,72,144,0
    dc.b    36,88,0,56,4,124,60,0,36,88,0,56,68,68,56,0,58,68,76,84,84,100,56,64,0,4,56,76,84,100,56,64
    dc.b    0,0,108,146,158,144,110,0,126,144,144,156,144,144,126,0,32,16,0,16,40,68,124,68,36,88,0,16,40,68,124,68
    dc.b    36,88,56,68,68,68,68,56,68,0,0,0,0,0,0,0,8,16,32,0,0,0,0,0,0,16,56,16,16,16,0,0
    dc.b    122,138,138,138,122,10,10,10,60,66,157,161,161,157,66,60,60,66,185,165,185,165,66,60,241,91,85,81,0,0,0,0
    dc.b    34,0,98,34,34,114,2,12,114,34,34,34,34,114,2,12,0,98,18,60,72,70,0,0,0,120,8,8,8,124,0,0
    dc.b    0,60,4,12,20,36,0,0,0,124,8,8,8,8,0,0,0,120,4,68,68,68,0,0,0,24,8,8,8,8,0,0
    dc.b    0,28,8,4,4,4,0,0,0,124,36,36,36,36,0,0,64,76,68,68,68,124,0,0,0,56,8,0,0,0,0,0
    dc.b    0,60,4,4,4,60,0,0,32,60,4,4,4,8,0,0,0,72,52,68,68,76,0,0,0,24,8,8,8,56,0,0
    dc.b    0,62,34,34,34,28,0,0,0,36,36,36,36,124,0,0,0,124,68,116,4,124,0,0,0,76,36,28,8,124,0,0
    dc.b    0,60,4,36,36,36,32,0,0,112,8,8,8,8,0,0,0,84,84,116,68,124,0,0,0,60,36,36,36,100,0,0
    dc.b    0,24,8,8,8,8,8,0,0,60,4,4,4,4,4,0,0,124,36,36,36,60,0,0,0,60,36,52,4,4,4,0
    dc.b    0,44,36,20,12,4,4,0,24,36,16,40,20,8,36,24,0,16,40,68,130,0,0,0,0,102,153,153,102,0,0,0
    dc.b    0,0,98,148,136,148,98,0,24,36,68,88,68,68,120,64,0,126,34,32,32,32,32,112,0,2,60,84,20,20,20,40
    dc.b    254,66,32,16,32,66,254,0,0,30,40,68,68,68,56,0,0,0,72,72,72,72,118,128,0,2,60,72,8,8,8,16
    dc.b    56,16,56,68,68,56,16,56,0,56,68,124,68,68,56,0,0,56,68,68,68,40,68,0,28,32,16,40,68,68,56,0
    dc.b    12,16,56,84,84,56,16,96,0,16,56,84,84,84,56,16,62,64,64,126,64,64,62,0,60,66,66,66,66,66,66,0
    dc.b    0,124,0,124,0,124,0,0,16,16,124,16,16,0,126,0,16,8,4,8,16,0,126,0,8,16,32,16,8,0,126,0
    dc.b    0,12,18,18,16,16,16,16,16,16,16,16,144,144,96,0,0,16,0,124,0,16,0,0,0,50,76,0,50,76,0,0
    dc.b    48,72,48,0,0,0,0,0,48,120,48,0,0,0,0,0,0,0,0,0,24,24,0,0,0,0,15,8,144,80,32,0
    dc.b    56,68,68,68,68,0,0,0,24,36,8,16,60,0,0,0,56,4,24,4,56,0,0,0,254,0,0,0,0,0,0,0

*-------------------------------------------------------------------------------

		.EVEN
KEYS:
KEY_CODE_1: 			DC.B 68
SWITCH_CODE_1:			DC.B 8
KEY_CODE_2: 			DC.B 68
SWITCH_CODE_2:			DC.B 12

MAUS_PARAMETER: 		DC.W 0
				 		DC.W 1
						DC.W 4
				 		DC.W 8
				 		DC.W 64
				 		DC.W 256

PRIORITY:										  ; r/w/p
						DC.W 10 				  ; +  Addition 0
						DC.W 10 				  ; -  Subtraktion 2
						DC.W 15 				  ; *  Mulu 4
						DC.W 15 				  ; /  Divu 6
						DC.W 10 				  ; |  Odern 8
						DC.W 15 				  ; &  Anden 10
						DC.W 15 				  ; ^  Eoren 12
						DC.W 15 				  ; <> Shiften 14
						DC.W 20 				  ; ~  1er Komplement 16
						DC.W 20 				  ; -  2er Komplement 18
						DC.W 15 				  ; %  Modulo
						DC.W 20 				  ; p  Pointer 22
						DC.W 0					  ; (  Klammer 24
						DC.W 0,0,0,0,0			  *

KEY_REPEAT: 			DC.L 3
KEY_DELAY:				DC.L 50
MOUSE_REPEAT:			DC.L 5
MOUSE_DELAY:			DC.L 100
DOPPEL_KLICK:			DC.L 0
PRINTER_TIMEOUT:		DC.L 400
RS232_TIMEOUT:			DC.L 400
MIDI_TIMEOUT:			DC.L 400

INSERT_FLAG:			DC.B -1
						DC.B 0					  ; unused
SYMBOL_FLAG:			DC.B -1

		.EVEN
FONT:					DC.W 4

*-------------------------------------------------------------------------------

CHEAT_MODE:			dc.b	0

FLAGS:
BU_FLAG:			dc.b	-1,	%1				; Buserror
AD_FLAG:			dc.b	-1,	%1				; Adress_error
IL_FLAG:			dc.b	-1,%1				; Illegal
DI_FLAG:			dc.b	0,	%0				; Division
CH_FLAG:			dc.b	0,	%0				; Chk
TV_FLAG:			dc.b	0,	%0				; Trapv/cc
PR_FLAG:			dc.b	-1,	%10001			; Privileg
TR_FLAG:			dc.b	-1,	%1				; Trace
LA_FLAG:			dc.b	0,	%0				; Linea
LF_FLAG:			dc.b	0,	%0				; Linef
CP_FLAG:			dc.b	-1,	%1				; Coprocessor Protocol Viol.
FO_FLAG:			dc.b	-1,	%1				; Format Error
IN_FLAG:			dc.b	-1,	%1				; Uninitialized Interrupt
SI_FLAG:			dc.b	-1,	%1				; Spurious
VB_FLAG:			dc.b	2,	%0				; VBL
NM_FLAG:			dc.b	-1,	%1				; NMI
T0_FLAG:			dc.b	0,	%0				; Trap 0
GE_FLAG:			dc.b	2,	%0				; GEMDOS
VD_FLAG:			dc.b	2,	%0				; VDI
AE_FLAG:			dc.b	2,	%0				; AES
T3_FLAG:			dc.b	0,	%0				; Trap 3
T4_FLAG:			dc.b	0,	%0				; Trap 4
T5_FLAG:			dc.b	0,	%0				; Trap 5
T6_FLAG:			dc.b	0,	%0				; Trap 6
T7_FLAG:			dc.b	0,	%0				; Trap 7
T8_FLAG:			dc.b	0,	%0				; Trap 8
T9_FLAG:			dc.b	0,	%0				; Trap 9
TA_FLAG:			dc.b	0,	%0				; Trap 10
TB_FLAG:			dc.b	0,	%0				; Trap 11
TC_FLAG:			dc.b	0,	%0				; Trap 12
BI_FLAG:			dc.b	2,	%0				; BIOS
XB_FLAG:			dc.b	2,	%0				; XBIOS
TF_FLAG:			dc.b	0,	%0				; Trap 15
C1_FLAG:			dc.b	-2,	%1				; Branch or Set on Unordered Condition
C2_FLAG:			dc.b	-2,	%1				; Inexact result
C3_FLAG:			dc.b	-2,	%1				; Divide by Zero
C4_FLAG:			dc.b	-2,	%1				; Underflow
C5_FLAG:			dc.b	-2,	%1				; Operand Error
C6_FLAG:			dc.b	-2,	%1				; Overflow
C7_FLAG:			dc.b	-2,	%1				; Signaling NAN
PC_FLAG:			dc.b	-2,	%1				; PMMU Configuration
PI_FLAG:			dc.b	0,	%1				; PMMU Illegal
PA_FLAG:			dc.b	0,	%1				; PMMU Access Level
HZ_FLAG:			dc.b	2,	%0				; 200HZ Timer
KB_FLAG:			dc.b	-2,	%0				; Keyboard
RI_FLAG:			dc.b	-1,	%1				; Ring Indicator
ET_FLAG:			dc.b	-1,	%0				; ETV_CRITIC
RE_FLAG:			dc.b	-1,	%10000			; RESET
		.EVEN

ADD1:					DC.W 20
ADD2:					DC.W 20
HISTORY:				DC.L 8000

CACHE_FLAG: 			DC.B 0
HISTORY_FLAG:			DC.B 0
INVERT_FLAG:			DC.B 0
GETREZ_FLAG:			DC.B 0
NEWFONT_FLAG:			DC.B 0
NEWFORMAT_FLAG: 		DC.B 0
NEWSCREEN_FLAG: 		DC.B 0

PARAMETER_ENDE:

******************	B S S  -  S E G M E N T  ***********************************

		.EVEN
DRIVE_0:				DS.B 2
PATH_0: 				DS.B 258

		.EVEN
DRIVE_1:				DS.B 2
PATH_1: 				DS.B 258

		.EVEN
DRIVE_2:				DS.B 2
PATH_2: 				DS.B 258

*-------------------------------------------------------------------------------

		.EVEN
DISK_HANDLE:			DS.W 1

COOKIES:
COOKIE_POINTER_0:		DS.L 1
COOKIE_POINTER_1:		DS.L 1
COOKIE_POINTER_2:		DS.L 1
COOKIE_POINTER_3:		DS.L 1
COOKIE_POINTER_4:		DS.L 1
COOKIE_POINTER_5:		DS.L 1
COOKIE_POINTER_6:		DS.L 1

COOKIE_POINTER_7:		DS.L 1
COOKIE_POINTER_8:		DS.L 1
COOKIE_POINTER_9:		DS.L 1
COOKIE_ANZAHL:			DS.W 1

TRACE_BASEPAGE: 		DS.L 2
ENTER_BASEPAGE: 		DS.L 2
QUIT_BASEPAGE:			DS.L 2
SWITCH1_BASEPAGE:		DS.L 2
SWITCH2_BASEPAGE:		DS.L 2
RESET_BASEPAGE: 		DS.L 2

LENGTH1:				DS.W 1
LENGTH2:				DS.W 1
LENGTH: 				DS.W 1
HIST_KB:				DS.L 1
HIST_NR:				DS.L 1

*-------------------------------------------------------------------------------

CONTROL:				DS.W 5
GLOBAL: 				DS.W 15
GINTIN: 				DS.W 16
GINTOUT:				DS.W 7
ADDRIN: 				DS.L 2
ADDROUT:				DS.L 1

*-------------------------------------------------------------------------------

USE_EXINPUT:			DS.B 1
STAY_RESIDENT:
						DS.B 1
ACC_FLAG:				DS.B 1
PATCH_MODUS:			DS.B 1
PEACEBUG_NUMBER:		DS.B 1
NEW_FORMAT: 			DS.B 1
LOCKED_FLAG:			DS.B 1
WRONG_KENNUNG_1:		DS.B 1
WRONG_KENNUNG_2:		DS.B 1
CHECK_KENNUNG:			DS.B 1

*-------------------------------------------------------------------------------

		.EVEN
INTER_XYWH: 			DS.W 4
INTER_X:				DS.W 1
INTER_Y:				DS.W 1
INTER_W:				DS.W 1
INTER_H:				DS.W 1
INTERSECT:				DS.B 1

*-------------------------------------------------------------------------------

		.EVEN
LOCAL_FLAGS:			DS.W 48

COOKIE_TEMP:			DS.L 1

MESSAGE_BUFFER: 		DS.B 16

BUFFER: 				DS.B 24

						DS.B 1024
USERSTACK:
PROGRAMM_ENDE:			.END
