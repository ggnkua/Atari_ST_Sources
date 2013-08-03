debug	equ		0
*-------------------------------------------------------------------------------
* PEACEBUG, Mainsource
*-------------------------------------------------------------------------------

* OS.S
		.EXPORT		_STACK_OS,CALL_DEBUGGER_2

* COOKIE.S
		.EXPORT		CPU,FPU,VDO,SND,MCH,MSTE,DisassemCPU
		.EXPORT		COOKIE_RECORD,COOKIE_ADRESSE,ProgrammLength,ProgrammStart
		.EXPORT		AES_INSTALLED,RESIDENT_FLAG,INST_FAILED

* EDIT.S
		.EXPORT		X_POSITION,Y_POSITION,FIRST_LINE,ZEILEN_LAENGE,ZEICHEN_ADRESSE

* INTERPRE.S
		.EXPORT		TestBusOn,TestBusOff
		.EXPORT		ZAHLEN_BASIS,PRIORITAETEN,GetRegister

* FRAME.S
		.EXPORT		VEKTOR_OFFSET

* SYMBOL.S
		.EXPORT		SYMBOL_FLAG,FILE_NAME
		.EXPORT		PRG_FLAGS
		.EXPORT		FILE_TEXT,FILE_DATA,FILE_BSS

* CACHE.S
		.EXPORT		CACHE_POINTER_1,CACHE_LAENGE_1
		.EXPORT		CACHE_POINTER_2,CACHE_LAENGE_2
		.EXPORT		CACHE_LENGTH,SAVE_IT,GET_SP,SET_PC
		.EXPORT		OPCODE,PRINT_REGISTER

* VEKTOR.S

		.EXPORT		VEKTOR_ADRESSEN,ROUTINEN_ADRESSEN,FLAGS,CHEAT_MODE,RESET
		.EXPORT		OLD_TEST_BUS,OLD_TEST_ADRESS

* HARDWARE.S
		.EXPORT		USERSWITCH_1,USERSWITCH_2,OWN_PALETTE,BILDSCHIRM_ADRESSE
		.EXPORT		SET_SHIFTMD_ST,SET_SHIFTMD_TT,SET_FALCON_REG
		.EXPORT		SWITCH_REGISTER,SWITCH_PALETTE

* DISASSEM.S
		.EXPORT		ProgrammStart,ProgrammEnde

*-------------------------------------------------------------------------------

		.INCLUDE	'EQU.S'
		.INCLUDE	'MACRO.S'

*-------------------------------------------------------------------------------

		.TEXT
PROGRAMM_ANFANG:bra.s		LetsGo

*-------------------------------------------------------------------------------

				dc.l		KENNUNG
				dc.l		SCREEN_PARAMETER-PROGRAMM_ANFANG+28
				dc.l		PARAMETER-PROGRAMM_ANFANG+28
				dc.l		FLAGS-PROGRAMM_ANFANG+28
				dc.l		FONT_16_8-PROGRAMM_ANFANG+28
				dc.l		FONT_8_8-PROGRAMM_ANFANG+28
				dc.l		RELOC_TABELLE-PROGRAMM_ANFANG+28

TEXT_Length:	dc.l		0
DATA_Length:	dc.l		0
BSS_Length:		dc.l		0

*-------------------------------------------------------------------------------

LetsGo:			move.l		a0,ProgrammStart		; Basepage bei Accessories
				seq			_app					; 0=Accessory, -1=Programm
				bne.s		.ACC

				move.l		4(sp),a0				; Basepagepointer
				move.l		a0,ProgrammStart		; Basepagezeiger sichern

				lea			_STACK_INSTALL,sp		; Stack initialisieren

				bsr			CalcProgramInfo
				move.l		ProgrammLength,-(sp)	; LÑnge
				pea			(a0)					; Basepage
				pea			$4a0000					; Dummy + Code
				trap		#1						; MSHRINK 74
				lea			12(sp),sp

.ACC:			lea			_STACK_INSTALL,sp		; Stack initialisieren

				bsr			CalcProgramInfo

				move.l		BssSegStart,a0			; BSS Segment lîschen
				move.l		BssSegLength,d0
				moveq		#0,d1
				lsr.l		#1,d0
				bcc.s		.word
				move.b		d1,(a0)+
.word:			lsr.l		#1,d0
				bcc.s		.long
				move.w		d1,(a0)+
.long:			lsr.l		#1,d0
				bcc.s		.long2
				move.l		d1,(a0)+
.long2:			lsr.l		#1,d0
				bcc.s		.long4
				move.l		d1,(a0)+
				move.l		d1,(a0)+
				bra.s		.long4
.clear:			move.l		d1,(a0)+
				move.l		d1,(a0)+
				move.l		d1,(a0)+
				move.l		d1,(a0)+
.long4:			dbra		d0,.clear

				clr.w		GLOBAL					; AES Versionsnummer
				move.l		#$a0000,CONTROL
				move.l		#$10000,CONTROL+4
				move.l		#AES_PB,d1
				move.w		#$c8,d0
				trap		#2						; APPL_INIT 10
				cmpi.w		#-1,GINTOUT
				beq			INSTALL_FAILED			; Fehler aufgetreten
				tst.w		GLOBAL					; AES Versionsnummer testen
				sne			AES_INSTALLED
				beq.s		.no_APPL_EXIT
				MOVE.L		#$130000,CONTROL
				MOVE.L		#$10000,CONTROL+4
				CLR.W		CONTROL+8
				MOVE.L		#AES_PB,D1
				MOVE.W		#$C8,D0
				TRAP		#2						; APPL_EXIT 19
				bra.s		.no_alternate

.no_APPL_EXIT:	bsr			GET_KBSHIFT
				btst		#3,d0
				bne			INSTALL_FAILED			; Alternate gedrÅckt?

.no_alternate:	move.l		ProgrammStart,a0		; Commandline kopieren
				lea			128(a0),a0
				move.l		a0,a3
				lea			COMMAND_DATA,a1
				moveq		#126,d0
				move.b		(a0)+,COMMAND_LENGTH
COPY_COMMAND:	move.b		(a0)+,(a1)+
				dbeq		d0,COPY_COMMAND

				pea			FSETDTA
				move.w		#38,-(sp)
				trap		#14						; SUPEXEC 38 ---> FSETDTA
				addq.w		#6,sp

				pea			DGETDRV
				move.w		#38,-(SP)
				trap		#14						; SUPEXEC 38 ---> DGETDRV
				addq.w		#6,sp

				lea			PATH,a0					; Bootpfad bestimmen
				move.b		#'\',(a0)+
				move.b		#'A',(a0)+
				move.b		#'U',(a0)+
				move.b		#'T',(a0)+
				move.b		#'O',(a0)+
				TST.B		AES_INSTALLED
				BEQ.S		AUTO_ORDNER
				PEA			DGETPATH
				MOVE.W		#38,-(SP)
				TRAP		#14						; SUPEXEC 38 ---> DGETPATH
				ADDQ.W		#6,SP
AUTO_ORDNER:	LEA			DRIVE,A0
				LEA			DRIVE_BOOT,A1
				MOVE.W		#255,D0
COPY_PATH:		MOVE.B		(A0)+,(A1)+
				DBRA		D0,COPY_PATH

				clr.w		-(sp)					; Mxalloc vorhanden?
				pea			-1.w
				move.w		#68,-(sp)
				trap		#1
				addq.w		#8,sp
				cmp.l		#-32,d0					; Aufruf vorhanden?
				sne			MXALLOC_FLAG

				MOVE.W		#48,-(SP)				; Gemdosversion ermitteln
				TRAP		#1
				ADDQ.W		#2,SP
				MOVEQ		#0,D3
				MOVE.W		D0,D3
				LSR.W		#8,D3
				LEA			GEMDOS_VERSION+20,A2
				MOVEQ		#1,D2
				BSR			PRINT_HEX
				MOVE.B		#'.',-3(A2)
				MOVE.B		D0,D3
				LEA			GEMDOS_VERSION+17,A2
				BSR			PRINT_HEX
				MOVE.B		#32,-3(A2)

				LINK		A6,#-16					; METADOS-Version ermitteln
				CLR.L		4(A6)
				PEA			(A6)
				MOVE.W		#48,-(SP)
				TRAP		#14
				ADDQ.W		#6,SP
				MOVE.L		4(A6),D0
				BEQ.S		NO_METADOS
				MOVEA.L		D0,A0
				LEA			METADOS_VERSION_1+18,A1
				MOVEQ		#29,D0
COPY_METADOS:	MOVE.B		(A0)+,(A1)+
				DBEQ		D0,COPY_METADOS
NO_METADOS:		UNLK		A6

				MOVEQ		#-2,D0					; GDOS vorhanden?
				TRAP		#2
				CMP.W		#-2,D0
				SNE			GDOS_INSTALLED

				TST.B		AES_INSTALLED			; Autoordnerversion?
				SEQ			RESIDENT_FLAG
				beq.s		.resident
				BSR			GET_KBSHIFT				; oder Control gedrÅckt?
				BTST		#2,D0
				sne			RESIDENT_FLAG
				bne.s		.resident
				pea			-1.w
				move.l		#$50023,-(sp)
				trap		#13
				addq.w		#8,sp
				movea.l		d0,a0
				cmpi.l		#'TASS',-8(a0)
				seq			RESIDENT_FLAG

.resident:		sf			INST_FAILED				; Debugger installieren
				PEA			INSTALL(PC)
				MOVE.W		#38,-(SP)
				TRAP		#14
				ADDQ.W		#6,SP
				TST.B		INST_FAILED
				BNE.S		INSTALL_FAILED

				PEA			SYMBOL_LADEN_2			; Symboltabelle lesen
				MOVE.W		#38,-(SP)
				TRAP		#14
				ADDQ.W		#6,SP

				TST.B		RESIDENT_FLAG			; resident halten?
				BNE.S		ONLY_INSTALL

				PEA			JUMPIN(PC)				; sonst einspringen
				MOVE.W		#38,-(SP)
				TRAP		#14

ONLY_INSTALL:	PEA			Installed
				MOVE.W		#9,-(SP)
				TRAP		#1						; Message printen
				ADDQ.W		#6,SP

				tst.l		ANZAHL_SYMBOLE_2		; Symbole geladen?
				beq.s		.no_symbol
				pea			SymbolLoaded			; dann Meldung machen
				move.w		#9,-(sp)
				trap		#1
				addq.w		#6,sp

.no_symbol:		clr.w		-(sp)
				move.l		ProgrammLength,-(sp)
				move.w		#49,-(sp)
				trap		#1						; und Programm resident halten

INSTALL_FAILED:	PEA			NotInstalled
				MOVE.W		#9,-(SP)
				TRAP		#1						; Message printen
				ADDQ.W		#6,SP
				clr.w		-(sp)
				trap		#1						; und Programm verlassen

*-------------------------------------------------------------------------------

CalcProgramInfo:movem.l		d0-a6,-(sp)				; Segmentinformationen holen
				lea			PROGRAMM_ANFANG(pc),a0	; und ProgrammlÑnge berechnen
				move.l		#256,d0
				move.l		a0,TextSegStart
				move.l		TEXT_Length(pc),d1
				add.l		d1,d0
				move.l		d1,TextSegLength
				lea			(a0,d1.l),a0
				move.l		a0,DataSegStart
				move.l		DATA_Length(pc),d1
				add.l		d1,d0
				move.l		d1,DataSegLength
				lea			(a0,d1.l),a0
				move.l		a0,BssSegStart
				move.l		BSS_Length(pc),d1
				add.l		d1,d0
				move.l		d1,BssSegLength
				lea			(a0,d1.l),a0
				move.l		d0,ProgrammLength
				move.l		a0,ProgrammEnde
				movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

INSTALL:		bsr			RESET_VECTORS			; Installationsroutine

				pea			$e0001
				trap		#14
				move.l		d0,IOREC_IKBD			; Keyboard Puffer holen
				addq.w		#4,SP

				MOVEA.L		_SYSBASE.w,A0			; KBSHIFT und ACT_PD bestimmen
				CMPI.W		#$102,2(A0)
				BLT.S		ALTES_TOS
				MOVEA.L		40(A0),A1				; ACT_PD
				MOVEA.L		36(A0),A2				; KBSHIFT
				BRA.S		NEUES_TOS
ALTES_TOS:		LEA			$602C.w,A1
				LEA			$E1B.w,A2
				MOVEA.L		8(A0),A0				; OS_BEG
				MOVE.L		28(A0),D0				; LÑndercode
				LSR.W		#1,D0
				CMP.W		#4,D0					; Spanisches TOS?
				BNE.S		NEUES_TOS
				LEA			$873C,A1
NEUES_TOS:		MOVE.L		A1,ACT_PD_ZEIGER
				MOVE.L		A2,KBSHIFT

				jsr			InstallCookie			; ACHTUNG: alle Routinen, die
				TST.B		INST_FAILED				; MALLOC brauchen, dÅrfen erst
				BNE			ERROR_INIT				; ab hier aufgerufen werden

				clr.b		DisassemCPU
				jsr			TestCPU
				move.b		d0,CPU
				bset		d0,DisassemCPU

				jsr			TestFPU
				move.b		d0,FPU
				beq.s		.cont
				bset		#6,DisassemCPU

.cont:			MOVE.W		CACHE_LAENGE_2,D0		; Cache reservieren
				SWAP		D0
				MOVE.W		CACHE_LAENGE_1,D0
				CLR.W		CACHE_LAENGE_1
				CLR.W		CACHE_LAENGE_2
				PEA			$10001
				JSR			CACHE_INIT
				TST.L		(SP)+
				BEQ.S		ERROR_INIT
				MOVE.L		D0,-(SP)
				JSR			CACHE_INIT
				TST.L		(SP)+
				BEQ.S		ERROR_INIT

				MOVE.L		HISTORY_LENGTH,-(SP)	; History reservieren
				BSR			NEW_HISTORY
				TST.L		(SP)+
				BEQ.S		ERROR_INIT

				BSR			GET_PARAMETER			; Screen installieren
				CMPI.W		#MENUE_LENGTH,ZEILEN_LAENGE
				BHI.S		ERROR_INIT
				MOVE.W		#-1,-(SP)
				BSR			NEW_SCREEN
				TST.W		(SP)+
				BNE.S		KLEINER_FONT
ERROR_INIT:		MOVE.L		COOKIE_ADRESSE,D0
				BEQ.S		NO_COOKIE
				MOVEA.L		D0,A0
				MOVE.L		#'fail',(A0)+
				CLR.L		(A0)
NO_COOKIE:		st			INST_FAILED
				RTS
KLEINER_FONT:	BSR			NEW_FORMAT
				BSR			PRINT_SCREEN
				BSR			PRINT_MENU
				CMPI.W		#3,FONT_FLAG
				BEQ.S		FONT_IS_OK
				CMPI.W		#16,ZEILEN_SCREEN
				BHS.S		FONT_IS_OK
				MOVE.W		#3,FONT_FLAG
				BRA.S		KLEINER_FONT
FONT_IS_OK:		CLR.W		X_POSITION
				MOVE.W		FIRST_LINE,Y_POSITION
				BSR			POSITIONIEREN			; Cursor positionieren

				TST.B		INST_FAILED
				BNE.S		ERROR_INIT

				lea			CHEAT_OFF,a0			; Cheatmode an/ab
				tst.b		CHEAT_MODE
				beq.s		.cheat_off
				lea			CHEAT_ON,a0
.cheat_off:		jsr			(a0)

				BSR			INSTALL_PAGE
				JSR			GET_HARDWARE

*---------------

				LEA			VEKTOR_ADRESSEN,A0		; Vektoren installieren
				LEA			ROUTINEN_ADRESSEN,A1
				LEA			FLAGS,A2
				MOVEQ		#ANZAHL_VEKTOREN-1,D0
VEKTOR_LOOP:	MOVEA.W		(A0)+,A3				; Vektor
				MOVE.W		(A1)+,D7				; Offset
				LEA			ROUTINEN_ADRESSEN,A5
				ADDA.W		D7,A5					; Routine
				TST.B		(A2)
				BEQ.S		CONT_VLOOP
				TST.B		AES_INSTALLED
				BNE.S		AES_LINEF_IO
				CMPA.L		#LINEF,A5
				BEQ.S		CONT_VLOOP
				CMPA.L		#AES,A5
				BEQ.S		CONT_VLOOP
AES_LINEF_IO:	MOVE.L		(A3),-4(A5)
				MOVE.L		A5,(A3)
CONT_VLOOP:		ADDQ.W		#2,A2
				DBRA		D0,VEKTOR_LOOP

*---------------

				MOVE.B		#1,KIND_OF_CLOCK
				CMPI.B		#2,MCH
				BEQ.S		ITS_A_TT_F030
				CMPI.B		#3,MCH
				BEQ.S		ITS_A_TT_F030
				LEA			$FFFFFC25.w,A0
				MOVE.B		(A0),D0
				MOVE.B		#-8,(A0)
				CMPI.B		#-8,(A0)
				SEQ			KIND_OF_CLOCK
				MOVE.B		D0,(A0)
ITS_A_TT_F030:	RTS

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

JUMPIN:			lea			_USER_USP,a0
				MOVE.L		A0,USP					; Userstackpointer
				OR.W		#$2000,SR
				LEA			_USER_ISP,SP			; Interrupsstackpointer
				OR.W		#$3000,SR
				LEA			_USER_MSP,SP			; Masterstackpointer
				JSR			CREATE_FRAME			; Stackframe
				move.l		ProgrammEnde,-(sp)		; PC
				pea			1024.w
				jsr			MALLOC					; 1 KB reservieren
				BEQ.S		MALLOC_FAILED
				move.l		d0,(sp)					; PC
				move.l		d0,-(sp)
				jsr			MFREE

MALLOC_FAILED:	MOVE.W		#$300,-(SP)			; SR
				MOVEM.W		CLEAR_ZERO,D0-D7		; Register lîschen
				MOVEM.W		CLEAR_ZERO,A0-A6
				jsr			GOTO_DEBUGGER
				PrintError	JumpinMessage

				TST.B		COMMAND_LENGTH			; Commandline?
				beq			EDITOR
				LEA			COMMAND_LINE,A3
				MOVE.W		FIRST_LINE,D3
				ADDQ.W		#1,D3
				BSR			MessageRaw_C
				BSR			RETURN
				BRA			EDITOR

*-------------------------------------------------------------------------------
* INSTALL_PAGE: Reserviert Speicher und installiert eine Doppelseite.
* JUMP_BACK: Diese Routine wird aus der Doppelseite angesprungen.
*-------------------------------------------------------------------------------

INSTALL_PAGE:	tst.b		RESIDENT_FLAG
				beq			.ende
				movem.l		d0-a6,-(sp)
				pea			1024.w
				jsr			MXALLOC
				beq.s		.no_page
				add.l		#511,d0
				and.w		#$fe00,d0
				move.l		d0,PAGE_POINTER
				movea.l		d0,a0
				move.l		#$12123456,(a0)+		; Magic
				move.l		d0,(a0)+				; Pointer
				move.w		#$4ef9,(a0)+			; JMP
				move.l		#JUMP_BACK,(a0)+		; Offset
				move.l		#KENNUNG,(a0)+			; Kennung fÅr Pageexec
				move.l		d0,a0					; Pageanfang
				move.w		#255,d1					; 256 Words
				move.w		#$5678,d2				; Checksumme
.loop:			sub.w		(a0)+,d2
				dbra		d1,.loop
				add.w	    d2,-(a0)				; und Checksumme
				jsr			FlushCache
.no_page:		movem.l		(sp)+,d0-a6
.ende:			rts

*-------------------------------------------------------------------------------

JUMP_BACK:		jsr			CREATE_FRAME_PC			; Stackframe anlegen
				move.w		sr,-(sp)
				movem.l		d0-a6,-(sp)

				move.l		PAGE_POINTER,a0			; Doppelseite lîschen
				clr.l		(a0)

				bsr			GET_KBSHIFT				; Shift links gedrÅckt?
				btst		#1,d0
				bne.s		RESET_RESIDENT			; dann resident bleiben

*---------------

TERMINATE:		pea			Terminated				; Peacebug terminieren
				move.w		#9,-(sp)
				trap		#1
				addq.w		#6,sp

GET_OUT:		pea			$b0000					; Umschalttasten auf 0
				trap		#13						; KBSHIFT 11
				addq.w		#4,sp
				movem.l		(sp)+,d0-a6
				rte

*---------------

RESET_RESIDENT:	bsr			InitVariables			; Peacebug resident halten

				moveq		#0,d7					; Speicher reservieren
				movea.l		$516.w,a0
				tst.w		(a0)
				beq.s		.no_hd
				move.l		#1024*10,d7
.no_hd:			move.l		ProgrammLength,-(sp)
				add.l		d7,(sp)
				move.w		#72,-(sp)
				trap		#1
				addq.w		#6,sp
				tst.l		d0
				beq			TERMINATE
				add.l		d7,d0					; d0 = neuer Programmstart

*---------------

				move.l		ProgrammLength,d1
				subq.l		#1,d1					; d1 = ProgrammlÑnge
				movea.l		ProgrammStart,a0		; a0 = alter Programmstart
				movea.l		d0,a1					; a1 = neuer Programmstart

				cmp.l		a0,a1					; gleiche Adresse?
				beq			.same_start

				link		a6,#-(.copy_reloc_2-.copy_reloc_1)
				lea			.copy_reloc_1(PC),a2	; Start Kopierroutine
				movea.l		sp,a3					; Ziel Kopierroutine
				move.w		#.copy_reloc_2-.copy_reloc_1-1,d2	; LÑnge Kopierroutine
.copy_reloc:	move.b		(a2)+,(a3)+
				dbra		d2,.copy_reloc
				jsr			FlushCache
				move.l		ProgrammStart,a5
				jmp			(sp)					; Kopierroutine anspringen

*---------------

.copy_reloc_1:	cmpa.l		a0,a1					; Programm kopieren
				bhi.s		.backward				; Ziel<Quelle
.copy1:			move.b		(a0)+,(a1)+
				dbra		d1,.copy1
				subi.l		#$10000,d1
				bpl.s		.copy1
				bra.s		.copied
.backward:		lea			1(a0,d1.l),a0
				lea			1(a1,d1.l),a1
.copy2:			move.b		-(a0),-(a1)
				dbra		d1,.copy2
				subi.l		#$10000,d1
				bpl.s		.copy2

.copied:		move.l		d0,a0
				lea			256(a0),a0				; neues Textsegment
				lea			256(a5),a5				; altes Textsegment
				move.l		#RELOC_TABELLE,a1		; Reloziertabelle
				suba.l		a5,a1
				adda.l		a0,a1
				move.l		(a1)+,d3				; Offset zum Textsegment
.relocate:		move.l		(a0,d3.l),d4			; zu relozierender Wert
				sub.l		a5,d4					; relozieren
				add.l		a0,d4
				move.l		d4,(a0,d3.l)			; und zurÅckschreiben
				moveq		#0,d4
.long_offset:	move.b		(a1)+,d4				; neuer Offset holen
				beq.s		.ende_reloc
				cmp.b		#1,D4
				bne.s		.not_254
				add.l		#254,d3
				bra.s		.long_offset
.not_254: 		add.l		d4,d3
				bra.s		.relocate
.ende_reloc:	add.l		#.copy_reloc_2,a0
				sub.l		a5,a0
				jmp			(a0)					; and jump back

*---------------

.copy_reloc_2:	unlk		a6
				jsr			FlushCache
				move.l		d0,ProgrammStart		; Programmvariablen neu setzen
				add.l		#256,d0
				move.l		d0,TextSegStart
				add.l		TextSegLength,d0
				move.l		d0,DataSegStart
				add.l		DataSegLength,d0
				move.l		d0,BssSegStart
				add.l		BssSegLength,d0
				move.l		d0,ProgrammEnde

.same_start:	move.l		ProgrammStart,a0
				lea			128(a0),a0
				pea			(a0)
				move.w		#26,-(sp)				; FSETDTA 26
				trap		#1
				addq.w		#6,sp

				bsr			INSTALL					; Debugger installieren

				jsr			SYMBOL_LADEN_2			; Symboltabelle laden

				pea			Alive					; Alive Message
				move.w		#9,-(sp)
				trap		#1
				addq.w		#6,sp

				tst.l		ANZAHL_SYMBOLE_2		; Symbole geladen?
				beq.s		.no_symbol
				pea			SymbolLoaded
				move.w		#9,-(sp)
				trap		#1
				addq.w		#6,sp

.no_symbol:		moveq		#66,d0
				tst.b		CPU
				beq.s		.no_frame
				moveq		#68,d0
.no_frame:		move.l		#$600,(sp,d0.w)		; A0=$600

				bsr			GET_KBSHIFT				; Shift rechts gedrÅckt?
				btst		#0,d0
				beq			GET_OUT					; nein, dann weiter

				movem.l		(sp)+,d0-a6
				bsr			GOTO_DEBUGGER
				move.l		SAVE_PC,FEHLER_ADRESSEN
				PrintError	RE_MESSAGE_2
				bra			EDITOR

*-------------------------------------------------------------------------------

InitVariables:	st			STOP_TRACE
				sf			STOP_TRACE
				sf			DEBUGGER_FLAG
				clr.l		SYMBOL_TABLE_1
				clr.l		SYMBOL_TABLE_2
				clr.l		RES_SYMDRIVER
				sf			DEBUGGER_BILD
				st			RESIDENT
				sf			AES_INSTALLED
				sf			GDOS_INSTALLED
				sf			SCREEN_LOCK
				clr.w		GLOBAL
				sf			SLOW_MODE
				sf			CHANGE_SR
				sf			SHIFTRECHTS_FLAG
				sf			SHIFTLINKS_FLAG
				sf			CAPSLOCK_FLAG
				sf			CONTROL_FLAG
				sf			ALTERNATE_FLAG
				sf			KEY_IGNORE_IKBD
				sf			MAUS_PAKET_IKBD
				sf			MAUSLEFT_FIRST
				sf			MAUSRIGHT_FIRST
				sf			OBSERVE_FLAG
				MOVE.B		#-1,LIST_FLAG
				CLR.W		UEBERTRAG_X
				CLR.W		UEBERTRAG_Y
				CLR.W		MAUS_LEFT
				CLR.W		MAUS_RIGHT
				MOVE.L		#1,TRACE_ZAEHLER
				MOVE.W		#SCREEN,DEVICE
				CLR.L		GO_BREAKPT
				CLR.L		DO_BREAKPT
				CLR.L		GEMDOS_BREAKPT
				CLR.L		GEM_BREAKPT
				CLR.L		BIOS_BREAKPT
				CLR.L		XBIOS_BREAKPT
				sf			BreakFlag
				sf			KEEP_SCREEN
				sf			LOCAL_FLAG
				sf			SUPERVISOR
				sf			TRACE_MODUS_1
				sf			TRACE_MODUS_2
				sf			TRACE_MODUS_3
				sf			TRACE_MODUS_4
				sf			TRACE_MODUS_5
				sf			OPCODE_PC
				sf			OPCODE
				sf			KILLED_MOUSE
				sf			SECOND_LINE
				sf			DEVICE_BUSY
				sf			CURSOR_ZAEHLER
				sf			OBSERVE_FOUND
				sf			ONLY_LEXE
				sf			OnlyWord
				bsr			HELL_OFF
				bsr			INVERS_OFF
				bsr			UNDERLINE_OFF
				bra			FLUSH_KEY

**********************	Editor, Parser	****************************************
*-------------------------------------------------------------------------------
* GET_EVENT: Kehrt bei einem Tastendruck oder einem Mausklick zurÅck.
* <--- Event.b = 0 = Tastendruck, = 1 = rechte Maustaste, = -1 = linke Maustaste
* <--- D0.w = Scancode
* <--- D1.w = Scancode and $7F
* <--- D2.w = Ascii-Code, 0 = Steuertasten, Funktionstasten oder KBSHIFT
*
* ZEICHEN_EINGEBEN: An der aktuellen Cursorposition wird ein Zeichen eingefÅgt,
*					Adressfeld, Editfeld und Register werden unterschieden.
* ---> D2.b = einzufÅgendes Zeichen
*
* CHAR_INSERT: FÅgt an der aktuellen Zeichenposition ein Leerzeichen ein.
* ADRESS_INSERT: Wie Char_insert aber im Adressfeld.
*
* CHAR_DELETE: Lîscht ein Zeichen an der aktuellen Zeichenposition.
* ADRESS_DELETE: Wie Char_delete aber im Adressfeld.
*-------------------------------------------------------------------------------

EDITOR:			bsr			INVERS_ON
				movem.l		POSITION_FTASTE,d0-d2		; Ftaste zeu zeichnen
				bsr			PRINT_AT
				bsr			INVERS_OFF
				move.b		SYMBOL_FLAG,d0
				pea			.input(pc)
				cmp.b		SAVE_SYMBOLFLAG,d0
				beq			PRINT_REGISTER
				bra			PRINT_MENU

.input:			bsr			CURSOR_ON
				bsr			SHOWM
				bsr			GET_EVENT
				bsr			HIDEM
				bsr			CURSOR_OFF

				move.b		OPCODE,-(sp)
				sf			OPCODE
				tst.b		EVENT
				bne.s		.no_key
				bsr.s		KEY_AUSWERTEN				; Keyevents auswerten
				bra.s		.test_opcode
.no_key: 		bsr			MAUS_AUSWERTEN				; Mausevents auswerten
.test_opcode:	tst.b		(sp)+
				beq.s		.input
				tst.b		OPCODE
				bne.s		.input
				bsr			PRINT_REGISTER
				bra.s		.input

*-------------------------------------------------------------------------------

KEY_AUSWERTEN:	CMP.B	    #59,D0
		BLO.S	    NO_FTASTE
		CMP.B	    #68,D0
		BHI.S	    NO_FTASTE
		MOVE.W	    D0,D2		  ; Funktionstasten
		SUB.W	    #58,D2
		TST.W	    UMSCHALT_TASTEN
		BEQ	    FUNKTIONSTASTEN
		ADD.W	    #10,D2
		BRA	    FUNKTIONSTASTEN

NO_FTASTE:	CMP.B	    #2,D0		  ; Alternate|Control <Nummer>
		BLO.S	    KEINE_NUMBER
		CMP.B	    #11,D0
		BHI.S	    KEINE_NUMBER
		TST.B	    CONTROL_FLAG
		BNE	    SET_MARKER
		TST.B	    ALTERNATE_FLAG
		BNE	    CALL_MARKER

KEINE_NUMBER:	TST.B	    D2
		BEQ	    STEUERTASTEN
		TST.B	    CONTROL_FLAG
		BNE	    CONTROL_TASTEN
		TST.B	    ALTERNATE_FLAG
		BEQ	    ZEICHEN_EINGEBEN
				JSR			TEST_NUM
		BMI	    ZEICHEN_EINGEBEN

		MOVEQ	    #0,D4		  ; Ascii eingeben
		SUB.B	    #'0',D3
		MOVE.B	    D3,D4
		CLR.B	    KEY
ASCII_WAIT:	BSR	    CHEAT_KEY
		TST.B	    ALTERNATE_FLAG
		BEQ.S	    ASCII_CONT
		MOVEQ	    #0,D0
		MOVE.B	    KEY,D0
		BLE.S	    ASCII_WAIT
				JSR			TEST_NUM
		BMI.S	    ASCII_CONT
		MULU	    #10,D4
		SUB.W	    #'0',D3
		ADD.W	    D3,D4
		CMP.W	    #255,D4
		BHI.S	    TOO_BIG
		MOVE.W	    D4,D3
		MULU	    #10,D3
		CMP.W	    #255,D3
		BHI.S	    ASCII_CONT
		CLR.B	    KEY
		BRA.S	    ASCII_WAIT
TOO_BIG:	MOVEQ	    #25,D4
ASCII_CONT:	CLR.B	    KEY
		MOVE.W	    D4,D2
		BRA	    ZEICHEN_EINGEBEN

*-------------------------------------------------------------------------------

MAUS_AUSWERTEN:	move.w		MAUS_X,d1
				lsr.w		#3,d1
				sub.w		OFFSET_X,d1		; d1 = X
				move.w		MAUS_Y,d2
				sub.w		OFFSET_Y,d2
				move.w		FONT_FLAG,d0
				lsr.w		d0,d2			; d2 = Y
				tst.b		EVENT
				bmi			LINKE_TASTE

*-------------------------------------------------------------------------------

* rechte Maustaste
* kopiert das Wort an der Mausposition, beachte die Wirkung von Shift!

		MOVE.W	    D2,D3
				lea			PrintPuffer,A3

				JSR			GET_LINEADRESS
		MOVE.W	    ZEILEN_LAENGE,D7
		SUBQ.W	    #1,D7
.loop:			move.b		(a0)+,(a3)+
				dbra		d7,.loop

				lea			PrintPuffer,A3
		LEA	    (A3,D1.w),A3	  ; Zeichenadresse berechnen
		MOVEQ	    #0,D2
		MOVEQ	    #-1,D3
FIRST_SUCHEN:	CLR.W	    -(SP)
		BSR.S	    TEST_CHAR
		BEQ.S	    ENDE_SUCHEN
		SUBQ.W	    #1,A3
		MOVE.W	    D1,D3
		DBRA	    D1,FIRST_SUCHEN
ENDE_SUCHEN:	TST.W	    D3
		BMI.S	    NIX_GEFUNDEN
		MOVE.W	    ZEILEN_LAENGE,D1
		SUB.W	    D3,D1
		SUBQ.W	    #1,D1
		BMI.S	    NIX_GEFUNDEN
		ADDQ.W	    #1,A3
		MOVEQ	    #32,D2
		BSR	    ZEICHEN_EINGEBEN
LAST_AND_COPY:	CLR.W	    -(SP)
		BSR.S	    TEST_CHAR
		BEQ.S	    NIX_GEFUNDEN
		MOVE.B	    (A3)+,D2
		BSR	    ZEICHEN_EINGEBEN
		DBRA	    D1,LAST_AND_COPY
NIX_GEFUNDEN:	RTS

TEST_CHAR:	MOVEM.L     D2/A0/A2,-(SP)
		LEA	    Convert,A2
		TST.W	    16(SP)
		BEQ.S	    NO_CHARS_3
		LEA	    CHARS_3,A0
		BRA.S	    OHNE_BUCHSTABEN
NO_CHARS_3:	LEA	    CHARS_1,A0
		TST.W	    UMSCHALT_TASTEN
		BEQ.S	    OHNE_BUCHSTABEN
		LEA	    CHARS_2,A0
OHNE_BUCHSTABEN:MOVEQ	    #0,D2
		MOVE.B	    (A3),D2
		MOVE.B	    (A2,D2.w),D2
TEST_SCHLEIFE:	TST.B	    (A0)
		BEQ.S	    NO_CHAR
		CMP.B	    (A0)+,D2
		BNE.S	    TEST_SCHLEIFE
		MOVEM.L     (SP)+,D2/A0/A2
		MOVE.L	    (SP),2(SP)
		st	    (SP)
		TST.B	    (SP)+
		RTS
NO_CHAR:	MOVEM.L     (SP)+,D2/A0/A2
		MOVE.L	    (SP),2(SP)
		sf	    (SP)
		TST.B	    (SP)+
		RTS

*-------------------------------------------------------------------------------

* Linke Maustaste
* Cursorpositionieren, Funktionstasten, Cache bedienen (Wechsel, Up, Down)

LINKE_TASTE:	CMPI.B	    #1,MAUS_LEFT
		BEQ.S	    EINZELKLICK
		MOVE.W	    D2,D3		  ; Doppelklick
				JSR			GET_LINEADRESS
		LEA	    (A0,D1.w),A3
		MOVE.W	    #1,-(SP)
		BSR.S	    TEST_CHAR
		BEQ.S	    NO_LISTEN
		MOVEQ	    #-1,D0
SUCH_LEFT:	MOVE.W	    #1,-(SP)
		BSR.S	    TEST_CHAR
		BEQ.S	    LEFT_REACHED
		ADDQ.W	    #1,D0
		SUBQ.W	    #1,A3
		CMPA.L	    A0,A3
		BHS.S	    SUCH_LEFT
LEFT_REACHED:	LEA	    1(A3),A2
		LEA	    1(A0,D1.w),A3
		ADDA.W	    ZEILEN_LAENGE,A0
SUCH_RIGHT:	MOVE.W	    #1,-(SP)
		BSR	    TEST_CHAR
		BEQ.S	    RIGHT_REACHED
		ADDQ.W	    #1,D0
		ADDQ.W	    #1,A3
		CMPA.L	    A0,A3
		BLO.S	    SUCH_RIGHT
RIGHT_REACHED:	TST.W	    D0
		BMI.S	    NO_LISTEN
		jsr		Interpreter
		BNE.S	    NO_LISTEN
		MOVEA.L     D3,A3
		BRA	    ListA3
NO_LISTEN:	RTS

EINZELKLICK:	CMP.W	    FIRST_LINE,D2	  ; Einfachklick
		BHS	    CURSOR_SET
		CMP.W	    #1,D2
		BGT.S	    KEINE_FTASTE
		CMP.W	    #79,D1
		BHI.S	    KEINE_FTASTE
		LSR.W	    #3,D1
		MULU	    #10,D2
		ADD.W	    D1,D2
		ADDQ.W	    #1,D2
		BRA	    FUNKTIONSTASTEN


KEINE_FTASTE:	CMP.W	    #1,D1		  ; Cachepfeile angeklickt?
		BHI.S	    NOCACHE
		TST.W	    D1
		BEQ.S	    ERSTE_ZEILE
		CMP.W	    #2,D2		  ; Cachewechseln
		BNE	    ENDE_MAUS
		NOT.B	    CACHE_FLAG
		TST.B	    SHIFTLINKS_FLAG   ; Bei Shift Inhalt mitkopieren
		BEQ.S	    NICHT_KOPIEREN2
		jsr	    CACHE_PUT		  ; aktueller Inhalt speichern
NICHT_KOPIEREN2:jsr			CACHE_GET		  ; ---> wird kopiert
		BRA	    PRINT_REGISTER
ERSTE_ZEILE:	cmpi.w		#3,d2
				beq.s		.CACHE_UP
				bhi.s		.CACHE_DOWN
				jmp			CACHE_WEG
.CACHE_UP:		jmp			CACHE_UP
.CACHE_DOWN:	jmp			CACHE_DOWN


NOCACHE:		cmpi.w		#2,d2
				bne			D0_BIS_A7

*--------------- Statusregister angeklickt?

				cmpi.w		#63,d1
				blo			KEIN_STATUS
				lea			MenueMaske_1,a0		; Statusregister Bits
				cmpi.b		#'-',(a0,d1.w)
				beq			ENDE_MAUS
				move.w		d1,d0				; d0 = X
				subi.w		#78,d1
				bgt			ENDE_MAUS
				neg.w		D1
				bsr			HELL_OFF
				move.w		SAVE_STATUS,d3
				andi.w		#$f71f,d3
				bchg		d1,d3
				beq.s		.not_hell
				bsr			HELL_ON
.not_hell:		move.w		d3,SAVE_STATUS		; Statusregister schreiben
				move.l		SAVE_A7,d3
				bsr			GET_SP
				jsr			CACHE_PUT			; Cache updaten
				moveq		#2,d1				; d1 = Y
				moveq		#0,d2				; 1 Stelle
				bsr			PRINT_AT			; Statusbit printen
				bsr			HELL_OFF
				bsr			PRINT_SHOW
				cmp.l		SAVE_A7,d3
				bne.s		.cont
				rts
.cont:			bsr			UNDERLINE_ON
				moveq		#71,d0				; X (fÅr PRINT_AT)
				moveq		#4,d1				; Y (fÅr PRINT_AT)
				moveq		#7,d2				; 7 Stellen
				move.l		SAVE_A7,d3			; a7 printen
				movea.l		ZEICHEN_ADRESSE,a2
				move.w		ZEILEN_LAENGE,d4
				adda.w		d4,a2
				adda.w		d4,a2
				adda.w		d4,a2
				lea			71(a2,d4.w),a2
				bsr			PRINTHEX
				bsr			PRINT_AT
				bra			UNDERLINE_OFF

*---------------

KEIN_STATUS:	LEA	    MenueMaske_1,A0
		CMP.W	    #80,D1
		BHS.S	    ENDE_MAUS
		CMPI.B	    #'#',(A0,D1.w)
		BEQ.S	    CURSOR_SET
ENDE_MAUS:	RTS
D0_BIS_A7:	LEA	    MenueMaske_2,A0
		CMP.W	    #80,D1
		BHS.S	    ENDE_MAUS
		CMPI.B	    #'#',(A0,D1.w)
		BNE.S	    ENDE_MAUS


CURSOR_SET:	CMP.W	    X_POSITION,D1	  ; Cursor setzen
		BNE.S	    HAT_GEAENDERT
		CMP.W	    Y_POSITION,D2
		BEQ.S	    ENDE_MAUS

HAT_GEAENDERT:	 MOVE.W      X_POSITION,-(SP)
		MOVE.W	    Y_POSITION,-(SP)
		MOVE.W	    D1,X_POSITION
		MOVE.W	    D2,Y_POSITION
				JSR			TEST_BORDER
		BEQ.S	    OLD_VALUES
				JSR			TEST_SHOW
		BNE.S	    OLD_VALUES
		ADDQ.W	    #4,SP
		BRA	    POSITIONIEREN

OLD_VALUES:	MOVE.W	    (SP)+,Y_POSITION
		MOVE.W	    (SP)+,X_POSITION
		RTS

*-------------------------------------------------------------------------------

ZEICHEN_EINGEBEN:MOVEM.L    d0-a6,-(SP)
				JSR			GET_XY_ADRESS
				JSR			TEST_EDIT
		BPL	    NORMAL_EINGEBEN

		MOVEQ	    #0,D3		  ; Register Editieren
		MOVE.W	    D2,D3
				JSR			TEST_HEX
		BMI	    NICHT_ERLAUBT
		MOVE.B	    D3,(A0)
		MOVEQ	    #0,D0
		MOVE.W	    X_POSITION,D0
		LEA	    DATEN_REGISTER,A0
		CMPI.W	    #3,Y_POSITION
		BEQ.S	    REGISTER_SINDS
		LEA	    ADRESS_REGISTER,A0
		CMPI.W	    #4,Y_POSITION
		BEQ.S	    REGISTER_SINDS

		MOVE.W	    X_POSITION,D0
		LEA	    SAVE_PC,A0
		SUB.W	    #10,D0
		CMPI.W	    #8,D0
		BLS.S	    KEIN_AN_ODER_DN
		LEA	    SAVE_USP,A0
		SUB.W	    #13,D0
		CMPI.W	    #8,D0
		BLS.S	    KEIN_AN_ODER_DN
		LEA	    SAVE_ISP,A0
		SUB.W	    #13,D0
		CMPI.W	    #8,D0
		BLS.S	    KEIN_AN_ODER_DN
		LEA	    SAVE_MSP,A0
		SUB.W	    #13,D0
		BRA.S	    KEIN_AN_ODER_DN

REGISTER_SINDS: SUBQ.W	    #7,D0
		DIVU	    #9,D0
		ADD.W	    D0,D0
		ADD.W	    D0,D0
		ADDA.W	    D0,A0
		SWAP	    D0
KEIN_AN_ODER_DN:SUBQ.W	    #8,D0
		NEG.W	    D0
		ADD.W	    D0,D0
		ADD.W	    D0,D0
		MOVEQ	    #$F,D2
		LSL.L	    D0,D2
		CMP.B	    #'A',D3
		BLO.S	    NO_HEXA
		SUB.W	    #65-48-10,D3
NO_HEXA:	SUB.W	    #48,D3
		LSL.L	    D0,D3
		NOT.L	    D2
		AND.L	    D2,(A0)
		OR.L	    D3,(A0)
		CMPI.W	    #2,Y_POSITION
		BNE.S	    ZEILE_3_4
		BSR	    GET_SP
ZEILE_3_4:	BSR	    PUT_SP
		jsr			CACHE_PUT
		BSR	    SET_PC
		BSR	    PRINT_REGISTER
		BSR	    RIGHT
NICHT_ERLAUBT:	MOVEM.L     (SP)+,d0-a6
		RTS


NORMAL_EINGEBEN:BEQ.S	    ANYTHING

		MOVE.W	    D2,D3
				JSR			TEST_HEX
		BMI.S	    NICHT_ERLAUBT
		MOVE.B	    D3,D2
		TST.B	    INSERT_FLAG
		BEQ.S	    KEIN_INSERT
		BSR	    ADRESS_INSERT
		BRA.S	    KEIN_INSERT
ANYTHING:
		TST.W	    X_POSITION
		BNE.S	    NO_CHECK
		CMP.B	    #'$',D2
		BEQ.S	    NICHT_ERLAUBT
NO_CHECK:	TST.B	    INSERT_FLAG
		BEQ.S	    KEIN_INSERT
		BSR	    CHAR_INSERT
KEIN_INSERT:	MOVE.B	    D2,(A0)
		BSR	    PRINT_Y_LINE
		BSR	    RIGHT
		BRA.S	    NICHT_ERLAUBT

*-------------------------------------------------------------------------------

CONTROL_TASTEN: JSR	    TEST_EDIT
				bpl.s	.cont
				rts
.cont:		ADD.W	    #96,D2
		LEA	    Convert,A0
		MOVE.B	    (A0,D2.w),D2

		CMP.B	    #'A',D2
		BEQ	    CONTROL_A
		CMP.B	    #'C',D2
		BEQ	    CONTROL_C
		CMP.B	    #'D',D2
		BEQ	    CONTROL_D
		CMP.B	    #'H',D2
		BEQ	    CONTROL_H
		CMP.B	    #'L',D2
		BEQ	    CONTROL_L
		CMP.B	    #'Q',D2
		BEQ	    CONTROL_Q
		CMP.B	    #'R',D2
		BEQ	    CONTROL_R
		CMP.B	    #'S',D2
		BEQ	    CONTROL_S
		CMP.B	    #'T',D2
		BEQ	    CONTROL_T
		CMP.B	    #'W',D2
		BEQ	    CONTROL_W
		CMP.B	    #'X',D2
		BEQ	    CONTROL_X

		CMP.B	    #'B',D2
		BEQ.S	    CONTROL_B
		CMP.B	    #'G',D2
		BEQ.S	    CONTROL_G
		CMP.B	    #'P',D2
		BEQ.S	    CONTROL_P
		RTS

*---------------

CONTROL_P:	JSR	    GET_ADRESS_2
		BNE	    NumberError
		MOVE.L	    D0,SAVE_PC
		BSR	    SET_PC
		jsr			CACHE_PUT
		BSR	    ListPC
		BRA	    PRINT_REGISTER

*---------------

CONTROL_G:	JSR	    GET_ADRESS_2
		BNE	    NumberError
		MOVE.L	    D0,SAVE_PC
		BRA	    FTASTE19

*---------------

CONTROL_B:	JSR	    GET_ADRESS_2
		BNE	    NumberError
		BSR	    GET_EVENT
		TST.B	    EVENT
		BNE.S	    CONTROL_B
				JSR			GET_ADRESS_2
		SUB.B	    #'0',D2
		BMI.S	    NO_CONTROL_B
		CMP.B	    #'9'-'0',D2
		BHI.S	    NO_CONTROL_B
		LEA	    BREAKPOINTS,A0
		LSL.W	    #4,D2
		LEA	    (A0,D2.w),A0
		MOVE.L	    D0,(A0)
		MOVE.L	    #1,8(A0)
		MOVE.W	    #2,12(A0)
NO_CONTROL_B:	RTS

*---------------

SET_MARKER:	MOVE.W	    D0,D2		  ; Control Number
				JSR			GET_ADRESS_2
		BNE	    NumberError
		SUBQ.W	    #2,D2
		ADD.W	    D2,D2
		ADD.W	    D2,D2
		LEA	    MARKER,A0
		MOVE.L	    D0,(A0,D2.w)
		RTS

CALL_MARKER:	LEA	    MARKER,A0	  ; Alternate Number
		SUBQ.B	    #2,D0
		LSL.W	    #2,D0
		MOVE.L	    (A0,D0.w),D0
		MOVEA.L     D0,A3
		BRA	    ListA3

*---------------

CONTROL_A:	MOVEQ	    #64,D0
		BRA.S	    GO_FTASTEN
CONTROL_C:	MOVEQ	    #60,D0
		BRA.S	    GO_FTASTEN
CONTROL_D:	MOVEQ	    #66,D0
		BRA.S	    GO_FTASTEN
CONTROL_H:	MOVEQ	    #65,D0
		BRA.S	    GO_FTASTEN
CONTROL_L:	MOVEQ	    #67,D0
		BRA.S	    GO_FTASTEN
CONTROL_Q:	MOVEQ	    #0,D0
		LEA	    NULL_BYTE,A2
		BRA	    _QUIT
CONTROL_R:	MOVEQ	    #61,D0
		BRA.S	    GO_FTASTEN
CONTROL_S:	MOVEQ	    #63,D0
		BRA.S	    GO_FTASTEN
CONTROL_T:	MOVEQ	    #59,D0
		BRA.S	    GO_FTASTEN
CONTROL_W:	MOVEQ	    #68,D0
		BRA.S	    GO_FTASTEN
CONTROL_X:	MOVEQ	    #62,D0
GO_FTASTEN:	MOVE.L	    D0,D1
		BRA	    KEY_AUSWERTEN

*-------------------------------------------------------------------------------

STEUERTASTEN:	CMP.W	    #80,D0
		BEQ	    CURSOR_DOWN
		CMP.W	    #72,D0
		BEQ	    CURSOR_UP
		CMP.W	    #75,D0
		BEQ.S	    CURSOR_LEFT
		CMP.W	    #77,D0
		BEQ	    CURSOR_RIGHT
		CMP.W	    #71,D0
		BEQ	    CLR_HOME		  ; Clr Home
		CMP.W	    #98,D0
		BEQ	    HELP
				JSR			TEST_EDIT		  ; Register noch eingeschrÑnkte
		BMI.S	    NUR_CURSOR		  ; Editiermîglichkeitem
		CMP.W	    #1,D0		  ; Escape
		BEQ	    ESCAPE
		CMP.W	    #14,D0		  ; Backspace
		BEQ	    BACKSPACE
		CMP.W	    #28,D0		  ; Return
		BEQ	    RETURN
		CMP.W	    #114,D0		  ; Enter
		BEQ	    RETURN
		CMP.W	    #82,D0		  ; Insert
		BEQ	    INSERT
		CMP.W	    #83,D0		  ; Delete
		BEQ	    DELETE
		CMP.W	    #97,D0		  ; Undo
		BEQ	    UNDO
NUR_CURSOR:	RTS

*-------------------------------------------------------------------------------

CURSOR_LEFT:	tst.b		ALTERNATE_FLAG			; Cache Up
				beq.s		.cont

				jmp			CACHE_UP

.cont:	TST.W	    UMSCHALT_TASTEN
		BNE	    HISTORY_UP

				JSR			TEST_EDIT
		BMI	    LEFT_REG

		TST.B	    CONTROL_FLAG
		BEQ.S	    ONESTEP_LEFT

				JSR			TEST_EDIT		  ; Control Cursorleft
		BNE.S	    ADRESS_LEFT
				JSR			GET_ADRESS_2
		BEQ.S	    CURSOR_LEFT_ALL
		CLR.W	    X_POSITION
		BRA	    CURSOR_OK
CURSOR_LEFT_ALL:CMPI.W	    #10,X_POSITION
		BEQ.S	    ADRESS_LEFT
		MOVE.W	    #10,X_POSITION
		BRA	    CURSOR_OK
ADRESS_LEFT:	MOVE.W	    #1,X_POSITION
		BRA	    CURSOR_OK

ONESTEP_LEFT:	SUBQ.W	    #1,X_POSITION	  ; Cursorleft
				JSR			TEST_BORDER
		BEQ.S	    CURSOR_LEFT
		TST.W	    X_POSITION
		BPL	    CURSOR_OK
		MOVE.W	    BILD_BREITE,X_POSITION
		SUBQ.W	    #1,X_POSITION
		SUBQ.W	    #1,Y_POSITION
		MOVE.W	    FIRST_LINE,D0
		CMP.W	    Y_POSITION,D0
		BLS	    CURSOR_OK
		ADDQ.W	    #1,Y_POSITION
		BSR	    UP
		JSR			TEST_BORDER
		BEQ.S	    ONESTEP_LEFT
		rts

LEFT_REG:	MOVE.W	    X_POSITION,D0	  ; Cursorleft Register
		LEA	    MenueMaske_1,A0
		CMPI.W	    #2,Y_POSITION
		BEQ.S	    NOCH_NICHTS_2
		LEA	    MenueMaske_2,A0
NOCH_NICHTS_2:	SUBQ.W	    #1,D0
		bgt	    .cont
		rts
.cont:	CMP.W	    #80,D0
		BHS.S	    NOCH_NICHTS_2
		CMPI.B	    #'#',(A0,D0.w)
		BNE.S	    NOCH_NICHTS_2
		MOVE.W	    D0,X_POSITION
		BRA	    CURSOR_OK


HISTORY_UP:	MOVEA.L     HISTORY_READ,A3
		SUBA.W	    ZEILEN_LAENGE,A3
		CMPA.L	    HISTORY_POINTER,A3
		BHS.S	    HIST_UP_OK
		MOVEA.L     HISTORY_POINTER,A0
		ADDA.L	    HISTORY_LENGTH,A0
GET_DOWN:	MOVEA.L     A3,A2
		ADDA.W	    ZEILEN_LAENGE,A3
		CMPA.L	    A0,A3
		BLO.S	    GET_DOWN
		MOVEA.L     A2,A3
HIST_UP_OK:	CMPA.L	    HISTORY_WRITE,A3
		BNE	.cont
		rts

.cont:	MOVEA.L     A3,A0		  ; String leer?
		MOVE.W	    ZEILEN_LAENGE,D0
		SUBQ.W	    #1,D0
TEST_LOOP:	TST.B	    (A0)+
		DBNE	    D0,TEST_LOOP

				bne.s		WriteHistory
				rts


HISTORY_DOWN:	MOVEA.L     HISTORY_READ,A3
		CMPA.L	    HISTORY_WRITE,A3
		BNE.S		.cont
		rts
.cont:	MOVEA.L     HISTORY_READ,A3
		BSR	    NEXT_HISTORY
		CMPA.L	    HISTORY_WRITE,A3

				bne.s		WriteHistory
				rts

WriteHistory:	move.l		a3,HISTORY_READ
				lea			PrintPuffer,a2
				move.w		ZEILEN_LAENGE,d0
				move.b		d0,(a2)+
				bra.s		.entry
.loop:			move.b		(a3)+,(a2)+
.entry:			dbra		d0,.loop
				move.w		Y_POSITION,d3
				lea			PrintPuffer,a3
				bra			RawMessage_P

*-------------------------------------------------------------------------------

CURSOR_RIGHT:	tst.b		ALTERNATE_FLAG			; Cache Down
				beq.s		.cont

				jmp			CACHE_DOWN

.cont:	TST.W	    UMSCHALT_TASTEN
		BNE.S	    HISTORY_DOWN

				JSR			TEST_EDIT
		BMI	    RIGHT_REG

		TST.B	    CONTROL_FLAG
		BEQ.S	    ONESTEP_RIGHT

				JSR			TEST_EDIT		  ; Control Cursorright
		BNE.S	    ADRESS_RIGHT
				JSR			GET_Y_ADRESS
		MOVE.W	    ZEILEN_LAENGE,D0
		ADDA.W	    D0,A0
		SUBQ.W	    #1,D0
END_SEARCH:	TST.B	    -(A0)
		DBNE	    D0,END_SEARCH
		BEQ	    CURSOR_OK
		CMPI.B	    #32,(A0)
		DBNE	    D0,END_SEARCH
		BEQ	    CURSOR_OK
		MOVE.W	    D0,X_POSITION
		ADDQ.W	    #1,D0
		CMP.W	    BILD_BREITE,D0
		BHS	    CURSOR_OK
		MOVE.W	    D0,X_POSITION
		BRA	    CURSOR_OK
ADRESS_RIGHT:	MOVE.W	    #10,X_POSITION
		BRA	    CURSOR_OK

ONESTEP_RIGHT:	ADDQ.W	    #1,X_POSITION	  ; Cursorright
		MOVE.W	    X_POSITION,D0
		CMP.W	    BILD_BREITE,D0
		BHS.S	    TOO_HIGH_X
				JSR			TEST_BORDER
		BEQ	    CURSOR_RIGHT
		BRA.S	    CURSOR_OK
TOO_HIGH_X:	CLR.W	    X_POSITION
		ADDQ.W	    #1,Y_POSITION
		MOVE.W	    ZEILEN_SCREEN,D0
		CMP.W	    Y_POSITION,D0
		BLS.S	    TOO_HIGH_Y
				JSR			TEST_BORDER
		BEQ.S	    ONESTEP_RIGHT
		BRA.S	    CURSOR_OK
TOO_HIGH_Y:	SUBQ.W	    #1,D0
		MOVE.W	    D0,Y_POSITION
		BSR.S	    DOWN
				JSR			TEST_BORDER
		BEQ.S	    ONESTEP_RIGHT
		RTS

RIGHT_REG:	MOVE.W	    X_POSITION,D0	  ; Cursorright Register
		LEA	    MenueMaske_1,A0
		CMPI.W	    #2,Y_POSITION
		BEQ.S	    NOCH_NICHTS
		LEA	    MenueMaske_2,A0
NOCH_NICHTS:	ADDQ.W	    #1,D0
		CMP.W	    BILD_BREITE,D0
		BLO.S		.cont
		rts
.cont:	CMP.W	    #80,D0
		BHS.S	    NOCH_NICHTS
		CMPI.B	    #'#',(A0,D0.w)
		BNE.S	    NOCH_NICHTS
		MOVE.W	    D0,X_POSITION
CURSOR_OK:	BRA	    POSITIONIEREN

*-------------------------------------------------------------------------------

RIGHT_LEFT:	BSR.S	    RIGHT

LEFT:		BSR.S	    SAVE_KBSHIFT
		BSR	    CURSOR_LEFT
		BRA.S	    RESTORE_KBSHIFT

RIGHT:		BSR.S	    SAVE_KBSHIFT
		BSR	    CURSOR_RIGHT
		BRA.S	    RESTORE_KBSHIFT

UP:		BSR.S	    SAVE_KBSHIFT
		BSR	    CURSOR_UP
		BRA.S	    RESTORE_KBSHIFT

DOWN:		BSR.S	    SAVE_KBSHIFT
		BSR.S	    CURSOR_DOWN

		BRA.S	    RESTORE_KBSHIFT


SAVE_KBSHIFT:	MOVE.B	    ALTERNATE_FLAG,SAVE_ALTERNATE
		MOVE.B	    CONTROL_FLAG,SAVE_CONTROL
		MOVE.W	    UMSCHALT_TASTEN,SAVE_UMSCHALT
		CLR.B	    ALTERNATE_FLAG
		CLR.B	    CONTROL_FLAG
		CLR.W	    UMSCHALT_TASTEN
		RTS

RESTORE_KBSHIFT:MOVE.B	    SAVE_ALTERNATE,ALTERNATE_FLAG
		MOVE.B	    SAVE_CONTROL,CONTROL_FLAG
		MOVE.W	    SAVE_UMSCHALT,UMSCHALT_TASTEN
		RTS

*-------------------------------------------------------------------------------

CURSOR_DOWN:	JSR	    TEST_EDIT
		BPL.S	    NO_DOWNREG

CONT_DOWN:	ADDQ.W	    #1,Y_POSITION	  ; Cursor Down Register
				JSR			TEST_SHOW
		BNE.S	    CONT_DOWN
		BRA	    RIGHT_LEFT

NO_DOWNREG:	MOVE.W	    ZEILEN_SCREEN,D1
		SUBQ.W	    #1,D1
		TST.W	    UMSCHALT_TASTEN
		BNE.S	    SUCH_VON_OBEN
		TST.B	    CONTROL_FLAG
		BNE.S	    SEARCH_ADRESS_1

		ADDQ.W	    #1,Y_POSITION	  ; normal Cursor down
		MOVE.W	    ZEILEN_SCREEN,D1
		CMP.W	    Y_POSITION,D1
		BHI	    DOWN_OK
		SUBQ.W	    #1,Y_POSITION
		SUBQ.W	    #1,D1

SEARCH_ADRESS_1:MOVE.W	    D1,D3
				JSR			GET_ADRESS_1	  ; Listadresse suchen
		DBEQ	    D1,SEARCH_ADRESS_1
		BNE.S	    NO_ADRESS_DOWN	  ; Wenn keine da, dann lîschen
		MOVEA.L     D0,A3
		BRA.S	    GO_ON

SUCH_VON_OBEN:	MOVE.W	    FIRST_LINE,D3
		SUBQ.W	    #1,D3
SEARCH_ADRESS:	ADDQ.W	    #1,D3
				JSR			GET_ADRESS_1	  ; Listadresse suchen

		DBEQ	    D1,SEARCH_ADRESS
		BNE.S	    NO_ADRESS_DOWN
		MOVEA.L     D0,A3

GO_ON:		TST.B	    CONTROL_FLAG
		BNE.S	    GO_DOWN_MORE
		TST.W	    UMSCHALT_TASTEN   ; ist Shift gedrÅckt?
		BNE.S	    NUR_2_DOWN

		BSR	    SCROLL_DOWN

GO_DOWN_MORE:	MOVE.B	    LIST_FLAG,D0
		BLE.S	    LS_ZERO

		ADDA.W	    DUMP_BREITE,A3
		SUBQ.B	    #1,D0
		BEQ.S	    DUMPEN
		SUBA.W	    DUMP_BREITE,A3
		ADDA.W	    ASCII_BREITE,A3
		BRA.S	    DUMPEN
LS_ZERO:	JSR	    DisassemLength
		ADDA.W	    D0,A3
DUMPEN: 	TST.B	    CONTROL_FLAG
		BNE.S	    NEW_LIST
		MOVE.W	    Y_POSITION,D3
		BSR	    ListLineRaw
		BRA.S	    DOWN_OK
NUR_2_DOWN:	ADDQ.W	    #2,A3
NEW_LIST:	BSR	    ListA3
		BRA.S	    DOWN_OK

NO_ADRESS_DOWN: ADDQ.W	    #1,Y_POSITION
		MOVE.W	    ZEILEN_SCREEN,D1
		CMP.W	    Y_POSITION,D1
		BHI.S	    DOWN_OK
		SUBQ.W	    #1,Y_POSITION
		BSR	    SCROLL_DOWN_C
DOWN_OK:	BRA	    POSITIONIEREN

*-------------------------------------------------------------------------------

CURSOR_UP:
				JSR			TEST_EDIT
		BPL.S	    NO_UPREG

CONT_UP_2:	CMPI.W	    #2,Y_POSITION	  ; Cursor Up Register
		BHI.S	    .cont
		RTS
.cont:		SUBQ.W	    #1,Y_POSITION
				JSR			TEST_SHOW
		BNE.S	    CONT_UP_2
		BRA	    RIGHT_LEFT

NO_UPREG:	MOVE.W	    ZEILEN_SCREEN,D1
		SUBQ.W	    #1,D1

		MOVE.W	    FIRST_LINE,D3
		SUBQ.W	    #1,D3
SEARCH_ADRESS_2:ADDQ.W	    #1,D3
				JSR			GET_ADRESS_1	  ; Listadresse suchen
		DBEQ	    D1,SEARCH_ADRESS_2
		BNE.S	    NICHTS_GEFUNDEN

		MOVEA.L     D0,A3

		TST.W	    UMSCHALT_TASTEN
		BNE	    NUR_2_UP
		TST.B	    CONTROL_FLAG
		BNE	    GO_UP_MORE
		BRA.S	    GO_ON_UP

NICHTS_GEFUNDEN:MOVE.W	    Y_POSITION,D3
		CMP.W	    FIRST_LINE,D3
		BHI.S	    NORMAL_CLEAR
CONT_UP_3:	SUBQ.W	    #1,Y_POSITION	  ; Cursor Up to Register
				JSR			TEST_SHOW
		BNE.S	    CONT_UP_3
		BRA	    RIGHT_LEFT
NORMAL_CLEAR:	SUBQ.W	    #1,Y_POSITION
		BNE	    UP_OK

GO_ON_UP:	MOVE.W	    Y_POSITION,D3
		CMP.W	    FIRST_LINE,D3
		BEQ.S	    AUF_GEHTS
		SUBQ.W	    #1,Y_POSITION
		BRA	    UP_OK

AUF_GEHTS:	TST.B	    ALTERNATE_FLAG
		BEQ.S	    NO_ALTERNATE
CONT_UP:	SUBQ.W	    #1,Y_POSITION	  ; Cursor Up to Register
				JSR			TEST_SHOW
		BNE.S	    CONT_UP
		BRA	    RIGHT_LEFT

NO_ALTERNATE:	BSR	    SCROLL_UP

		MOVE.B	    LIST_FLAG,D0
		BLE.S	    LS_ZERO_3
		SUBA.W	    DUMP_BREITE,A3
		SUBQ.B	    #1,D0
		BEQ.S	    DUMPEN_3
		ADDA.W	    DUMP_BREITE,A3
		SUBA.W	    ASCII_BREITE,A3
DUMPEN_3:	MOVE.W	    FIRST_LINE,D3
		BSR	    ListLineRaw
		BRA	    UP_OK

LS_ZERO_3:	BSR	    SearchUp
		BNE.S	    DIS_2

		st			OnlyWord
		BSR.S	    DIS_2		  ; nichts gefunden
		sf			OnlyWord
		RTS
DIS_2:		MOVE.W	    Y_POSITION,D3
		BSR	    ListLineRaw
		BRA.S	    UP_OK

GO_UP_MORE:	MOVE.W	    ZEILEN_SCREEN,D0
		SUB.W	    FIRST_LINE,D0
		MOVE.B	    LIST_FLAG,D1
		BLE.S	    LS_ZERO_2
		SUBQ.B	    #1,D1
		BEQ.S	    DUMPEN_2
		MULU	    ASCII_BREITE,D0
		SUBA.W	    D0,A3
		BSR	    ListA3
		BRA.S	    UP_OK
DUMPEN_2:	MULU	    DUMP_BREITE,D0
		SUBA.W	    D0,A3
		BSR	    ListA3
		BRA.S	    UP_OK
LS_ZERO_2:	SUBA.W	    D0,A3
		SUBA.W	    D0,A3
		AND.W	    #$FFFE,D0
		SUBA.W	    D0,A3
		TST.B	    CONTROL_FLAG
		BNE.S	    NEW_LIST_2
		MOVE.W	    Y_POSITION,D3
		BSR	    ListLineRaw
		BRA.S	    UP_OK
NUR_2_UP:	SUBQ.W	    #2,A3
NEW_LIST_2:	BSR	    ListA3
		BRA.S	    UP_OK

		BSR	    SCROLL_UP_C 	  ; UP lîschen
UP_OK:		BRA	    POSITIONIEREN

*-------------------------------------------------------------------------------

INSERT: 	TST.B	    ALTERNATE_FLAG
		BEQ.S	    NO_CHANGE

		NOT.B	    CACHE_FLAG	  ; Cache Change
		TST.B	    SHIFTLINKS_FLAG
		BEQ.S	    NICHT_KOPIEREN1
		jsr			CACHE_PUT		  ; Cache Change&Copy
NICHT_KOPIEREN1:jsr			CACHE_GET
		BRA	    PRINT_REGISTER

NO_CHANGE:	TST.W	    UMSCHALT_TASTEN
		BNE	    FTASTE18		  ; Shift Insert

		TST.B	    CONTROL_FLAG	  ; EinfÅgen
		BEQ.S	    NORMAL_INSERT
		MOVE.W	    Y_POSITION,D3	  ; Control Insert
		BSR	    PUSH_DOWN
		BSR	    CLEAR_LINE

NORMAL_INSERT:	JSR	    TEST_EDIT
		BEQ.S	    INSERT_NORMAL

		BSR	    ADRESS_INSERT	  ; Adress Insert
		BRA	    PRINT_Y_LINE

INSERT_NORMAL:	BSR	    CHAR_INSERT 	  ; Normal Insert
		BRA	    PRINT_Y_LINE

*-------------------------------------------------------------------------------

DELETE: 	TST.W	    UMSCHALT_TASTEN
		BEQ.S	    NO_SHIFT_DELETE

				JSR			TEST_EDIT
		BNE.S	    ADRESSEN_DELETE
		MOVE.W	    ZEILEN_LAENGE,D0   ; Normal Shift Delete
		SUB.W	    X_POSITION,D0
S_D_LOOP_1:	BSR	    CHAR_DELETE
		DBRA	    D0,S_D_LOOP_1
		BRA.S	    ENDE_DELETE

ADRESSEN_DELETE:MOVEQ	    #7,D0
S_D_LOOP_2:	BSR	    ADRESS_DELETE	  ; Adress Shift Delete
		DBRA	    D0,S_D_LOOP_2
		BRA.S	    ENDE_DELETE

NO_SHIFT_DELETE:TST.B	    CONTROL_FLAG
		BEQ.S	    NORMAL_DELETE

		MOVE.W	    Y_POSITION,D3	  ; Control Delete
		BSR	    PULL_UP
		MOVE.W	    ZEILEN_SCREEN,D3
		SUBQ.W	    #1,D3
		BSR	    CLEAR_LINE

NORMAL_DELETE:	JSR	    TEST_EDIT
		BEQ.S	    DELETE_NORMAL

		BSR	    ADRESS_DELETE	  ; Adress Delete
		BRA.S	    ENDE_DELETE

DELETE_NORMAL:	BSR	    CHAR_DELETE 	  ; Delete Normal
ENDE_DELETE:	BRA	    PRINT_Y_LINE

*-------------------------------------------------------------------------------

BACKSPACE:	MOVE.W	    X_POSITION,-(SP)
		CLR.W	    X_POSITION
				JSR			TEST_BORDER
		BEQ.S	    ADRESSE_DA
		MOVE.W	    (SP)+,X_POSITION
		TST.W	    X_POSITION
		BNE.S	    ADRESSE_WEG
		rts
ADRESSE_DA:	MOVE.W	    (SP)+,X_POSITION
		CMPI.W	    #10,X_POSITION
		BNE.S	.cont
		rts
.cont:	CMPI.W	    #1,X_POSITION
		BNE	    ADRESSE_WEG
		rts

ADRESSE_WEG:	BSR	    LEFT

		TST.B	    INSERT_FLAG
		BNE.S	    INSERTMODUS

				JSR			GET_XY_ADRESS	  ; Backspace All
		MOVE.B	    #32,(A0)		  ; Backspace Normal
				JSR			TEST_EDIT
		BEQ.S	    ZERO_IS_OK
		MOVE.B	    #'0',(A0)		  ; Backspace Adress
ZERO_IS_OK:	BRA.S	    NO_INSERT

INSERTMODUS:	JSR	    TEST_EDIT		  ; Backspace Normal Insert
		BNE.S	    BACK_ADRESS
		BSR	    CHAR_DELETE
NO_INSERT:	BRA	    PRINT_Y_LINE

BACK_ADRESS:	BSR	    ADRESS_DELETE	  ; Backspace Adress Insert
		BRA.S	    NO_INSERT

*-------------------------------------------------------------------------------

ESCAPE:	 		jsr			GET_ADRESS_2		; Zeilenadresse?
				bne.s		.esc_all
				jsr			TEST_EDIT			; Workspace? Addresspace?
				beq.s		.esc_work
				jsr			GET_Y_ADRESS		; Adresse lîschen
				movea.l		a0,a2
				suba.l		a3,a3
				bsr			PRINT_ADRESSE
				bsr			PRINT_Y_LINE
				move.w		#1,X_POSITION
				bra			POSITIONIEREN
.esc_work:		lea			.address,a2			; Workspace lîschen
				movea.l		d0,a3
				bsr			PRINT_ADRESSE
				move.w		Y_POSITION,d3
				lea			.address,a3
				bsr			RawMessageRaw_C
				move.w		#10,X_POSITION
				bra			POSITIONIEREN
.esc_all:		move.w		Y_POSITION,d3		; ganze Zeile lîschen
				bsr			CLEAR_LINE
				clr.w		X_POSITION
				bra			POSITIONIEREN

				MessageC	.address,'$12345678>'

*-------------------------------------------------------------------------------

CLR_HOME:		tst.b		ALTERNATE_FLAG
				beq.s		.cont

				jmp			CACHE_WEG		  ; Cache Reset

.cont:	CLR.W	    X_POSITION
		MOVE.W	    FIRST_LINE,Y_POSITION
		TST.W	    UMSCHALT_TASTEN
		BNE.S	    CLR_NO_BORDER

				JSR			TEST_BORDER
		BNE.S	    CLR_NO_BORDER
		MOVE.W	    #10,X_POSITION

CLR_NO_BORDER:	BSR	    POSITIONIEREN
		TST.W	    UMSCHALT_TASTEN
		bne.s	.cont
			    RTS
.cont:	MOVE.W	    FIRST_LINE,D3
		MOVE.W	    ZEILEN_SCREEN,D0
		SUB.W	    D3,D0
		BRA.S	    CLR_EINSTIEG
HOME_SCHLEIFE:	BSR	    CLEAR_LINE
				ADDQ.W	    #1,D3
CLR_EINSTIEG:	DBRA	    D0,HOME_SCHLEIFE
RTS:			rts

*-------------------------------------------------------------------------------

RETURN:			moveq		#13,d2				; Asciicode 13
				tst.w		UMSCHALT_TASTEN		; Shift Return?
				bne			ZEICHEN_EINGEBEN

				jsr			TrapVektor			; Routine Vektor...

				jsr			GET_Y_ADRESS		; a0 = Zeilenadresse
				lea			PUFFER_INPUT,a1
				move.w		ZEILEN_LAENGE,d0
				subq.w		#1,d0
.copy_1:		move.b		(a0)+,(a1)+
				dbra		d0,.copy_1

				lea			PUFFER_INPUT,a2		; letzter Historyeintrag
				movea.l		HISTORY_LAST,a3		; identisch?
				move.l		a3,d0
				beq.s		.not_last
				move.w		ZEILEN_LAENGE,d0
				subq.w		#1,d0
.compare:		cmpm.b		(a2)+,(a3)+
				dbne		d0,.compare
				beq.s		.no_new_entry

.not_last:		lea			PUFFER_INPUT,a2		; Historyeintrag erzeugen
				movea.l		HISTORY_WRITE,a3
				move.l		a3,HISTORY_LAST
				move.w		ZEILEN_LAENGE,d0
				bra.s		.copy_entry
.copy_2:		move.b		(a2)+,(a3)+
.copy_entry:	dbra		d0,.copy_2
				movea.l		HISTORY_WRITE,a3
				bsr			NEXT_HISTORY
				move.l		a3,HISTORY_WRITE
.no_new_entry:	move.l		HISTORY_WRITE,HISTORY_READ

				lea			PUFFER_INPUT,a2		; a2 = Stringadresse
				move.w		ZEILEN_LAENGE,d0	; d0 = ZeilenlÑnge
				subq.w		#1,d0
				move.w		Y_POSITION,SAVE_Y_POSITION
				move.l		#RTS,BreakRoutine
				bsr			PARSER				; Parser...

*---------------

		.BSS
PUFFER_INPUT:	ds.b		MENUE_LENGTH+2
		.EVEN
SAVE_Y_POSITION:ds.w		1					; Y_POSITION - GLOBAL
SAVE_POSITION:	ds.l		2					; d0/a2 - GLOBAL
		.TEXT

*--------------- Wird auch von der Breakroutine angesprungen

PARSER_RETURN:	move.l		#RTS,BreakRoutine
				tst.w		HANDLE				; File schliessen
				beq.s		.no_FCLOSE
				jsr			FCLOSE
.no_FCLOSE:		tst.b		PRINT_NEW_LINE
				beq			PRINT_REGISTER		; keine neue Zeile printen
				bsr.s		HoldTheLine
				lea			.return,a2			; neue Zeile printen
				movea.l		FIRST_ADRESS,a3
				bsr			PRINT_ADRESSE
				move.w		#10,X_POSITION
				lea			.return,a3
				bsr			RawMessageRawDown_C
				bra			PRINT_REGISTER

				MessageC	.return,'$12345678>'

*-------------------------------------------------------------------------------

* Lîscht den Rest der Zeile und darf auch von Befehlen aufgerufen werden.
HoldTheLine:	movem.l		d0/d3/a0/a2,-(sp)
				movem.l		SAVE_POSITION,d0/a2
				tst.w		d0
				bmi.s		.ende
				move.w		SAVE_Y_POSITION,d3
				cmp.w		FIRST_LINE,d3
				blt.s		.ende
				jsr			GET_LINEADRESS
				suba.l		#PUFFER_INPUT,a2
				lea			(a0,a2.l),a0
.clear:			move.b		#32,(a0)+
				dbra		d0,.clear
				bsr			PRINT_LINE
.ende:			movem.l		(sp)+,d0/d3/a0/a2
				rts

*-------------------------------------------------------------------------------

UNDO:		MOVE.L	    HISTORY_WRITE,HISTORY_READ
		BRA	    HISTORY_UP

*-------------------------------------------------------------------------------

HELP:		TST.W	    UMSCHALT_TASTEN
		BNE.S	    NOT_NORMAL_HELP
		BSR	    ESCAPE
		MOVEQ	    #'h',D2
		BSR	    ZEICHEN_EINGEBEN
		BRA	    RETURN
NOT_NORMAL_HELP:CMPI.W	    #3,FONT_FLAG
		BNE.S	.cont
		RTS
.cont:		MOVE.W	    ZEILEN_SCREEN,D4
		MOVE.W	    D4,D0
		MOVE.W	    FIRST_LINE,D5
		SUB.W	    D5,D0
		SUBQ.W	    #1,D0
SWAP_LOOP_0:	MOVE.W	    ZEILEN_LAENGE,D1
		SUBQ.W	    #1,D1
		MOVE.W	    D4,D3
				JSR			GET_LINEADRESS
		MOVEA.L     A0,A1
		MOVE.W	    D5,D3
				JSR			GET_LINEADRESS
SWAP_LOOP_1:	MOVE.B	    (A0),D2
		MOVE.B	    (A1),(A0)+
		MOVE.B	    D2,(A1)+
		DBRA	    D1,SWAP_LOOP_1
		ADDQ.W	    #1,D4
		ADDQ.W	    #1,D5
		DBRA	    D0,SWAP_LOOP_0
		BRA	    PRINT_SCREEN

*-------------------------------------------------------------------------------

GET_EVENT:		tst.b		CLOCK_PRINT
				beq.s		.no_clock
				sf			CLOCK_PRINT
				bsr			CLOCK

.no_clock:		bsr			CHEAT_KEY
		TST.B	    MAUS_LEFT
		BNE	    LEFT_MAUSKLICK
		TST.B	    MAUS_RIGHT
		BNE	    RIGHT_MAUSKLICK
		TST.B	    OBSERVE_FOUND
		BNE	    OBSERVE_PRINT
		sf	    MAUSLEFT_FIRST
		sf	    MAUSRIGHT_FIRST

		MOVEQ	    #0,D0
		MOVE.B	    KEY,D0
		BEQ.S	    GET_EVENT
		MOVEQ	    #0,D2
		MOVE.B	    ASCII_KEY,D2
		MOVEQ	    #%1111111,D1
		AND.W	    D0,D1
		CMP.W	    D0,D1
		BEQ.S	    KEY_PRESSED
		CLR.B	    LAST_KEY
		BRA.S	    GET_EVENT

*---------------

KEY_PRESSED:	sf	    EVENT
		BSR	    KILL_MOUSE
		CMP.B	    LAST_KEY,D1
		BNE.S	    NO_KEYREPEAT
		MOVE.L	    ZAEHLER_1,D3
		SUB.L	    HZ200_ZAEHLER,D3
		BLT	    GET_EVENT
		MOVE.L	    HZ200_ZAEHLER,D3
		SUB.L	    KEY_REPEAT,D3
		MOVE.L	    D3,ZAEHLER_1
		MOVE.L	    ZAEHLER_2,D3
		SUB.L	    HZ200_ZAEHLER,D3
		BLT	    GET_EVENT
		RTS
NO_KEYREPEAT:	MOVE.L	    HZ200_ZAEHLER,D3
		SUB.L	    KEY_REPEAT,D3
		MOVE.L	    D3,ZAEHLER_1
		MOVE.L	    HZ200_ZAEHLER,D3
		SUB.L	    KEY_DELAY,D3
		MOVE.L	    D3,ZAEHLER_2
		MOVE.B	    D1,LAST_KEY
		RTS

*---------------

RIGHT_MAUSKLICK:MOVE.B	    #1,EVENT
		LEA	    ZAEHLER_5,A0
		LEA	    ZAEHLER_6,A1
		LEA	    MAUSRIGHT_FIRST,A2
		BRA.S	    HANDLE_KLICK
LEFT_MAUSKLICK: st	    EVENT
		LEA	    ZAEHLER_3,A0
		LEA	    ZAEHLER_4,A1
		LEA	    MAUSLEFT_FIRST,A2
HANDLE_KLICK:	TST.B	    (A2)
		BEQ.S	    FIRST_KLICK
		MOVE.L	    HZ200_ZAEHLER,D3
		MOVE.L	    (A0),D2
		CMP.L	    D2,D3
		BGT	    GET_EVENT
		SUB.L	    MOUSE_REPEAT,D2
		MOVE.L	    D2,(A0)
		MOVE.L	    (A1),D2
		CMP.L	    D2,D3
		BGT	    GET_EVENT
		RTS
FIRST_KLICK:	MOVE.L	    HZ200_ZAEHLER,D3
		MOVE.L	    D3,D2
		SUB.L	    MOUSE_REPEAT,D3
		MOVE.L	    D3,(A0)		  ; Repeat starten
		SUB.L	    MOUSE_DELAY,D2
		MOVE.L	    D2,(A1)		  ; Delay starten
		st	    (A2)
		RTS

*---------------

OBSERVE_PRINT:	sf			OBSERVE_FOUND
				lea			OBSERVE_MESSAGE,a3
				move.l		OBSERVE_ADDRESS_CHANGED,FEHLER_ADRESSEN
				move.l		OBSERVE_ADDRESS_WHERE,FEHLER_ADRESSEN+4
				bsr			CURSOR_OFF
				bsr			MessageRawDown_C
				subq.w		#1,Y_POSITION
				bsr			POSITIONIEREN
				bsr			CURSOR_ON
				bra			GET_EVENT

*-------------------------------------------------------------------------------

CHAR_DELETE:	MOVEM.L     d0-a6,-(SP)
				JSR			GET_XY_ADRESS
		ADDQ.W	    #1,A0
		MOVE.W	    ZEILEN_LAENGE,D0
		SUB.W	    X_POSITION,D0
		SUBQ.W	    #2,D0
		BMI.S	    NIX_LOESCHEN
DELETE_LOOP:	MOVE.B	    (A0)+,-2(A0)
		DBRA	    D0,DELETE_LOOP
NIX_LOESCHEN:	 MOVE.B      #32,-1(A0)
		MOVEM.L     (SP)+,d0-a6
		RTS

*-------------------------------------------------------------------------------

ADRESS_DELETE:	MOVEM.L     d0-a6,-(SP)
				JSR			GET_XY_ADRESS
		MOVEQ	    #8,D0
		SUB.W	    X_POSITION,D0
		BRA.S	    DELETE_BEGIN
ADRESSEN_LOOP:	MOVE.B	    1(A0),(A0)+
DELETE_BEGIN:	DBRA	    D0,ADRESSEN_LOOP
				JSR			GET_Y_ADRESS
		MOVE.B	    #'0',8(A0)
		MOVEM.L     (SP)+,d0-a6
		RTS

*-------------------------------------------------------------------------------

CHAR_INSERT:	MOVEM.L     d0-a6,-(SP)
		MOVE.W	    Y_POSITION,D3
		ADDQ.W	    #1,D3
				JSR			GET_LINEADRESS
		SUBQ.W	    #1,A0
		MOVE.W	    ZEILEN_LAENGE,D0
		SUB.W	    X_POSITION,D0
		BRA.S	    INSERT_EINSTIEG
INSERT_LOOP:	MOVE.B	    -(A0),1(A0)
INSERT_EINSTIEG:DBRA	    D0,INSERT_LOOP
		MOVE.B	    #32,1(A0)
		MOVEM.L     (SP)+,d0-a6
		RTS

*-------------------------------------------------------------------------------

ADRESS_INSERT:	MOVEM.L     D0/A0,-(SP)
				JSR			GET_Y_ADRESS
		ADDQ.W	    #8,A0
		MOVEQ	    #8,D0
		SUB.W	    X_POSITION,D0
		BRA.S	    INSERT_BEGIN
ADRESS_LOOP:	MOVE.B	    -(A0),1(A0)
INSERT_BEGIN:	DBRA	    D0,ADRESS_LOOP
		MOVE.B	    #'0',(A0)
		MOVEM.L     (SP)+,D0/A0
		RTS

*-------------------------------------------------------------------------------
* FUNKTIONSTASTEN: wertet die Funktionstasten aus, nur vom Editor aufrufen!
* ---> D2.w = 1-20
*-------------------------------------------------------------------------------

FUNKTIONSTASTEN:jsr			TrapVektor			; Routine Vektor...
				movem.l		d0-a6,-(sp)
				cmpi.w		#20,d2
				bne.s		.not_f19
				moveq		#19,d2
.not_f19:		subq.w		#1,d2
				move.w		d2,d0
				move.w		d2,d3
				lsl.w		#3,d0				; d0 = Ftaste*8=X
				moveq		#0,d1				; d1 = 0 oder 1=Y
				cmpi.w		#10,d2
				blo.s		.F1_10
				subi.w		#80,d0				; X
				moveq		#1,d1				; Y
				bsr			UNDERLINE_ON
.F1_10:			moveq		#7,d2
				movem.l		d0-d2,POSITION_FTASTE
				bsr			PRINT_AT
				bsr			UNDERLINE_OFF
				add.w		d3,d3
				move.w		.table(pc,d3.w),d3
				jsr			.table(pc,d3.w)
				movem.l		POSITION_FTASTE,d0-d2
				bsr			INVERS_ON
				bsr			PRINT_AT
				bsr			INVERS_OFF
				movem.l		(sp)+,d0-a6
				rts

.table:			dc.w		FTASTE1-.table,FTASTE2-.table,FTASTE3-.table,FTASTE4-.table,FTASTE5-.table
				dc.w		FTASTE6-.table,FTASTE7-.table,FTASTE8-.table,FTASTE9-.table,FTASTE10-.table
				dc.w		FTASTE11-.table,FTASTE12-.table,FTASTE13-.table,FTASTE14-.table,FTASTE15-.table
				dc.w		FTASTE16-.table,FTASTE17-.table,FTASTE18-.table,FTASTE19-.table,FTASTE19-.table

*-------------------------------------------------------------------------------

FTASTE1:		bset		#TRACE_ANZAHL,TRACE_MODUS_1
				bra			GOTO_PROGRAM

*-------------------------------------------------------------------------------

FTASTE2:		MOVEA.L		SAVE_PC,A3
				JSR			DisassemLength
				BTST		#7,DisassemblyFlags
				BNE			FTASTE12
				ADDA.W		D0,A3
				MOVE.L		A3,DO_BREAKPT
				JSR			CACHE_NEXT
				BRA			GOTO_PROGRAM

*-------------------------------------------------------------------------------

FTASTE3:	MOVEA.L     SAVE_A7,A0
		LEA	    OLD_TRACERTS,A1
		MOVE.L	    (A0),(A1)+		  ; RÅcksprungadresse
		MOVE.L	    A1,(A0)
		BSET	    #TRACE_RTS,TRACE_MODUS_2
		jsr			CACHE_NEXT
		BRA	    GOTO_PROGRAM

*-------------------------------------------------------------------------------

FTASTE4:		sf			OPCODE_PC			; PC zeigt nicht auf den Befehl
				movea.l		SAVE_PC,a3
				move.w		(a3),d0				; Opcode
				cmpi.w		#$4e76,d0			; TRAPV?
				bne.s		.no_TRAPV
				btst		#1,SAVE_STATUS+1	; v-Bit gesetzt?
				beq.s		FTASTE1				; nein
				move.w		#$1c,VEKTOR_OFFSET
				bra.s		.TRACEN
.no_TRAPV:		andi.w		#$fff0,d0
				cmpi.w		#$4e40,D0			; TRAP 0-15?
				bne.s		.no_TRAP
				moveq		#$f,d0
				and.w		(a3),d0				; Trapnummer
				add.w		d0,d0
				add.w		d0,d0
				addi.w		#$80,d0
				move.w		d0,VEKTOR_OFFSET
				bra.s		.TRACEN
.no_TRAP:		st			OPCODE_PC			; PC zeigt auf den Befehl
				move.w		#$10,VEKTOR_OFFSET
				jsr			DisassemLength
				beq.s		.TRACEN				; Illegaler Opcode
				move.w		(a3),d0
				cmpi.w		#ILLEGAL_OPCODE,d0	; Illegal?
				beq.s		.TRACEN
				move.w		#$28,VEKTOR_OFFSET
				andi.w		#$f000,d0
				cmpi.w		#$a000,d0			; Linea
				bne			FTASTE1
.TRACEN:		suba.l		a0,a0				; Exceptionadresse berechnen
				tst.b		CPU
				beq.s		.MC68000
				dc.w		$4e7a,$8801			; MOVEC VBR,A0
.MC68000:		adda.w		VEKTOR_OFFSET,a0
				move.l		(a0),JUMPTO_EXCEPT
				bset		#TRACE_EXCEPT,TRACE_MODUS_2
				bra			GOTO_PROGRAM

*-------------------------------------------------------------------------------

FTASTE5:	jsr			CACHE_NEXT
		MOVEA.L     SAVE_PC,A3
		JSR	    DisassemLength
		ADD.L	    D0,SAVE_PC
		BSR	    SET_PC
		jsr			CACHE_PUT
		BSR	    PRINT_REGISTER
		BRA	    ListPC

*-------------------------------------------------------------------------------

FTASTE6:	MOVE.B	    #2,LIST_FLAG
		MOVEA.L     SAVE_PC,A3
		BRA	    ListA3

*-------------------------------------------------------------------------------

FTASTE7:	MOVE.B	    #1,LIST_FLAG
		MOVEA.L     SAVE_PC,A3
		BRA	    ListA3

*-------------------------------------------------------------------------------

FTASTE8:	sf	    LIST_FLAG
		MOVEA.L     SAVE_PC,A3
		BRA	    ListA3

*-------------------------------------------------------------------------------

FTASTE9:	st	    LIST_FLAG
		MOVEA.L     SAVE_PC,A3
		BRA	    ListA3

*-------------------------------------------------------------------------------

FTASTE10:		tst.b		DEBUGGER_BILD
				sne			KEEP_SCREEN
				beq.s		.show_it
				jmp			SHOW_PROGRAMM
.show_it:		jmp			SHOW_DEBUGGER

*-------------------------------------------------------------------------------

FTASTE11:		bset		#TRACE_68020,TRACE_MODUS_1
				bra			GOTO_PROGRAM

*-------------------------------------------------------------------------------

FTASTE12:		movea.l		SAVE_PC,a3
				jsr			DisassemLength
				btst		#7,DisassemblyFlags
				beq			FTASTE1
				bset		#TRACE_ONE,TRACE_MODUS_1
				clr.l		OLD_TRACERTS
				jsr			CACHE_NEXT
				bra			GOTO_PROGRAM

*-------------------------------------------------------------------------------

FTASTE13:		movea.l		SAVE_A7,a0
				addq.w		#2,a0
				lea			OLD_TRACERTS,a1
				move.l		(a0),(a1)+			; RÅcksprungadresse
				move.l		a1,(a0)
				bset		#TRACE_RTS,TRACE_MODUS_2
				jsr			CACHE_NEXT
				bra			GOTO_PROGRAM

*-------------------------------------------------------------------------------

FTASTE14:	BSET	    #TRACE_TO_TOS,TRACE_MODUS_2
		MOVE.L	    $84.w,GEMDOS_BREAKPT
		MOVE.L	    $88.w,GEM_BREAKPT
		MOVE.L	    $B4.w,BIOS_BREAKPT
		MOVE.L	    $B8.w,XBIOS_BREAKPT
		MOVE.W	    #4,GEMDOS_BREAKPT+12
		MOVE.W	    #4,GEM_BREAKPT+12
		MOVE.W	    #4,BIOS_BREAKPT+12
		MOVE.W	    #4,XBIOS_BREAKPT+12
		jsr			CACHE_NEXT
		BRA	    GOTO_PROGRAM

*-------------------------------------------------------------------------------

FTASTE15:	JSR	    GET_ADRESS_2
		BNE	    NumberError
		LEA	    BREAKPOINTS,A0
		MOVEQ	    #ANZAHL_BREAKPOINTS-1,D1
FT15_SCHLEIFE1: CMP.L	    (A0),D0
		BEQ.S	    BPT_ENTFERNEN
		LEA	    16(A0),A0
		DBRA	    D1,FT15_SCHLEIFE1
		LEA	    BREAKPOINTS,A0
		MOVEQ	    #ANZAHL_BREAKPOINTS-1,D1
		CLR.L	    FEHLER_ADRESSEN
FT15_SCHLEIFE2: TST.L	    (A0)
		BEQ.S	    BPT_GEFUNDEN
		ADDQ.L	    #1,FEHLER_ADRESSEN
		LEA	    16(A0),A0
		DBRA	    D1,FT15_SCHLEIFE2
		RTS
BPT_GEFUNDEN:	MOVE.L	    D0,(A0)
		MOVE.L	    #1,8(A0)
		MOVE.W	    #2,12(A0)
				lea			BPT_SET_MESSAGE,a3
				bsr			MessageRawDown_C
				subq.w		#1,Y_POSITION
				bra			POSITIONIEREN

BPT_ENTFERNEN:	CLR.L	    (A0)
				lea			BPT_WEG_MESSAGE,a3
				bsr			MessageRawDown_C
				subq.w		#1,Y_POSITION
				bra			POSITIONIEREN

*-------------------------------------------------------------------------------

FTASTE16:		tst.b		SCREEN_LOCK
				beq.s		.cont
				bsr			NOT_AVAILABLE
				subq.w		#1,Y_POSITION
				bra			POSITIONIEREN
.cont:			st			SCREEN_LOCK
		BSR	    CLEAR_SCREEN
		SUBQ.W	    #7,FONT_FLAG
		NEG.W	    FONT_FLAG
		BSR	    ROUTINE_A
		BSR	    PRINT_SCREEN
		MOVE.W	    MAUS_X,D2
		SUB.W	    OFFSET_X,D2
		MOVE.W	    MAUS_Y,D3
		SUB.W	    OFFSET_Y,D3
		CMPI.W	    #3,FONT_FLAG
		BEQ.S	    KLEIN
		ADD.W	    D3,D3
		BRA.S	    GROSS
KLEIN:		LSR.W	    #1,D3
GROSS:		ADD.W	    OFFSET_X,D2
		ADD.W	    OFFSET_Y,D3
		BSR	    SET_MOUSE
		BSR	    POSITIONIEREN
				sf			SCREEN_LOCK
				rts

*-------------------------------------------------------------------------------

FTASTE17:	TST.B	    SYMBOL_FLAG
		BMI.S	    ALL_ON
		SUBQ.B	    #1,SYMBOL_FLAG
		BRA	    PRINT_MENU
ALL_ON: 	MOVE.B	    #1,SYMBOL_FLAG
		BRA	    PRINT_MENU

*-------------------------------------------------------------------------------

FTASTE18:	NOT.B	    INSERT_FLAG
		BRA	    PRINT_MENU

*-------------------------------------------------------------------------------

FTASTE19:		jsr		CACHE_PUT
				jsr		CACHE_NEXT
				BRA		GOTO_PROGRAM

*-------------------------------------------------------------------------------
* PARSER:
* ---> d0.w = LÑnge des Strings (-1)
* ---> a2.l = Zeiger auf den zu analysierenden String
* <--- tst.w D7.w = gefundener Befehl oder -1
* - First_adress.l enthÑlt die Adresse, die derjenigen folgt, die am Schluss
*	geprintet wurde
* - SAVE_POSITION enthÑlt d0/a2, Reststring
*
* PARSER_2: analysiert die Benutzereingaben, es wird kein Routine aufgerufen
* ---> d0.w = LÑnge des Strings (-1)
* ---> a2.l = Zeiger auf den zu analysierenden String
* <--- tst.w D7.w = gefundener Befehl oder -1
* - SAVE_POSITION enthÑlt d0/a2, Reststring
*-------------------------------------------------------------------------------

PARSER:			st			COMMAND_FLAG			; Befehl ausfÅhren
				bsr.s		SEARCH_COMMAND
				move.w		COMMAND_FOUND,d7
				rts

*---------------

PARSER_2:		sf			COMMAND_FLAG			; Befehl nicht ausfÅhren
				bsr.s		SEARCH_COMMAND
				st			COMMAND_FLAG			; wichtig, weil von hier aus
				move.w		COMMAND_FOUND,d7		; nach SEARCH_COMMAND zurÅck-
				rts									; gesprungen wird

*---------------

SEARCH_COMMAND:	movem.l		d0-a6,-(sp)
				move.w		#-1,COMMAND_FOUND		; noch keinen gÅltigen Befehl
				st			PRINT_NEW_LINE			; neue Zeile printen
				move.l		SAVE_PC,FIRST_ADRESS	; Zeilenadresse = PC
				movem.l		d0/a2,SAVE_POSITION

*---------------
				jsr			KillSpace
				bmi			.ende
				jsr			CutSpace
				bmi			.ende
				movem.l		d0/a2,save_D0_A2		; Position sichern

*--------------- Zeilenadresse berechnen
				tst.b		COMMAND_FLAG			; Help ohne Adressuche
				beq.s		.start_PARSER
				cmpi.b		#'$',(a2)
				bne.s		.start_PARSER
				jsr			CalcNumber				; $12345678
				bne.s		.start_PARSER
				move.l		d3,FIRST_ADRESS			; Zeilenadresse
				cmpi.b		#'>',(a2)+				; $12345678>
				bne			.ende
				subq.w		#1,d0
				movem.l		d0/a2,SAVE_POSITION
				jsr			KillSpace
				bmi			.ende
				movem.l		d0/a2,save_D0_A2

*--------------- Befehl suchen und aufrufen
.start_PARSER:	movem.l		save_D0_A2,d0/a2
				lea			Convert,a0
				lea			.PARSER_TABELLE(pc),a1
				moveq		#ANZAHL_BEFEHLE-1,d7
.loop:			bsr.s		.get_char				; d1 = zu parsendes Zeichen
				cmp.b		(a1)+,d1
				bne.s		.next_command
				addq.w		#1,a2
				subq.w		#1,d0
				bmi.s		.found
				tst.b		(a1)
				beq.s		.found
				bsr.s		.get_char
				cmp.b		#'A',d1
				blo.s		.found
				cmp.b		#'Z',d1
				bhi.s		.found
				bra.s		.loop

.next_command:	tst.b		(a1)+
				bne.s		.next_command
				movem.l		save_D0_A2,d0/a2
				dbra		d7,.loop
				bra.s		.ende

.get_char:		moveq		#0,d1
				move.b		(a2),d1
				move.b		(a0,d1.w),d1
				rts

.found:			movem.l		d0/a2,SAVE_POSITION
				jsr			KillSpace
				jsr			CutSpace
				subi.w		#ANZAHL_BEFEHLE-1,d7
				neg.w		d7
				move.w		d7,COMMAND_FOUND
				tst.b		COMMAND_FLAG
				beq.s		.ende
				add.w		d7,d7
				move.w		.PARSER_SPRUNG(pc,d7.w),d7	; jetzt Routine
				jsr			.PARSER_SPRUNG(pc,d7.w)		; anspringen

*---------------

.ende:			tst.b		COMMAND_FLAG			; Parser von Help aufgerufen?
				beq.s		.no_FCLOSE
				move.w		#SCREEN,DEVICE
				tst.w		HANDLE
				beq.s		.no_FCLOSE
				jsr			FCLOSE
.no_FCLOSE:		movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

.PARSER_SPRUNG:	dc.w		_ASCII-.PARSER_SPRUNG,_ASCFIND-.PARSER_SPRUNG,_BREAKPOINTS-.PARSER_SPRUNG,_CALL-.PARSER_SPRUNG,_CD-.PARSER_SPRUNG
				dc.w		_CHECKSUMME-.PARSER_SPRUNG,_CLR-.PARSER_SPRUNG,_COLD-.PARSER_SPRUNG
				dc.w		_COMPARE-.PARSER_SPRUNG,_COOKIE-.PARSER_SPRUNG,_COPY-.PARSER_SPRUNG,_DISASSEMBLE-.PARSER_SPRUNG,_DFREE-.PARSER_SPRUNG
				dc.w		_DIR-.PARSER_SPRUNG,_DO-.PARSER_SPRUNG,_DUMP-.PARSER_SPRUNG
				dc.w		_QUIT-.PARSER_SPRUNG,_FIND-.PARSER_SPRUNG,_FILL-.PARSER_SPRUNG,_FREE-.PARSER_SPRUNG,_GO-.PARSER_SPRUNG,_HELP-.PARSER_SPRUNG,_HUNT-.PARSER_SPRUNG
				dc.w		_INFO-.PARSER_SPRUNG,_LIST-.PARSER_SPRUNG,_LAST-.PARSER_SPRUNG,_LET-.PARSER_SPRUNG,_LEXECUTE-.PARSER_SPRUNG,_LOAD-.PARSER_SPRUNG,_DIR-.PARSER_SPRUNG
				dc.w		_DUMP-.PARSER_SPRUNG,_MKDIR-.PARSER_SPRUNG,_NEWFORMAT-.PARSER_SPRUNG,_OBSERVE-.PARSER_SPRUNG
				dc.w		_PAGE-.PARSER_SPRUNG,_PROGRAMS-.PARSER_SPRUNG,_QUIT-.PARSER_SPRUNG
				dc.w		_READSECTOR-.PARSER_SPRUNG
				dc.w		_REGISTER-.PARSER_SPRUNG,_RESIDENT-.PARSER_SPRUNG,_RMDIR-.PARSER_SPRUNG
				dc.w		_SAVE-.PARSER_SPRUNG,_LET-.PARSER_SPRUNG,_SHOWMEMORY-.PARSER_SPRUNG,_SLOW-.PARSER_SPRUNG
				dc.w		_SWITCH-.PARSER_SPRUNG,_SYMBOL-.PARSER_SPRUNG,_SYSINFO-.PARSER_SPRUNG,_TRACE-.PARSER_SPRUNG,_WARM-.PARSER_SPRUNG
				dc.w		_WRITESECTOR-.PARSER_SPRUNG,_XBRA-.PARSER_SPRUNG,_FRAGEZEICHEN-.PARSER_SPRUNG
				dc.w		_SLASH-.PARSER_SPRUNG,_ASSEMBLER-.PARSER_SPRUNG,_KOMMA-.PARSER_SPRUNG,_KLAMMER-.PARSER_SPRUNG,_DOPPELPUNKT-.PARSER_SPRUNG

*-------------------------------------------------------------------------------

* erlaubt sind:
* als erstes Zeichen: alle Zeichen
* als folgende Zeichen: alle Grossbuchstaben
.PARSER_TABELLE:dc.b		'ASCII',0,'ASCFIND',0,'BREAKPOINTS',0,'CALL',0,'CD',0
				dc.b		'CHECKSUMME',0,'CLR',0,'COLD',0,'COMPARE',0
				dc.b		'COOKIE',0
				dc.b		'COPY',0,'DISASSEMBLE',0,'DFREE',0,'DIRECTORY',0
				dc.b		'DO',0,'DUMP',0,'EXIT',0
				dc.b		'FIND',0,'FILL',0,'FREE',0
				dc.b		'GO',0,'HELP',0,'HUNT',0,'INFO',0
				dc.b		'LIST',0,'LAST',0,'LET',0,'LEXECUTE',0,'LOAD',0
				dc.b		'LS',0,'MEMORY',0
				dc.b		'MKDIRECTORY',0,'NEWFORMAT',0,'OBSERVE',0
				dc.b		'PAGE',0,'PROGRAMS',0,'QUIT',0,'READSECTOR',0
				dc.b		'REGISTER',0,'RESIDENT',0,'RMDIRECTORY',0
				dc.b		'SAVE',0,'SET',0,'SHOWMEMORY',0
				dc.b		'SLOW',0,'SWITCH',0,'SYMBOL',0
				dc.b		'SYSINFO',0
				dc.b		'TRACE',0,'WARM',0,'WRITESECTOR',0,'XBRA',0
				dc.b		'?',0,'/',0,'!',0,',',0,')',0,':',0
		.EVEN

*-------------------------------------------------------------------------------

Umlenkung:		movem.l		d0-a6,-(sp)
				movem.l		d0/a2,SAVE_POSITION

				jsr			KillSpace
				bmi			.ende
				cmpi.b		#'>',(a2)+
				bne			.ende
				subq.w		#1,d0
				jsr			KillSpace
				bmi			.ende

				movem.l		d0/a2,-(sp)
				lea			DEVICE_KENNUNG,a0		; welchen Device?
				lea			Convert,a1
				moveq		#0,d1
				moveq		#3,d2					; midi, prn, aux, con
.search:		movem.l		(sp),d0/a2				; Device suchen
.loop:			tst.b		(a0)
				beq			.found
				move.b		(a2)+,d1
				move.b		(a1,d1.w),d1
				cmp.b		(a0)+,d1
				dbne		d0,.loop
				bne.s		.next
				tst.b		(a0)
				beq.s		.found
.next:			tst.b		(a0)+					; nÑchsten Device suchen
				bne.s		.next
				dbra		d2,.search
				movem.l		(sp)+,d0/a2				; dann halt ein File

				move.w		#-1,DEVICE				; File Create
				cmpi.b		#'>',(a2)
				bne			.create
				addq.w		#1,a2
				subq.w		#1,d0
				jsr			KillSpace
				bmi.s		.ende
				move.w		#-2,DEVICE				; File Open
.create:		lea			FILE_STRING,a3
				jsr			ExtractString
				movem.l		d0/a2,SAVE_POSITION
				bra.s		.ende

.found:			subq.w		#3,d2
				neg.w		d2
				move.w		d2,DEVICE
				addq.w		#8,sp
				movem.l		d0/a2,SAVE_POSITION

.ende:			movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

_ASCFIND:		moveq		#0,d2					; OpcodelÑnge --> nichts addieren
				jsr			GetLength				; .w|.l
				bmi			LengthError
				seq			d6						; OpcodelÑnge?
				beq.s		.default				; Default=OpcodelÑnge

				moveq		#2,d2					; LÑnge testen
				subq.w		#2,d3					; Word?
				beq.s		.default
				moveq		#4,d2
				subq.w		#2,d3					; Long?
				bne			LengthError

.default:		jsr			GetFirstValue			; [From]
				bgt			NumberError
				beq.s		.from_io
				move.l		FILE_ANFANG,d3			; sonst FILE_ANFANG
				beq			NumberError

.from_io:		movea.l		d3,a0					; a0 = [From]
				jsr			GetNextValue			; [,To]
				bgt			NumberError
				beq.s		.to_io
				move.l		FILE_ANFANG,d3			; sonst FILE_ENDE
				add.l		FILE_LAENGE,d3
				beq			NumberError

.to_io:			movea.l		d3,a1					; a1 = [,To]
				cmpa.l		a0,a1					; From>=To?
				bgt.s		.range_io
				movem.l		d0/a2,SAVE_POSITION
				rts
.range_io:		jsr			GetTerm					; Der String ist Nullterminiert
				ble			NumberError
				bsr			Umlenkung
				movea.l		a3,a5					; a5 = Suchstring
				movea.l		a0,a3					; Disassemblyadresse
				lea			.ASCFIND(pc),a6			; Routine
				st			LIST_FLAG				; Listmodus
				bra			PrintManager

*---------------

.ASCFIND:		move.l		a2,-(sp)
				lea			PrintPuffer,a2			; Stringadresse
				jsr			Disassembler
				clr.b		(a2)					; Stringende
				lea			PrintPuffer,a2			; Stringadresse
				bsr			hunt_for_it
				bne.s		.found
				move.l		(sp)+,a2
				tst.b		d6						; LÑnge variabel?
				beq.s		.cont1
				adda.w		DisassemblyLength,a3	; D2 = 0 bei variabler LÑnge
.cont1:			adda.w		d2,a3
				cmpa.l		a3,a1
				bgt.s		.ASCFIND
				moveq		#-1,d0
				rts
.found:			move.l		(sp)+,a2
				bsr			ListLineDown
				tst.b		d6						; LÑnge variabel?
				beq.s		.cont2
				adda.w		DisassemblyLength,a3	; D2 = 0 bei variabler LÑnge
.cont2:			adda.w		d2,a3
				cmpa.l		a3,a1
				sle			d0
				tst.b		d0
				rts

*---------------

hunt_for_it:	movem.l		a2/a5,-(sp)				; Suchen mit Wildcards
hunt_loop:		move.b		(a5)+,d7
				beq.s		test_end
				cmpi.b		#'*',d7
				beq.s		all_quantor
				cmpi.b		#'?',d7
				beq.s		existenz_quantor
				cmp.b		(a2)+,d7
				beq.s		hunt_loop
hunt_fail:		movem.l		(sp)+,a2/a5
				moveq		#0,d7
				rts
existenz_quantor:
				tst.b		(a2)+
				bne.s		hunt_loop
				bra.s		hunt_fail
test_end:		tst.b		(a2)
				bne.s		hunt_fail
hunt_found:		movem.l		(sp)+,a2/a5
				moveq		#-1,d7
				rts
all_quantor:	cmp.b		#'*',(a5)+
				beq.s		all_quantor
				subq.w		#1,a5
loop:			bsr.s		hunt_for_it
				bne.s		hunt_found
				tst.b		(a2)+
				bne.s		loop
				bra.s		hunt_fail

*-------------------------------------------------------------------------------

_BREAKPOINTS:	lea			BREAKPOINTS,a0

				cmpi.b		#'-',(a2)			; B - ?
				beq			.ClearAll

				jsr			CalcNumber			; B Nummer... ?
				bne			.ShowAll

*-------------- B Nummer (schliesst auch B Nummer- ein)
.Setzen:		tst.l		d3					; Breakpointnummer testen
				bmi			.WrongBPT
				cmp.l		#ANZAHL_BREAKPOINTS,d3
				bhs			.WrongBPT

				jsr			KillSpace
				bmi			.zeige_einen
				cmpi.b		#'-',(a2)			; B Nummer- ?
				beq			.ClearOne
				cmpi.b		#'=',(a2)			; B Nummer=... ?
				bne			.zeige_einen
				subq.w		#1,d0
				addq.w		#1,a2
				lsl.w		#4,d3
				adda.w		d3,a0				; B Nummer=
				jsr			GetFirstValue
				bne			NumberError
				move.l		#1,8(a0)			; B Nummer=Adresse
				move.w		#2,12(a0)
				move.l		d3,(a0)
				jsr			GetNextValue
				bgt			NumberError
				beq.s		.anzahl
				cmpi.b		#'*',(a2)+			; Permanent BPT?
				beq.s		.permanent
				cmpi.b		#'=',-(a2)			; ZÑhler BPT?
				bne.s		.ende
				subq.w		#1,d0
				addq.w		#1,a2
				clr.l		8(a0)
				move.w		#1,12(a0)			; B Nummer=Adresse,=
				jsr			GetFirstValue
				bgt			NumberError
				bne.s		.ende				; B Nummer=Adresse,=Startwert
.anzahl:		move.l		d3,8(a0)			; B Nummer=Adresse,Anzahl
				bra.s		.ende
.permanent:		clr.w		12(a0)				; B Nummer=Adresse,*
				subq.w		#1,d0
.ende:			movem.l		d0/a2,SAVE_POSITION
				rts
.WrongBPT:		st			Ueberlauf
				bra			NumberError

*-------------- Breakpoints lîschen
*-------------- ALLE
.ClearAll:		moveq		#ANZAHL_BREAKPOINTS-1,d7
.clear:			clr.l		(a0)				; B -
				lea			16(a0),a0
				dbra		d7,.clear
.setA2:			addq.w		#1,a2
				subq.w		#1,d0
				movem.l		d0/a2,SAVE_POSITION
				rts
*-------------- EINEN
.ClearOne:		lsl.w		#4,d3				; B Nummer-
				adda.w		d3,a0
				clr.l		(a0)
				bra.s		.setA2

*-------------- Breakpoints zeigen
*-------------- ALLE
.ShowAll:		moveq		#0,d6						; Breakpointnummer
				moveq		#ANZAHL_BREAKPOINTS-1,d7	; Anzahl Breakpoints
.show_BPT:		bsr			Umlenkung
				lea			.show(pc),a6
				bra			PrintManager

.show:			move.l		d6,FEHLER_ADRESSEN
				move.l		(a0),FEHLER_ADRESSEN+4
				move.l		8(a0),FEHLER_ADRESSEN+8
				lea			.BPT_MESSAGE_1,a3
				cmpi.w		#1,12(a0)
				blt.s		.ok
				bgt.s		.zaehler
				lea			.BPT_MESSAGE_2,a3
				bra.s		.ok
.zaehler:		lea			.BPT_MESSAGE_3,a3
.ok:			tst.l		(a0)
				beq.s		.NotThisBPT
				bsr			MessageDown_C
.NotThisBPT:	lea			16(a0),a0
				addq.l		#1,d6
				subq.w		#1,d7
				smi			d0
				tst.b		d0
				rts
*-------------- EINEN
.zeige_einen:	move.l		d3,d6		  		; B Nummer
				lsl.w		#4,d3
				adda.w		d3,a0
				moveq		#0,d7
				bra.s		.show_BPT

*---------------

				MessageC	.BPT_MESSAGE_1,'Breakpoint $=$,*'
				MessageC	.BPT_MESSAGE_2,'Breakpoint $=$,=$'
				MessageC	.BPT_MESSAGE_3,'Breakpoint $=$,$'

*-------------------------------------------------------------------------------

_CALL:			movea.l		SAVE_A7,a0			; RÅcksprungadresse schreiben
				move.l		SAVE_PC,-(a0)
				move.l		a0,SAVE_A7			; neuer Stackpointer setzen
				bsr			PUT_SP
				jsr			GetFirstValue
				bgt			NumberError
				bmi.s		.cont
				move.l		d3,SAVE_PC
.cont:			bra			FTASTE3

*-------------------------------------------------------------------------------

_CD:			jsr			ExpandPath
				bsr			Umlenkung
				movea.l		a3,a2
				jsr			DSETPATH			; Pfad setzen
				bne			PathError
				lea			PATH-2,a3			; umkopieren (wegen dem Space)
				lea			PrintPuffer,a2
				move.b		#32,(a2)+
.copy:			move.b		(a3)+,(a2)+
				bne.s		.copy
				lea			PrintPuffer,a3
				bra			RawMessageDown_C

*-------------------------------------------------------------------------------

_CHECKSUMME:	jsr			GetFirstValue
				bgt			NumberError
				beq.s		.address_io
				move.l		RW_ADRESSE,d3
				beq			NumberError
.address_io:	move.l		d3,a6				; a6 = Adresse
				jsr			GetNextValue
				bgt			NumberError
				beq.s		.checksum_io
				move.w		#$1234,d3			; Defaultchecksumme
.checksum_io:	moveq		#0,d6
				move.w		d3,d6				; d6 = Checksum
				jsr			GetNextValue
				bgt			NumberError
				beq.s		.number_io
				move.l		#256,d3				; Defaultnumber
.number_io:		move.l		d3,d7				; d7 = Number (Anzahl Words)
				bsr			Umlenkung
				st			BreakFlag
				bra.s		.entry
.loop:			move.b		(a6)+,d5			; damit kein Addresserror
				lsl.w		#8,d5				; auftreten kann
				move.b		(a6)+,d5
				sub.w		d5,d6
.entry:			dbra		d7,.loop
				subi.l		#$10000,d7
				bpl.s		.loop
				sf			BreakFlag
				move.l		d6,FEHLER_ADRESSEN
				lea			.CheckSumme,a3
				bra			MessageDown_C

				MessageC	.CheckSumme,'Checksum: $'

*-------------------------------------------------------------------------------

_CLR:			jsr			GetFirstValue
				bgt			NumberError
				beq.s		.from_io
				move.l		FILE_ANFANG,d3
				beq			NumberError
.from_io:		movea.l		d3,a0				; a0 = [From]
				jsr			GetNextValue
				bgt			NumberError
				beq.s		.to_io
				move.l		FILE_ANFANG,d3
				add.l		FILE_LAENGE,d3
				beq			NumberError
.to_io:			movem.l		d0/a2,SAVE_POSITION
				move.l		d3,d0				; d0 = Anzahl Bytes
				sub.l		a0,d0
				ble.s		.ende
				st			BreakFlag
				jsr			ClearMemory
				sf			BreakFlag
.ende:			rts

*-------------------------------------------------------------------------------

_COOKIE:		bsr			Umlenkung
				move.l		$5a0.w,d7
				beq.s		.ende
				move.l		d7,a0
				lea			.COOKIE_MESSAGE,a3		; String
				lea			.COOKIE(PC),a6			; Routine
				bra			PrintManager			; MANAGER aufrufen

*---------------

.COOKIE:		tst.l		(a0)					; Eintrag leer?
				beq.s		.ende
				lea			9(a3),a2				; Cookie-ID eintragen
				move.b		(a0)+,(a2)+
				move.b		(a0)+,(a2)+
				move.b		(a0)+,(a2)+
				move.b		(a0)+,(a2)+
				moveq		#7,d2					; Cookievalue eintragen
				move.l		(a0)+,d3
				lea			17(a3),a2
				bsr			PRINT_HEX
				move.b		#32,(a2)				; zeigt auf Debugger?
				cmp.l		ProgrammStart,d3
				blo.s		.not_within
				cmp.l		ProgrammEnde,d3
				bhs.s		.not_within
				move.b		#'*',(a2)				; innerhalb Debugger
.not_within:	bsr			RawMessageDown_P
				moveq		#0,d0
				rts
.ende:			moveq		#-1,d0
				rts

				MessageP	.COOKIE_MESSAGE,' Name: "PBUG" = $12345678*'

*-------------------------------------------------------------------------------

_COPY:			jsr			GetFirstValue
				bgt			NumberError
				beq.s		.from_io
				move.l		FILE_ANFANG,d3
				beq			NumberError
.from_io:		movea.l		d3,a0					; a0 = [From]
				jsr			GetNextValue
				bgt			NumberError
				beq.s		.to_io
				move.l		FILE_ANFANG,d3
				add.l		FILE_LAENGE,d3
				beq			NumberError
.to_io:			movea.l		d3,a1					; a1 = [,To]
				jsr			GetNextValue
				bne			NumberError
				movem.l		d0/a2,SAVE_POSITION
				movea.l		d3,a2					; a2 = ,Destination
				move.l		a1,d0					; d0 = Anzahl Bytes
				sub.l		a0,d0
				subq.l		#1,d0
				bpl.s		.cont
				rts
.cont:			st			BreakFlag
				cmpa.l		a0,a2
				bhi.s		.VonHinten
.copy_1:		move.b		(a0)+,(a2)+
				dbra		d0,.copy_1
				sub.l		#$10000,d0
				bpl.s		.copy_1
				sf			BreakFlag
				rts
.VonHinten:		lea			1(a0,d0.l),a0
				lea			1(a2,d0.l),a2
.copy_2:		move.b		-(a0),-(a2)
				dbra		d0,.copy_2
				subi.l		#$10000,d0
				bpl.s		.copy_2
				sf		    BreakFlag
				rts

*-------------------------------------------------------------------------------

_DIR:			jsr			ExpandPath
				bsr			Umlenkung
				movea.l		a3,a2				; Pfad setzen
				jsr			DSETPATH
				bne			PathError
				lea			PRINT,a3			; Pfad printen
				move.b		#32,(a3)
				bsr			RawMessageDown_C
				lea			ALL_FILES,a2		; erstes File suchen
				jsr			FSFIRST
				beq.s		.file_io
				lea			.file_fail,a3
				bsr			MessageDown_C
				jmp			RESTORE_PATH
.file_io:		lea			NULL_BYTE,a3		; Leerzeile
				bsr			MessageDown_C
				moveq		#0,d5				; Anzahl Directories
				moveq		#0,d6				; Anzahl Files
				moveq		#0,d7				; TotallÑnge
				lea			.DIR_MESSAGE,a3
				lea			.DIR(PC),a6
				move.l		#RESTORE_PATH,BreakRoutine
				bra			PrintManager

*---------------

.DIR:			jsr			FGETDTA				; ---> A0.l
				move.l		a3,a2
.clear:			move.b		#32,(a2)+
				tst.b		(a2)
				bne.s		.clear

				lea			1(a3),a2
				move.b		#'C',(a2)
				move.b		#'D',1(a2)
				addq.l		#1,d5
				btst		#4,21(a0)
				bne.s		.command_io
				subq.l		#1,d5
				addq.l		#1,d6
				move.b		#'L',(a2)+
				move.b		#'O',(a2)+
				move.b		#'A',(a2)+
				move.b		#'D',(a2)+
				lea			30(a0),a1			; Name
				moveq		#8,d0
.search:		tst.b		(a1)
				beq.s		.command_io
				cmpi.b		#'.',(a1)+
				dbeq		d0,.search
				bne.s		.command_io
				moveq		#0,d0
				move.b		(a1)+,d0
				swap		d0
				move.b		(a1)+,d0
				lsl.w		#8,d0
				move.b		(a1)+,d0
				cmpi.l		#'PRG',d0
				beq.s		.program
				cmpi.l		#'APP',d0
				beq.s		.program
				cmpi.l		#'GTP',d0
				beq.s		.program
				cmpi.l		#'TOS',d0
				beq.s		.program
				cmpi.l		#'TTP',d0
				bne.s		.command_io
.program:		subq.w		#4,a2
				move.b		#'L',(a2)+
				move.b		#'E',(a2)+
				move.b		#'X',(a2)+
				move.b		#' ',(a2)+

.command_io:	lea			30(a0),a1			; Name
				lea			6(a3),a2
				move.b		#'"',(a2)+
				moveq		#13,d0
.copy:			move.b		(a1)+,(a2)+
				dbeq		d0,.copy
				move.b		#'"',-(a2)

				lea			21(a3),a2			; LÑnge
				move.l		26(a0),d3
				add.l		d3,d7				; TotallÑnge
				move.b		#';',(a2)+
				move.b		#'.',(a2)+
				bsr			PRINT_DEZ

				lea			35(a3),A2			; Zeit
				moveq		#1,d2				; zwei Stellen
				moveq		#0,d3
				move.b		22(a0),d3
				lsr.b		#3,d3
				bsr			PRINT_DEZIMAL
				move.b		#':',(a2)+
				move.w		22(a0),d3
				lsr.w		#5,d3
				andi.w		#%111111,d3
				bsr			PRINT_DEZIMAL
				move.b		#':',(a2)+
				moveq		#%11111,d3
				and.w		22(a0),d3
				add.w		d3,d3
				bsr			PRINT_DEZIMAL

				lea			45(a3),a2			; Datum
				moveq		#$1F,d3
				and.w		24(a0),d3
				bsr			PRINT_DEZIMAL
				move.b		#'.',(a2)+
				move.w		24(A0),d3
				lsr.w		#5,d3
				andi.w		#%1111,d3
				bsr			PRINT_DEZIMAL
				move.b		#'.',(a2)+
				moveq		#3,d2				; 4 Stellen
				moveq		#0,d3
				move.b		24(a0),d3
				lsr.w		d3
				add.w		#1980,d3
				bsr			PRINT_DEZIMAL

				bsr			RawMessageDown_C
				jsr			FSNEXT
				beq.s		.ende
				jsr			RESTORE_PATH

				lea			NULL_BYTE,a3
				bsr			MessageDown_C
				lea			PrintPuffer,a2
				move.l		d5,d3
				bsr			PRINT_DEZ
				lea			.ordner(pc),a3
				bsr.s		.copy_string
				move.l		d6,d3
				bsr			PRINT_DEZ
				lea			.files(pc),a3
				bsr.s		.copy_string
				move.l		d7,d3
				bsr			PRINT_DEZ
				lea			.bytes(pc),a3
				bsr.s		.copy_string
				clr.b		(a2)
				lea			PrintPuffer,a3
				bsr			MessageDown_C

				moveq		#-1,d3
.ende:			rts

.copy_string:	move.b		(a3)+,(a2)+
				bne.s		.copy_string
				subq.w		#1,a2
				rts

*---------------

.ordner:		dc.b		' directories    ',0
.files:			dc.b		' file(s)    ',0
.bytes:			dc.b		' byte(s)',0
		.EVEN
				MessageC	.DIR_MESSAGE,' LOAD "PEACEBUG.S"   ;.331859      10:10:10  22.10.1994'
				MessageC	.file_fail,'no file found'

*-------------------------------------------------------------------------------

_DFREE: 		jsr			ExpandPath
				bsr			Umlenkung
				movea.l		a3,a2
				jsr			DSETPATH
				jsr			DFREE
				bmi			.ende

				move.l		8(a0),d3			; a0 = ^DTA
				move.l		12(a0),d2
				jsr			LongMulu
				move.l		d3,d0				; d0 = Bytes pro Cluster

				lea			.DFREE_MESSAGE+6,a2
				move.b		DRIVE,(a2)
				lea			3(a2),a2

				move.l		4(a0),d2
				sub.l		(a0),d2
				jsr			LongMulu
				move.l		#1024,d2
				jsr			LongDivu			; benutzte KB
				bsr			PRINT_DEZ
				lea			.used,a3
				bsr.s		.copy

				move.l		d0,d3
				move.l		(a0)+,d2
				jsr			LongMulu
				move.l		#1024,d2
				jsr			LongDivu			; freie KB
				bsr			PRINT_DEZ
				lea			.free,a3
				bsr.s		.copy

				move.l		d0,d3
				move.l		(a0),d2
				jsr			LongMulu
				move.l		#1024,d2
				jsr			LongDivu			; gesamt KB
				bsr			PRINT_DEZ
				lea			.totally,a3
				bsr.s		.copy
				clr.b		(a2)

				lea			.DFREE_MESSAGE,a3
				bsr			MessageDown_C

.ende:			jmp			RESTORE_PATH

.copy:			move.b		(a3)+,(a2)+
				bne.s		.copy
				subq.w		#1,a2
				rts

*---------------

				MessageC	.DFREE_MESSAGE,'Drive A: 12345678 K used, 12345678 K free, 12345678 K totally'
				MessageC	.used,' K used, '
				MessageC	.free,' K free, '
				MessageC	.totally,' K totally'

*-------------------------------------------------------------------------------

_DO:			jsr			GetFirstValue
				bgt			NumberError
				bne.s		.address_io
				move.l		d3,SAVE_PC
.address_io:	movem.l		d0/a2,SAVE_POSITION
				bsr			HoldTheLine
				bra			FTASTE2

*-------------------------------------------------------------------------------

* D0 = Anzahl Adressen, D2 = CMPM (1,2,4), D3 = Zeile, D7 = SpeicherbereichlÑnge
* COMPARE A0,A1,A2, A3 = Compare_message, A5 = Fehler_adressen, A6 = Routine

_COMPARE:		moveq		#1,d2					; Default Byte
				lea			.compare_b(pc),a6
				jsr			GetLength
				bmi			LengthError
				subq.w		#1,d3
				ble.s		.length_io				; Byte oder Default
				moveq		#2,d2
				lea			.compare_w(pc),a6
				subq.w		#1,d3
				beq.s		.length_io				; Word
				moveq		#4,d2
				lea			.compare_l(pc),a6
				subq.w		#2,d3
				bne			LengthError

.length_io:		jsr			GetFirstValue
				bgt			NumberError
				beq.s		.from_io
				move.l		FILE_ANFANG,d3
				beq			NumberError

.from_io:		movea.l		d3,a0					; a0 = [From]
				jsr			GetNextValue
				bgt			NumberError
				beq.s		.to_io
				move.l		FILE_ANFANG,d3
				add.l		FILE_LAENGE,d3
				beq			NumberError

.to_io:			movea.l		d3,a1					; a1 = [,To]
				jsr			GetNextValue
				bne			NumberError
				bsr			Umlenkung
				movea.l		d3,a2					; a2 = ,Destination
				bsr.s		OutputInit
				cmpa.l		a0,a1
				bgt.s		Output
				rts

*---------------

.compare_b:		cmpm.b		(a0)+,(a2)+
				dbne		d7,.compare_b
				bne			OutputFound
				subi.l		#$10000,d7
				bpl.s		.compare_b
				bra.s		OutputAbbruch

.compare_w:		cmpm.w		(a0)+,(a2)+
				dbne		d7,.compare_w
				bne			OutputFound
				subi.l		#$10000,d7
				bpl.s		.compare_w
				bra.s		OutputAbbruch

.compare_l:		cmpm.l		(a0)+,(a2)+
				dbne		d7,.compare_l
				bne			OutputFound
				subi.l		#$10000,d7
				bpl.s		.compare_l
				bra.s		OutputAbbruch

*-------------------------------------------------------------------------------
* Outputroutinen:
* ---> d2.w = (b,w,l) = (1,2,4)
*	   d3.w = Y_POSITION
* <--- d7.l = SchleifenzÑhler
* ---> a0.l = [From], wird nur vom OutputInit benutzt
*	   a1.l = [,To], wird nur vom OutputInit benutzt
*	   a2.l = ,Destination, diese Adresse wird auch geprintet
*	   a3.l = String/Message
*	   a5.l = FEHLER_ADRESSEN
*	   a6.l = Routine fÅr PrintManager
*-------------------------------------------------------------------------------

* ---> d2.w = (b,w,l) = (1,2,4)
* ---> a0.l = [From], wird nur vom OutputInit benutzt
* ---> a1.l = [,To], wird nur vom OutputInit benutzt
* <--- tst.l d7.l = SchleifenzÑhler
OutputInit:		move.l		d1,-(sp)
				move.l		a1,d7
				sub.l		a0,d7
				moveq		#0,d1
				move.w		d2,d1
				lsr.w		#1,d1
				lsr.l		d1,d7			; LÑnge des Speicherbereichs
				move.l		(sp)+,d1
				subq.l		#1,d7
				rts

*---------------

Output: 		lea			NUMBER_MESSAGE,a3
				lea			FEHLER_ADRESSEN,a5
				move.w		#ANZAHL_ADRESSEN,ADRESSEN_ZEILEN
				move.w		BILD_BREITE,d1
				subq.w		#1,d1
				divu		#11,d1
				cmpi.w		#ANZAHL_ADRESSEN,d1
				bhs			PrintManager
				move.w		d1,ADRESSEN_ZEILEN
				bra			PrintManager

*---------------

OutputAbbruch:	cmp.w		ADRESSEN_ZEILEN,d1
				beq.s		.nothing_found
				bsr			OutputPrint
.nothing_found:	moveq		#-1,d1
				rts

*---------------

OutputFound:	subq.w		#1,d1
				suba.w		d2,a2
				move.l		a2,(a5)+
				move.b		#'$',(a3)+
				move.b		#' ',(a3)+

				pea			(a0)				; Adresse irgendwo in einem
				move.l		ProgrammStart,a0	; debuggereigenen Speicher-
				pea			(a0)				; bereich?
				add.l		ProgrammLength,a0
				pea			(a0)
				bsr.s		TestWithin
				movea.l		ZEICHEN_ADRESSE,a0
				pea			(a0)
				adda.w		ZEICHEN_SCREEN_8_8,a0
				pea			(a0)
				bsr.s		TestWithin
				movea.l		HISTORY_POINTER,a0
				pea			(a0)
				adda.l		HISTORY_LENGTH,a0
				pea			(a0)
				bsr.s		TestWithin
				movea.l		(sp)+,a0

				move.b		#' ',(a3)+
				clr.b		(a3)
				adda.w		d2,a2
				subq.l		#1,d7
				bmi.s		.ende
				movem.l		a3/a5,-(sp)
				bsr.s		OutputPrint
				tst.w		d1
				ble.s		.cont
				movem.l		(sp)+,a3/a5
				subq.w		#1,Y_POSITION
				bsr			POSITIONIEREN
				jmp			(a6)
.cont:			addq.w		#8,sp
				move.w		ADRESSEN_ZEILEN,d1
				clr.b		-(sp)
				tst.b		(sp)+
				rts
.ende:			bsr.s		OutputPrint
				moveq		#-1,d1
				rts

*---------------

OutputPrint:	lea			NUMBER_MESSAGE,a3
				lea			FEHLER_ADRESSEN,a5
				bra			MessageDown_C

*---------------

TestWithin:		cmpa.l		4(sp),a2
				bhi.s		.not_within
				cmpa.l		8(sp),a2
				blo.s		.not_within
				move.b		#'*',-1(a3)
.not_within:	move.l		(sp),8(sp)
				addq.w		#8,sp
				rts

*---------------

		.DATA
NUMBER_MESSAGE:	dc.b		'$'
			.REPT ANZAHL_ADRESSEN-1
				dc.b		'  $'
			.ENDM
				dc.b		0
		.TEXT

*-------------------------------------------------------------------------------

_HUNT:			moveq		#2,d2				; Default Word
				bra.s		DEFAULT_FIND
_FIND:			moveq		#1,d2				; Default Byte
				jsr			GetLength
				bmi			LengthError
				subq.w		#1,d3
				ble.s		DEFAULT_FIND		; Byte oder Default
				moveq		#2,d2
				subq.w		#1,d3
				beq.s		DEFAULT_FIND		; Word
				moveq		#4,d2
				subq.w		#2,d3
				bne			LengthError

DEFAULT_FIND:	jsr			GetFirstValue
				bgt			NumberError
				beq.s		.from_io
				move.l		FILE_ANFANG,d3
				beq			NumberError

.from_io:		movea.l		d3,a0				; a0 = [From]
				jsr			GetNextValue
				bgt			NumberError
				beq.s		.to_io
				move.l		FILE_ANFANG,d3
				add.l		FILE_LAENGE,d3
				beq			NumberError

.to_io:			movea.l		d3,a1				; a1 = [,To]
				jsr			GetTerm
				ble			NumberError			; LÑnge=0 oder Fehler?
				move.l		d7,d1				; d1 = LÑnge des Strings
				bsr			OutputInit
				bpl.s		.cont
				rts
.cont:			bsr			Umlenkung
				move.l		d1,d0				; d0 = LÑnge des Strings
				subq.l		#2,d0
				movea.l		a3,a1
				movea.l		a0,a2
				move.b		(a1)+,d6			; erstes Byte holen
				move.l		a1,d5				; d5 = String[2]
				lea			.FIND(PC),a6
				bra			Output

*---------------

* ACHTUNG: (A2) muss Quelloperand sein, weil bei ungÅltigen Speicherbereichen
*	   (280000- bei 2.5 MB) die Statusbits sonst nicht gesetzt werden
.FIND:			cmp.b		(a2),d6
				adda.w		d2,a2				; Schrittweite
				dbeq		d7,.FIND
				bne.s		.FIND_LONG
				move.w		d0,d4
				bmi			OutputFound
				movea.l		a2,a0
				suba.w		d2,a2
				addq.w		#1,a2
.loop:			cmpm.b		(a2)+,(a1)+
				dbne		d4,.loop
				movea.l		d5,a1				; d5 = String[2]
				movea.l		a0,a2
				beq			OutputFound
				dbra		d7,.FIND
.FIND_LONG:		subi.l		#$10000,d7
				bpl.s		.FIND
				bra			OutputAbbruch

*-------------------------------------------------------------------------------

_FILL:			jsr			GetFirstValue
				bgt			NumberError
				beq.s		.from_io
				move.l		FILE_ANFANG,d3
				beq			NumberError
.from_io:		movea.l		d3,a0				; a0 = [From]
				jsr			GetNextValue
				bgt			NumberError
				beq.s		.to_io
				move.l		FILE_ANFANG,d3
				add.l		FILE_LAENGE,d3
				beq			NumberError
.to_io:			movea.l		d3,a1				; a1 = [,To]
				jsr			GetTerm
				ble			NumberError
				movem.l		d0/a2,SAVE_POSITION
				subq.w		#1,d7
				move.w		d7,d1				; d1/d7 = StringlÑnge-1
				movea.l		a3,a2
				move.l		a1,d0
				sub.l		a0,d0				; d0 = LÑnge Speicherbereich
				bgt.s		.cont
				rts

.cont:			st			BreakFlag
.loop:			move.b		(a3)+,(a0)+
				subq.l		#1,d0
				dbeq		d1,.loop
				beq.s		.ende
				move.w		d7,d1
				movea.l		a2,a3
				bra.s		.loop
.ende:			sf			BreakFlag
				rts

*-------------------------------------------------------------------------------

_FREE:			bsr			Umlenkung
				pea			-1.w
				move.w		#72,-(sp)
				trap		#1
				addq.w		#6,sp
				tst.l		d0
				bne.s		.at_least_one
				rts

*--------------- Speicherblocks reservieren
.at_least_one:	move.l		sp,.save_sp
				move		sr,d7
				move.w		d7,.save_sr
				move		#$2300,sr
				lea			_STACK_OS,sp
				link		a5,#-100*8				; Platz fÅr 100 Blîcke
				clr.l		-(a5)					; leerer Block als Endekennung
				clr.l		-(a5)
				moveq		#98,d6					; nur 100 Blocks
.next_block:	pea			-1.w					; LÑnge bestimmen
				move.w		#72,-(sp)
				trap		#1
				addq.w		#6,sp
				move.l		d0,d7
				beq.s		.last_block
				move.l		d0,-(sp)				; Block reservieren
				move.w		#72,-(sp)
				trap		#1
				addq.w		#6,sp
				tst.l		d0
				beq.s		.last_block
				move.l		d7,-(a5)				; LÑnge
				move.l		d0,-(a5)				; Adresse
				dbra		d6,.next_block

*--------------- Speicherblocks freigeben
.last_block:	movea.l		a5,a4
.free_block:	move.l		(a4)+,d0				; Speicher freigeben
				beq.s		.print_it
				move.l		d0,-(sp)
				move.w		#73,-(sp)
				trap		#1
				addq.w		#6,sp
				addq.w		#4,a4
				bra.s		.free_block

*--------------- Speicherblocks printen
.print_it:		st			d6						; Titel printen
				lea			.print_blocks(pc),a6
				bsr			PrintManager
				unlk		a5
				rts

.print_blocks:	tst.b		d6
				beq.s		.no_title

				lea			.title,a3				; Titel printen
				bsr			MessageDown_C
				lea			NULL_BYTE,a3
				bsr			MessageDown_C

.no_title:		sf			d6
				move.l		(a5)+,d3				; Adresse
				beq.s		.ende
				lea			.free+1,a2
				bsr			PRINT_HEXADEZIMAL		; Adresse printen
				move.l		(a5)+,d3				; LÑnge
				add.l		d3,d7
				lea			.free+22,a3
				lea			.string1,a4
				bsr			.fill					; LÑnge in Bytes
				moveq		#10,d0
				lsr.l		d0,d3
				beq.s		.no_KB_1
				lea			.free+37,a3
				lea			.string2,a4
				bsr			.fill					; LÑnge in KB
.no_KB_1:		clr.b		(a2)
				lea			.free,a3
				bsr			RawMessageDown_C
				moveq		#0,d0
				rts
.ende:			addq.w		#4,a5
				move.l		d7,d3
				lea			NULL_BYTE,a3
				bsr			MessageDown_C
				lea			.total+11,a2
				lea			.total+21,a3
				lea			.string1,a4
				bsr.s		.fill					; LÑnge in Bytes
				moveq		#10,d0
				lsr.l		d0,d3
				beq.s		.no_KB_2
				lea			.total+36,a3
				lea			.string2,a4
				bsr			.fill					; LÑnge in KB
.no_KB_2:		clr.b		(a2)
				lea			.total,a3
				bsr			MessageDown_C
				move.w		.save_sr,d0
				move.w		d0,sr
				movea.l		.save_sp,sp
				moveq		#-1,d0
				rts

*---------------

.fill:			move.l		a2,-(sp)
				bsr			PRINT_DEZ
				move.l		a2,d0
				move.l		(sp)+,a2
				sub.l		a2,d0					; d0 = LÑnge
				sub.l		d0,a3
.clear:			move.b		#32,(a2)+
				cmpa.l		a2,a3
				bhi.s		.clear
				bsr			PRINT_DEZ
.copy:			move.b		(a4)+,(a2)+
				bne.s		.copy
				subq.w		#1,a2
				rts

*---------------

.save_sp:		dc.l		1
.save_sr:		dc.w		1

				MessageC	.title,'Address        Length Bytes   Length KB'
				MessageC	.free,' $12345678  1234567890 Bytes  1234567 KB'
				MessageC	.total,'Total:     1234567890 Bytes  1234567 KB'
				MessageC	.string1,' Bytes'
				MessageC	.string2,' KB'

*-------------------------------------------------------------------------------

_GO:			clr.l		GO_BREAKPT
				jsr			GetFirstValue
				bgt			NumberError
				bne.s		GO_PC
				move.l		d3,SAVE_PC
GO_PC:			jsr			GetNextValue
				bgt			NumberError
				bne.s		NO_BPT
				move.l		d3,GO_BREAKPT
NO_BPT:			bsr			HoldTheLine
				bra			FTASTE19

*-------------------------------------------------------------------------------

_HELP:			bsr			PARSER_2
				bmi.s		.HELP_ALL
				lea			HelpRecord,a3
				bra.s		.entry
.search:		tst.b		(a3)+
				bne.s		.search
.entry:			dbra		d7,.search
				tst.b		(a3)
				beq			.HELP_ALL
				movem.l		SAVE_POSITION,d0/a2
				bsr			Umlenkung
				bra			MessageDown_C

*-------------

.HELP_ALL:		movem.l		SAVE_POSITION,d0/a2
				bsr			Umlenkung
				moveq		#ANZAHL_BEFEHLE-1,d7
				lea			HelpRecord,a3
				lea			.HELP_AUSGABE(pc),a6
				bra			PrintManager

.HELP_AUSGABE:	tst.b		(a3)
				beq.s		.next
				bsr			MessageDown_C
.next:			tst.b		(a3)+
				bne.s		.next
				subq.w		#1,d7
				bmi.s		.ende
				moveq		#0,d0
				rts
.ende:			moveq		#-1,d0
				rts

*-------------------------------------------------------------------------------

_INFO:			bsr			Umlenkung
				st			BreakFlag
				move.w		Y_POSITION,d3
				bsr			PRINT_FILEINFO
				tst.b		FILE_NAME
				beq.s		.keineLeerzeile
				lea			NULL_BYTE,a3			; Leerzeile printen
				bsr			MessageDown_C

.keineLeerzeile:lea			FEHLER_ADRESSEN,A6
				move.l		ProgrammLength,d7
				beq.s		.cont_1
				lea			.DEBUG_MESSAGE_1,a3		; Programm
				move.l		ProgrammStart,(a6)
				bsr			.PrintDezimal
				bsr			MessageDown_C

.cont_1:		move.l		TextSegLength,d7
				beq.s		.cont_2
				lea			.DEBUG_MESSAGE_2,a3		; Text Segment
				move.l		TextSegStart,(a6)
				bsr			.PrintDezimal
				bsr			MessageDown_C

.cont_2:		move.l		DataSegLength,d7
				beq.s		.cont_3
				lea			.DEBUG_MESSAGE_3,a3		; Data Segment
				move.l		DataSegStart,(a6)
				bsr			.PrintDezimal
				bsr			MessageDown_C

.cont_3:		move.l		BssSegLength,d7
				beq.s		.cont_4
				lea			.DEBUG_MESSAGE_4,a3		; BSS Segment
				move.l		BssSegStart,(a6)
				bsr			.PrintDezimal
				bsr			MessageDown_C

.cont_4:		lea			.DEBUG_MESSAGE_5,a3		; Cookierecord
				move.l		#COOKIE_RECORD,(a6)
				bsr			MessageDown_C
				bsr			PRINT_SEKTOR
				sf		    BreakFlag
				move.w		Y_POSITION,d3
				rts

*---------------

.PrintDezimal:	movem.l		d3/a2,-(sp)
				move.l		d7,d3
				lea			27(a3),a2
				bsr			PRINT_DEZ
				clr.b		(a2)
				movem.l		(sp)+,d3/a2
				rts

*---------------

				MessageC	.DEBUG_MESSAGE_1,'Debuggerstart:  $  Length: 1234567890'
				MessageC	.DEBUG_MESSAGE_2,'TEXT-Segment:   $  Length: 1234567890'
				MessageC	.DEBUG_MESSAGE_3,'DATA-Segment:   $  Length: 1234567890'
				MessageC	.DEBUG_MESSAGE_4,'BSS-Segment:    $  Length: 1234567890'
				MessageC	.DEBUG_MESSAGE_5,'Cookie:         $'

*-------------------------------------------------------------------------------

_LAST:			bsr			Umlenkung
				lea			ERROR_STRING,a3
				bra			RawMessageDown_C

*-------------------------------------------------------------------------------

* <--- D2.l = Symbolnummer (0-...)
* <--- D3.l = LÑnge des gefundenen Registers oder 0
* <--- A0.l = Adresse des gefundenen Registers
_LET:			bsr			GetRegister
				move.l		d3,d7
				beq.s		.no_register
				jsr			KillSpace
				bmi.s		.error
				cmpi.b		#'=',(a2)			; reg= ?
				bne.s		.error
				addq.w		#1,a2
				subq.w		#1,d0
				jsr			GetFirstValue		; Wert holen
				bne			NumberError
				movem.l		d0/a2,SAVE_POSITION

				subq.w		#1,d7				; byte?
				beq.s		.byte
				subq.w		#1,d7				; word?
				beq.s		.word
				subq.w		#2,d7				; long?
				beq.s		.long

				clr.l		(a0)+				; doublelong
				move.l		a3,(a0)
				bra.s		.ende
.byte:			move.b		d3,(a0)				; byte
				bra.s		.ende
.word:			move.w		d3,(a0)				; word
				bra.s		.ende
.long:			move.l		d3,(a0)				; long
.ende:			cmpa.l		#SAVE_A7,a0
				beq.s		.put_a7
				bsr			GET_SP
.put_a7:		bsr			PUT_SP
				bsr			SET_PC
				jmp			CACHE_PUT

.no_register:	movem.l		d0/a2,SAVE_POSITION
				lea			.NO_REG_MESSAGE,a3
				bra			MessageRawDown_C
.error:			movem.l		d0/a2,SAVE_POSITION
				lea			SYNTAX_FEHLER,a3
				bra			MessageRawDown_C

				MessageC	.NO_REG_MESSAGE,'Unknown Register'

*-------------------------------------------------------------------------------

_LEXECUTE:		bsr			FreeProgram				; altes Zeugs freigeben
				bsr			FreeFile

				jsr			ExpandFile				; vollstÑndiger Pfad bestimmen
				movem.l		d0/a2,SAVE_POSITION

				lea			FILE_NAME,a2
				moveq		#0,d0
				moveq		#0,d1					; Position des letzten \
.extract_file:	addq.w		#1,d0
				tst.b		(a2)
				beq.s		.ende_extract
				cmpi.b		#'\',(a2)+				; kein \ ?
				bne.s		.extract_file
				move.w		d0,d1					; Position merken
				bra.s		.extract_file
.ende_extract:	lea			FILE_NAME,a2
				move.b		(a2,d1.w),-(sp)
				clr.b		(a2,d1.w)				; Pfad isolieren
				jsr			DSETPATH				; Pfad setzen
				move.b		(sp)+,(a2,d1.w)

				jsr			BeginOs					; Programm mittels Pexec laden
				move.l		ProgrammStart,a0
				move.l		36(a0),a0				; Basepage des Parents
				move.l		44(a0),-(sp)			; Environnement
				pea			NULL_BYTE
				pea			FILE_NAME
				pea			$4b0003
				trap		#1
				lea			16(sp),sp
				jsr			EndOs
				move.l		d0,FILE_ANFANG
				ble			FILE_LOAD_ERROR_2

				bsr			HoldTheLine

				movea.l		FILE_ANFANG,a1			; Basepage
				lea			SYMBOL_VALUE,a2			; BP, TEXT,DATA und BSS Symbole
				move.l		a1,(a2)+				; Basepage
				move.l		a1,(a2)+
				addq.w		#8,a1
				move.l		#256,d0
				move.l		(a1),FILE_TEXT			; TEXT
				move.l		(a1),(a2)+
				move.l		(a1)+,(a2)+
				move.l		(a1),FILE_TEXT_LAENGE	; TEXT LÑnge
				bne.s		.cont1
				clr.l		-(a2)
				clr.l		-(a2)
				addq.w		#8,a2
.cont1:			add.l		(a1)+,d0
				move.l		(a1),FILE_DATA			; DATA
				move.l		(a1),(a2)+
				move.l		(a1)+,(a2)+
				move.l		(a1),FILE_DATA_LAENGE	; DATA LÑnge
				bne.s		.cont2
				clr.l		-(a2)
				clr.l		-(a2)
				addq.w		#8,a2
.cont2:			add.l		(a1)+,d0
				move.l		(a1),FILE_BSS			; BSS
				move.l		(a1),(a2)+
				move.l		(a1)+,(a2)+
				move.l		(a1),FILE_BSS_LAENGE	; BSS LÑnge
				bne.s		.cont3
				clr.l		-(a2)
				clr.l		-(a2)
				addq.w		#8,a2
.cont3:			add.l		(a1)+,d0
				move.l		d0,FILE_LAENGE

				jsr			SYMBOL_LADEN_1			; Programmsymbole laden

				move.b		#-1,LIST_FLAG
				move.l		#_USER_USP,SAVE_USP
				move.l		#_USER_ISP,SAVE_ISP
				move.l		#_USER_MSP,SAVE_MSP
				move.w		#$300,SAVE_STATUS
				move.l		#START_PROGRAMM,SAVE_PC
				move.l		FILE_TEXT,GO_BREAKPT	; Breakpoint setzen
				st			ONLY_LEXE				; nur 16 Zeilen listen
				bra			GOTO_PROGRAM

*---------------

START_PROGRAMM:	st			ProgramRuns				; Programm lÑuft
				clr.l		-(sp)
				move.l		FILE_ANFANG,-(sp)
				clr.l		-(sp)
				pea			$4b0004					; Programm starten
				trap		#1
				lea			16(sp),sp

				pea			0.w						; Supervisormodus an
				move.w		#32,-(sp)
				trap		#1
				movea.l		d0,sp

				sf			ProgramRuns				; Programm lÑuft nicht mehr
				bsr			RESET_VECTORS
				bsr			FreeFile

				move.l		FILE_ANFANG,a0
				move.l		44(a0),-(sp)			; Environnement freigeben
				jsr			MFREE
				pea			(a0)					; Programmcode freigeben
				jsr			MFREE
				move.l		SYMBOL_TABLE_1,-(sp)	; Symboltabelle 1 freigeben
				clr.l		SYMBOL_TABLE_1
				clr.l		ANZAHL_SYMBOLE_1
				jsr			MFREE

				tst.b		ProgramIsFreed			; von FreeProgram aufgerufen?
				beq.s		.show					; nein, dann PTERM anzeigen

				movea.l		FREE_USP,a0				; Register restaurieren
				move.l		a0,usp					; USP restaurieren
				move.w		#$2700,sr
				movea.l		FREE_ISP,sp				; ISP restaurieren
				move.w		#$3700,sr
				movea.l		FREE_MSP,sp				; MSP restaurieren
				move.w		FREE_SR,sr
				movem.l		FREE_REGISTER,d0-a6
				rts

*---------------

.show:			jsr			CREATE_FRAME			; Pterm anzeigen
				move.l		PTERM_ADRESSE,-(sp)
				move.w		sr,-(sp)
				bsr			GOTO_DEBUGGER
				move.l		SAVE_PC,FEHLER_ADRESSEN
				movea.l		PTERM_MESSAGE,a3
				bsr			PRINT_ERROR
				bra			EDITOR

*-------------------------------------------------------------------------------

_LOAD:			bsr			FreeProgram
				bsr			FreeFile
				cmpi.b		#'-',(a2)
				bne.s		.cont
				addq.w		#1,a2
				subq.w		#1,d0
				movem.l		d0/a2,SAVE_POSITION
				rts

.cont:			jsr			ExpandFile
				movem.l		d0/a2,SAVE_POSITION
				exg			a2,a3					; LÑnge bestimmen
				move.l		d0,d1
				jsr			FSFIRST
				bne			FILE_LOAD_ERROR
				jsr			FGETDTA
				move.l		26(a0),d7				; LÑnge
				move.l		d1,d0
				exg			a2,a3

				jsr			GetNextValue
				bgt			NumberError
				beq.s		.start_io
				movem.l		d0/a2,SAVE_POSITION
				move.l		d7,-(sp)				; Speicher reservieren
				jsr			MALLOC
				beq			FILE_LOAD_ERROR
				move.l		d0,d6					; d6 = [Start]
				movem.l		SAVE_POSITION,d0/a2
				bra.s		.ohne_ende
.start_io:		move.l		d3,d6					; d6 = [Start]
				jsr			GetNextValue
				bgt			NumberError
				bne.s		.ohne_ende
				movem.l		d0/a2,SAVE_POSITION
				move.l		d3,d7
				sub.l		d6,d7					; d7 = [,End]
				ble			FILE_LOAD_ERROR

.ohne_ende:		movem.l		d0/a2,SAVE_POSITION
				move.l		d6,FILE_ANFANG			; Anfang
				move.l		d7,FILE_LAENGE			; LÑnge

				moveq		#0,d0					; Readonly
				lea			FILE_NAME,a2
				jsr			FOPEN					; îffnen
				bmi			FILE_LOAD_ERROR
				movea.l		d6,a3
				move.l		d7,d3
				jsr			FREAD					; Datei lesen
				bne			FILE_LOAD_ERROR

				jsr			FCLOSE
				movea.l		FILE_ANFANG,a3
				move.l		a3,SYMBOL_VALUE+8*4
				move.l		a3,SYMBOL_VALUE+9*4
				move.l		a3,d0
				add.l		FILE_LAENGE,d0
				move.l		d0,SYMBOL_VALUE+10*4
				move.l		d0,SYMBOL_VALUE+11*4

*-------------------------------------------------------------------------------

* ---> A3 = ab hier auflisten
LIST_16:		move.l		ANZAHL_ZEILEN,d7
				lea			.LIST_16(PC),a6
				bra			PrintManager

.LIST_16:		bsr			ListLineRawDown
				adda.w		DisassemblyLength,a3
				move.l		a3,FIRST_ADRESS
				subq.l		#1,d7
				seq			d0
				tst.b		d0
				rts

*-------------------------------------------------------------------------------

FILE_LOAD_ERROR:bsr			FreeFile
				jsr			FCLOSE
				lea			FILELOAD_ERROR,a3
				bra			MessageRawDown_C

				MessageC	FILELOAD_ERROR,'The file couldn''t be loaded'

*---------------

FILE_LOAD_ERROR_2:
				move.l		d0,d7
				bsr			FreeFile
				jsr			FCLOSE
				lea			.message_1,a3
				cmpi.l		#-33,d7
				beq			MessageRawDown_C
				lea			.message_2,a3
				cmpi.l		#-39,d7
				beq			MessageRawDown_C
				lea			.message_3,a3
				cmpi.l		#-66,d7
				beq			MessageRawDown_C
				lea			FILELOAD_ERROR,a3
				bra			MessageRawDown_C

				MessageC	.message_1,'Program not found'
				MessageC	.message_2,'Not enough memory'
				MessageC	.message_3,'No GEMDOS program file'

*-------------------------------------------------------------------------------

FreeProgram:	tst.b		ProgramRuns
				bne.s		.cont
				rts
.cont:			movem.l		d0-a6,FREE_REGISTER	; Register sichern und neue
				move.w		sr,FREE_SR			; Stackpointer installieren
				move.l		usp,a0				; USP sichern/setzen
				move.l		a0,FREE_USP
				lea			_USER_USP,a0
				move.l		a0,usp
				move.w		#$2700,sr			; ISP sichern/setzen
				move.l		sp,FREE_ISP
				lea			_USER_ISP,sp
				move.w		#$3700,sr			; MSP sichern/setzen
				move.l		sp,FREE_MSP
				lea			_USER_MSP,sp
				move.w		#$300,sr
				st			ProgramIsFreed		; Programm freigeben
				clr.w		-(sp)				; Programm beenden
				trap		#1

*---------------

FreeFile:		movem.l		d0-a6,-(sp)
				move.l		FILE_ANFANG,-(sp)	; Speicher freigeben
				jsr			MFREE
				moveq		#0,d1				; Variablen lîschen
				move.l		d1,FILE_ANFANG
				move.l		d1,FILE_LAENGE
				move.l		d1,FILE_TEXT
				move.l		d1,FILE_TEXT_LAENGE
				move.l		d1,FILE_DATA
				move.l		d1,FILE_DATA_LAENGE
				move.l		d1,FILE_BSS
				move.l		d1,FILE_BSS_LAENGE
				clr.b		FILE_NAME
				move.l		#-1,PRG_FLAGS
				movea.l		SYMBOL_TABLE_3,a0	; Symboltabelle 3 lîschen
				move.l		ANZAHL_SYMBOLE_3,d0
				bra.s		.entry
.clear:			move.l		d1,(a0)+
.entry:			dbra		d0,.clear
				movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

PRINT_FILEINFO:	lea			FEHLER_ADRESSEN,a1

				tst.b		FILE_NAME
				beq			.ende
				lea			.FILE_MESSAGE_NAME,a3	; Filename
				bsr			MessageDown_C

				move.l		FILE_LAENGE,d7			; ganzes File
				movea.l		FILE_ANFANG,a0
				lea			.FILE_MESSAGE_ANFANG,a3
				bsr			.printen

				move.l		FILE_TEXT_LAENGE,d7		; TEXT-Segment
				movea.l		FILE_TEXT,a0
				lea			.FILE_MESSAGE_TEXT,a3
				bsr			.printen

				move.l		FILE_DATA_LAENGE,d7		; DATA-Segment
				movea.l		FILE_DATA,a0
				lea			.FILE_MESSAGE_DATA,a3
				bsr			.printen

				move.l		FILE_BSS_LAENGE,d7		; BSS-Segment
				movea.l		FILE_BSS,a0
				lea			.FILE_MESSAGE_BSS,a3
				bsr			.printen

				move.l		ANZAHL_SYMBOLE_1,d7		; Symboltabelle
				movea.l		SYMBOL_TABLE_1,a0
				lea			.FILE_MESSAGE_SYMBOL,a3
				bsr			.printen

				move.l		PRG_FLAGS,d0			; Programmflags auswerten
				cmpi.l		#-1,d0
				beq.s		.ende
				btst		#0,d0					; Fastload?
				beq.s		.no_fast
				lea			.FASTLOAD,a3
				bsr			MessageDown_C
.no_fast:		btst		#1,d0					; TT-Ram?
				beq.s		.no_ttload
				lea			.LOAD_TT_RAM,a3
				bsr			MessageDown_C
.no_ttload:		btst		#2,d0					; TT-Malloc?
				beq.s		.no_ttmalloc
				lea			.MALLOC_TT_RAM,a3
				bsr			MessageDown_C
.no_ttmalloc:	lea			.MEMORY_PRIVATE,a3
				andi.b		#$f0,d0
				beq.s		.mode_found
				lea			.MEMORY_GLOBAL,a3
				cmpi.b		#$10,d0
				beq.s		.mode_found
				lea			.MEMORY_SUPER,a3
				cmpi.b		#$20,d0
				beq.s		.mode_found
				lea			.MEMORY_READABLE,a3
				cmpi.b		#$30,d0
				bne.s		.test_sharedmem
.mode_found:	bsr			MessageDown_C
.test_sharedmem:btst		#12,d0					; Shared Memory?
				beq.s		.ende
				lea			.SHARED_MEMORY,a3
				bsr			MessageDown_C

.ende:			rts

*---------------

* ---> d7.l = Number
* ---> a0.l = Adresse
* ---> a3.l = Message
.printen:		tst.l		d7
				beq.s		.zero
				move.l		a0,(a1)			; FEHLER_ADRESSEN
				bsr.s		.PrintDezimal
				bra			MessageDown_C
.zero:			rts

.PrintDezimal:	movem.l		d3/a2,-(sp)
				move.l		d7,d3
				lea			27(a3),a2
				bsr			PRINT_DEZ
				clr.b		(a2)
				movem.l		(sp)+,d3/a2
				rts

*---------------

				MessageC	.FILE_MESSAGE_ANFANG,'Programstart:   $  Length: 1234567890'
				MessageC	.FILE_MESSAGE_TEXT,'TEXT-Segment:   $  Length: 1234567890'
				MessageC	.FILE_MESSAGE_DATA,'DATA-Segment:   $  Length: 1234567890'
				MessageC	.FILE_MESSAGE_BSS,'BSS-Segment:    $  Length: 1234567890'
				MessageC	.FILE_MESSAGE_SYMBOL,'Symboltable:    $  Number: 1234567890'
				MessageC	.FASTLOAD,'- Fastloadbit is set'
				MessageC	.LOAD_TT_RAM,'- Program may load into alternative RAM'
				MessageC	.MALLOC_TT_RAM,'- Malloc calls may be satisfied from alternative RAM'
				MessageC	.MEMORY_PRIVATE,'- Privatemode: only the process itself (and the OS) can use the memory'
				MessageC	.MEMORY_GLOBAL,'- Globalmode: the memory is totally unprotected'
				MessageC	.MEMORY_SUPER,'- Supermode: the memory can be accessed by anybody in Super mode'
				MessageC	.MEMORY_READABLE,'- Private-/Readablemode: anybody can read, nobody else can write'
				MessageC	.SHARED_MEMORY,'- Program has shared memory'
		.DATA
.FILE_MESSAGE_NAME:	dc.b	'Filename:       '
FILE_NAME:			ds.b	256
		.TEXT

*-------------------------------------------------------------------------------

_SAVE:			jsr			ExpandFile
				jsr			GetNextValue			; Start?
				bgt			NumberError
				bne.s		.no_start
				move.l		d3,d6					; d6 = Fileanfang
				jsr			GetNextValue			; End?
				bne			NumberError
				move.l		d3,d7
				sub.l		d6,d7					; d7 = FilelÑnge
				bgt.s		.start_end_io
				rts
.no_start:		move.l		FILE_ANFANG,d6			; d6 = Fileanfang
				beq			NumberError
				move.l		FILE_LAENGE,d7			; d7 = FilelÑnge
				beq			NumberError
.start_end_io:	movem.l		d0/a2,SAVE_POSITION
				movea.l		a3,a2					; File
				jsr			FDELETE					; lîschen
				jsr			FCREATE					; und neu erzeugen
				bmi.s		.error
				movea.l		d6,a3					; a3 = Fileanfang
				move.l		d7,d3					; d3 = FilelÑnge
				jsr			FWRITE					; Datei schreiben
				bne.s		.error
				jmp			FCLOSE

.error:			jsr			FCLOSE
				lea			.FILESAVE_ERROR,a3
				bra			MessageRawDown_C

				MessageC	.FILESAVE_ERROR,'The file couldn''t be written'

*-------------------------------------------------------------------------------

_NEWFORMAT:		tst.b		SCREEN_LOCK
				bne			NOT_AVAILABLE
				st			SCREEN_LOCK
				jsr			SHOW_PROGRAMM
				bsr			CLEAR_SCREEN
				bsr			GET_PARAMETER
				bsr			NEW_FORMAT
				cmpi.w		#3,FONT_FLAG
				beq.s		.font_io
				cmpi.w		#16,ZEILEN_SCREEN
				bhs.s		.font_io
				move.w		#3,FONT_FLAG
				bsr			NEW_FORMAT
.font_io:		bsr			PRINT_SCREEN
				clr.w		X_POSITION
				move.w		FIRST_LINE,Y_POSITION
				bsr			POSITIONIEREN
				sf			SCREEN_LOCK
				sf			PRINT_NEW_LINE			; keine neue Zeile printen
				bsr			ListPC
				sf			KEEP_SCREEN
				jmp			SHOW_DEBUGGER

*-------------------------------------------------------------------------------

_OBSERVE:		cmpi.b		#'-',(a2)+
				bne.s		.kein_minus
				subq.w		#1,d0
				sf			OBSERVE_FLAG
				bra.s		.observe_print

.kein_minus:	cmpi.b		#'+',-(a2)
				bne.s		.kein_plus
				addq.w		#1,a2					; O +
				subq.w		#1,d0
				move.w		OBSERVE_COUNT,d3
				addq.w		#1,d3
				bra.s		.check_length

.kein_plus:		jsr			GetFirstValue
				bgt			NumberError
				bne.s		.no_address
				move.l		d3,OBSERVE_ADDRESS		; O Address
				jsr			GetNextValue
				bgt			NumberError
				beq.s		.check_length			; ---> O Address,Bytes
				move.w		OBSERVE_COUNT,d3		; O Address
				addq.w		#1,d3
				bra.s		.check_length

.no_address:	jsr			GetNextValue
				bgt			NumberError
				bmi.s		.observe_print			; O (sonst O ,Bytes --> cont)

*---------------

.check_length:	cmpi.w		#1024,d3
				bhi.s		.overflow
				tst.w		d3
				bhi.s		.length_io
.overflow:		st			Ueberlauf
				bra			NumberError
.length_io:		subq.w		#1,d3
				move.w		d3,OBSERVE_COUNT
				movea.l		OBSERVE_ADDRESS,a0
				lea			OBSERVE_SAVE,a1
.copy:			move.b		(a0)+,(a1)+
				dbra		d3,.copy
				st			OBSERVE_FLAG

*---------------

.observe_print:	bsr			Umlenkung
				tst.b		OBSERVE_FLAG
				bne.s		.cont
				lea			.OBSERVE_OFF,a3
				bra			MessageDown_C
.cont:			clr.w		FEHLER_ADRESSEN
				move.w		OBSERVE_COUNT,FEHLER_ADRESSEN+2
				addq.w		#1,FEHLER_ADRESSEN+2
				move.l		OBSERVE_ADDRESS,FEHLER_ADRESSEN+4
				lea			.OBSERVE_STATE,a3
				bra			MessageDown_C

				MessageC	.OBSERVE_STATE,'Observing $ byte(s) at address $'
				MessageC	.OBSERVE_OFF,'Observe off'

*-------------------------------------------------------------------------------

_MKDIR: 		jsr			ExpandFile
				movem.l		d0/a2,SAVE_POSITION
				movea.l		a3,a2
				jmp			DCREATE

*-------------------------------------------------------------------------------

_PAGE:			bsr			Umlenkung
				st			BreakFlag
				movea.l		$42e.w,a0				; PHYSTOP
.loop:			lea			-$200(a0),a0
				cmpa.w		#$400,a0
				bls.s		.ende
				cmpi.l		#$12123456,(a0)
				bne.s		.loop
				cmpa.l		4(a0),a0
				bne.s		.loop
				moveq		#0,d0
				move.w		#255,d1
				movea.l		a0,a1
.check:			add.w		(a1)+,d0
				dbra		d1,.check
				cmpi.w		#$5678,d0
				bne.s		.loop
				move.l		a0,FEHLER_ADRESSEN
				lea			.PAGE_MESSAGE,a3
				bsr			MessageDown_C
				bra.s		.loop
.ende:			sf			BreakFlag
				rts

				MessageC	.PAGE_MESSAGE,'Resident program at $'

*-------------------------------------------------------------------------------

_PROGRAMS:		bsr			Umlenkung
				move.l		RES_SYMDRIVER,d0
				bne.s		.cont
				rts
.cont:			movea.l		d0,a0
				st			d6						; keine Leerzeile am Anfang
				cmpi.w		#$118,(a0)
				shi			d7						; MiNT?
				addq.w		#4,a0
				lea			.PROGRAMS(pc),a6
				bra			PrintManager

*---------------

.PROGRAMS:		tst.l		(a0)
				beq			.ende
				movea.l		(a0),a0
				tst.b		(a0)
				beq			.ende

				tst.b		d6						; Leerzeile?
				bne.s		.firstline
				lea			NULL_BYTE,a3
				bsr			MessageDown_C
.firstline:		sf			d6

				lea			.PROGRAMS_NAME,a3		; Programmname
				lea			15(a3),a2
				moveq		#13,d4
				tst.b		d7
				beq.s		.copy
				moveq		#15,d4
.copy:			move.b		(a0)+,(a2)+
				dbra		d4,.copy
				bsr			RawMessageDown_C

				move.l		26(a0),FEHLER_ADRESSEN	; Basepage
				lea			.PROGRAMS_BASEPAGE,a3
				bsr			MessageDown_C

				move.l		18(a0),FEHLER_ADRESSEN	; TEXT Segment
				lea			.PROGRAMS_TEXT,a3
				bsr			MessageDown_C

				move.l		22(a0),d3				; ProgrammlÑnge
				sub.l		26(a0),d3
				lea			.PROGRAMS_LENGTH,a3
				lea			14(a3),a2
				bsr			PRINT_DEZ
				clr.b		(a2)
				bsr			MessageDown_C

				moveq		#0,d3					; Anzahl Symbole
				move.w		(a0),d3
				lea			.PROGRAMS_SYMBOLS,a3
				lea			14(a3),a2
				bsr			PRINT_DEZ
				clr.b		(a2)
				bsr			MessageDown_C

				lea			30(a0),a0
				moveq		#0,d0
				rts
.ende:			moveq		#-1,d0
				rts

*---------------

				MessageC	.PROGRAMS_NAME,' Name:         1234567890123456'
				MessageC	.PROGRAMS_BASEPAGE,'Basepage:     $'
				MessageC	.PROGRAMS_TEXT,'TEXT-Segment: $'
				MessageC	.PROGRAMS_LENGTH,'Length:       1234567890'
				MessageC	.PROGRAMS_SYMBOLS,'Symbols:      1234567890'

*-------------------------------------------------------------------------------

_QUIT:			bsr			FreeProgram
				bsr			FreeFile
				jsr			GetFirstValue
				bgt			NumberError
				beq.s		.value_io
				moveq		#0,d3
				tst.b		RESIDENT_FLAG
				beq.s		.value_io
				moveq		#-1,d3
.value_io:		move.w		d3,QUIT_WERT
				movem.l		d0/a2,SAVE_POSITION
				bsr			HoldTheLine
				sf			KEEP_SCREEN
				tst.b		RESIDENT_FLAG			; residente Version?
				bne.s		.resident

				jsr			UntrapVektor

.resident:		move.l		#_USER_USP,SAVE_USP
				move.l		#_USER_ISP,SAVE_ISP
				move.l		#_USER_MSP,SAVE_MSP
				move.w		#$300,SAVE_STATUS
				move.l		#.QUITEN,SAVE_PC
				bra			GOTO_PROGRAM
.QUITEN:		move.w		QUIT_WERT,-(sp)
				move.w		#$4c,-(sp)
				trap		#1						; PTERM

*-------------------------------------------------------------------------------

_WRITESECTOR:	moveq		#9,d7
				bsr.s		XBIOS_8_9
				bne.s		ReadWriteError
				rts

*---------------

_READSECTOR:	moveq		#8,d7
				bsr.s		XBIOS_8_9
				bne.s		ReadWriteError
				bra			PRINT_SEKTOR

*---------------

ReadWriteError:	lea			.RW_FEHLER,A3
				bra			MessageRawDown_C

				MessageC	.RW_FEHLER,'Sector can''t be read/written'

*---------------

XBIOS_8_9:		jsr			GetFirstValue
				bgt			NumberError
				bne.s		.no_track
				move.w		d3,RW_TRACK
.no_track:		jsr			GetNextValue
				bgt			NumberError
				bne.s		.no_sector
				move.w		d3,RW_SECTOR
.no_sector:		jsr			GetNextValue
				bgt			NumberError
				bne.s		.no_side
				move.w		d3,RW_SIDE
.no_side:		jsr			GetNextValue
				bgt			NumberError
				bne.s		.no_address
				move.l		d3,RW_ADRESSE
.no_address:	jsr			GetNextValue
				bgt			NumberError
				bne.s		.no_drive
				move.w		d3,RW_DEVICE
.no_drive:		bsr			Umlenkung

				movea.l		sp,a6				; a6 = Stackpointer
				move		sr,d6				; d6 = Statusregister
				move		#$2300,sr
				lea			_STACK_OS,sp

				move.w		#1,-(sp)
				move.w		RW_SIDE,-(sp)
				move.w		RW_TRACK,-(sp)
				move.w		RW_SECTOR,-(sp)
				move.w		RW_DEVICE,-(sp)
				clr.l		-(sp)
				move.l		RW_ADRESSE,-(sp)
				move.w		d7,-(sp)
				trap		#14
				lea			20(sp),sp

				move.w		d6,sr
				movea.l		a6,sp

				tst.w		d0
				rts

*---------------

PRINT_SEKTOR:	move.l		RW_ADRESSE,FEHLER_ADRESSEN
				lea			.SEKTOR_MESSAGE,a3
				bra			MessageDown_C

				MessageC	.SEKTOR_MESSAGE,'Sectorbuffer:   $'

*-------------------------------------------------------------------------------

_REGISTER:		bsr			GetRegister
				bsr			Umlenkung
				subq.w		#1,d3
				bmi.s		.show_all

*---------------

				lea			.REG_MESSAGE,a3			; R Register
				moveq		#0,d0
				moveq		#0,d1
.copy:			move.b		(a0)+,d0
				move.b		d0,d1
				andi.b		#%1111,d0
				lsr.w		#4,d1
				move.b		.table(pc,d1.w),(a3)+
				move.b		.table(pc,d0.w),(a3)+
				dbra		d3,.copy
				clr.b		(a3)
				lea			.REG_MESSAGE,a3
				bra			MessageDown_C

				MessageC	.REG_MESSAGE,'1234567812345678'

.table:			dc.b		'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'

*--------------

.show_all:		st			BreakFlag
				lea			FEHLER_ADRESSEN,a0

				movem.l		DATEN_REGISTER,d0-d2/d4-d7/a1
				movem.l		d0-d2/d4,(a0)
				lea			.REGISTER_DN_1,a3
				bsr			MessageDown_C			; d0-d3

				movem.l		d5-d7/a1,(a0)
				lea			.REGISTER_DN_2,a3
				bsr			MessageDown_C			; d4-d7

				movem.l		ADRESS_REGISTER,d0-d2/d4-d7/a1
				movem.l		d0-d2/d4,(a0)
				lea			.REGISTER_AN_1,a3
				bsr			MessageDown_C			; a0-a3

				movem.l		d5-d7/a1,(a0)
				lea			.REGISTER_AN_2,a3
				bsr			MessageDown_C			; a4-a7

				move.l		SAVE_PC,(a0)
				move.l		SAVE_USP,4(a0)
				move.l		SAVE_ISP,8(a0)
				clr.w		12(a0)
				move.w		SAVE_STATUS,14(a0)
				lea			.REGISTER_STACK,a3
				bsr			MessageDown_C			; PC/USP/ISP/SR

				tst.b		CPU
				beq			.ende

				lea			FEHLER_ADRESSEN,a0
				move.l	    SAVE_SFC,(a0)
				move.l	    SAVE_DFC,4(a0)
				move.l	    SAVE_VBR,8(a0)
				lea			.REGISTER_10_40,a3
				bsr			MessageDown_C			; SFC/DFC/VBR

				cmpi.b		#1,CPU
				bls			.ende
				cmpi.b		#2,CPU
				beq.s		.MC68020_30
				cmpi.b		#3,CPU
				bne.s		.not_20_30

.MC68020_30:	move.l	    SAVE_CAAR,(a0)
				lea			.REGISTER_20_30,a3
				bsr			MessageDown_C			; CAAR

.not_20_30:		move.l		SAVE_MSP,(a0)
				move.l		SAVE_CACR,4(a0)
				lea			.REGISTER_20_40,a3
				bsr			MessageDown_C			; MSP/CACR

				cmpi.b		#2,CPU
				beq			.ende
				cmpi.b		#3,CPU
				bne.s		.MC68040

				move.l		SAVE_SRP,(a0)
				move.l		SAVE_SRP+4,4(a0)
				move.l		SAVE_TC_30,8(a0)
				clr.w		12(a0)
				move.w		SAVE_MMUSR,14(a0)
				lea			.REGISTER_30_1,a3
				bsr			MessageDown_C			; SRP/TC/MMUSR

				move.l		SAVE_CRP,(a0)+
				move.l		SAVE_CRP+4,(a0)+
				move.l		SAVE_TT0,(a0)+
				move.l		SAVE_TT1,(a0)
				lea			.REGISTER_30_2,a3
				bsr			MessageDown_C			; CRP/TT0/TT1
				bra.s		.ende

.MC68040:		move.l		SAVE_SRP,(a0)
				clr.w		4(a0)
				move.w		SAVE_TC_40,6(a0)
				clr.w		8(a0)
				move.w		SAVE_MMUSR,10(a0)
				lea			.REGISTER_40_1,a3
				bsr			MessageDown_C			; SRP/TC/MMUSR

				move.l		SAVE_URP,(a0)+
				move.l		SAVE_DTT0,(a0)+
				move.l		SAVE_DTT1,(a0)+
				move.l		SAVE_ITT0,(a0)+
				move.l		SAVE_ITT1,(a0)+
				lea			.REGISTER_40_2,a3
				bsr			MessageDown_C			; URP/DTT0/DTT1/ITT0/ITT1

.ende:			sf			BreakFlag
				rts

*---------------

				MessageC	.REGISTER_DN_1,'D0-D3 $ $ $ $'
				MessageC	.REGISTER_DN_2,'D4-D7 $ $ $ $'
				MessageC	.REGISTER_AN_1,'A0-A3 $ $ $ $'
				MessageC	.REGISTER_AN_2,'A4-A7 $ $ $ $'
				MessageC	.REGISTER_STACK,'PC=$ USP=$ ISP=$ SR=$'
				MessageC	.REGISTER_10_40,'10-40: SFC=$ DFC=$ VBR=$'
				MessageC	.REGISTER_20_30,'20-30: CAAR=$'
				MessageC	.REGISTER_20_40,'20-40: MSP=$ CACR=$'
				MessageC	.REGISTER_30_1,'30-40: SRP=$ $  TC=$ MMUSR=$'
				MessageC	.REGISTER_30_2,'30: CRP=$ $  TT0=$ TT1=$'
				MessageC	.REGISTER_40_1,'30-40: SRP=$  TC=$ MMUSR=$'
				MessageC	.REGISTER_40_2,'40: URP=$ DTT0=$ DTT1=$ ITT0=$ ITT1=$'

*-------------------------------------------------------------------------------

_RESIDENT:		movem.l		d0/a2,SAVE_POSITION
				lea			.RESIDENT_ERROR,a3	; Programm schon resident?
				tst.b		RESIDENT_FLAG
				bne			MessageRawDown_C
				bsr			HoldTheLine
				st			RESIDENT_FLAG
				sf			KEEP_SCREEN
				bsr			FreeProgram			; File freigeben
				bsr			FreeFile
				jsr			InstallCookie		; Cookie installieren
				clr.b		DisassemCPU			; CPU testen
				jsr			TestCPU
				move.b		d0,CPU
				bset		d0,DisassemCPU
				jsr			TestFPU				; FPU testen
				move.b		d0,FPU
				beq.s		.cont
				bset		#6,DisassemCPU
.cont:			bsr			INSTALL_PAGE		; Doppelseite installieren
				move.l		#_USER_USP,SAVE_USP
				move.l		#_USER_ISP,SAVE_ISP
				move.l		#_USER_MSP,SAVE_MSP
				move.w		#$300,SAVE_STATUS
				move.l		#.keep_resident,SAVE_PC
				bra			GOTO_PROGRAM

.keep_resident:	clr.w		-(sp)
				move.l		ProgrammLength,-(sp)
				move.w		#49,-(sp)
				trap		#1					; und Programm resident halten

				MessageC	.RESIDENT_ERROR,'This function isn''t available in the resident version'

*-------------------------------------------------------------------------------

_COLD:			clr.l		MEMVALID.w
				clr.l		MEMVAL2.w
				clr.l		MEMVAL3.w
				clr.l		RESVALID.w
				jsr			UntrapVektor
				bra.s		RESETEN

*---------------

_WARM:			move.l		#$752019F3,MEMVALID.w
				move.l		#$237698AA,MEMVAL2.w
				move.l		#$5555AAAA,MEMVAL3.w

RESETEN:		st			DO_A_RESET
				move.l		_SYSBASE.w,a0
				move.l		4(a0),SAVE_PC			; OS_START
				ori.w		#$2700,SAVE_STATUS
				bra			GOTO_PROGRAM

*-------------------------------------------------------------------------------

_RMDIR: 		jsr			ExpandFile				; Pfad holen ---> a3
				movem.l		d0/a2,SAVE_POSITION
				movea.l		a3,a2
				jsr			DDELETE					; Directory lîschen
				bpl.s		.io
				jmp			FDELETE					; File lîschen
.io:			rts

*-------------------------------------------------------------------------------

_SHOWMEMORY:	moveq		#ANZAHL_SHOW-1,d7
				lea			SHOW_RECORD,a0
				move.w		d0,d1
				movea.l		a2,a6
				jsr			GetFirstValue
				beq			.term_io				; Term io
				bmi			.show_it				; keine Zahl --> Sh

				move.w		d1,d0
				movea.l		a6,a2
				moveq		#0,d3					; erste Shownumber
				cmpi.b		#'-',(a2)				; Sh - ?
				beq.s		.kill_all
				jsr			CalcNumber				; Sh Number ?
				bne			NumberError
				cmpi.b		#'-',(a2)				; Sh Number - ?
				sne			NoNumber
				bne			NumberError
				tst.w		d3						; 0<=Number<ANZAHL_SHOW ?
				bmi			.show_ueberlauf
				cmpi.w		#ANZAHL_SHOW-1,d3
				bhi			.show_ueberlauf
				mulu		#MENUE_LENGTH+2,d3
				lea			(a0,d3.l),a0
				moveq		#0,d7					; nur ein Show lîschen

*---------------

.kill_all:		addq.w		#1,a2
				subq.w		#1,d0
				movem.l		d0/a2,SAVE_POSITION
.kill_loop:		move.w		Y_POSITION,d0	; Sh [Number]-
				tst.b		(a0)
				beq.s		.dont_kill
				clr.b		(a0)
				subq.w		#1,SHOW_ANZAHL
				subq.w		#1,SAVE_Y_POSITION
				bsr			Calc_FIRST_LINE
				bsr			SCROLL_DOWN_C
				cmp.w		FIRST_LINE,d0
				blo.s		.dont_kill
				subq.w		#1,d0
.dont_kill:		move.w		d0,Y_POSITION
				lea			MENUE_LENGTH+2(a0),a0
				dbra		d7,.kill_loop
				bra			POSITIONIEREN

*---------------

.term_io:		sub.w		d0,d1				; Sh Term[,List]
				moveq		#1,d6				; Default List
				jsr			GetNextValue
				bgt			NumberError
				bmi.s		.search
				move.b		d3,d6				; Sh Term,List
				ble.s		.show_ueberlauf
				cmpi.b		#4,d6
				bhi.s		.show_ueberlauf
				subq.b		#2,d6

.search:		bsr			Umlenkung
.search_loop:	tst.b		(a0)				; freien Platz suchen
				beq.s		.found
				lea			MENUE_LENGTH+2(a0),a0
				dbra		d7,.search_loop
.ende:			rts

.found:			st			(a0)+				; Eintrag erzeugen
				move.b		d6,(a0)+
				move.w		MENUE_LENGTH,d0
				bra.s		.compress
.copy:			tst.b		(a6)+
				beq.s		.compress
				cmpi.b		#32,-1(a6)
				beq.s		.compress
				move.b		-1(a6),(a0)+
				subq.w		#1,d0
.compress:		dbra		d1,.copy
				bra.s		.entry
.clear:			move.b		#32,(a0)+
.entry:			dbra		d0,.clear
				bsr			SCROLL_UP
				addq.w		#1,SHOW_ANZAHL
				addq.w		#1,SAVE_Y_POSITION
				bsr			Calc_FIRST_LINE
				addq.w		#1,Y_POSITION
				bra			POSITIONIEREN

*---------------

.show_ueberlauf:st			Ueberlauf
				bra			NumberError

*---------------

.show_it:		bsr			Umlenkung		; Sh
				lea			.show(pc),a6
				bra			PrintManager

.show:			movea.l		a0,a1
				tst.b		(a1)+
				beq.s		.no_term
				lea			.show_string+1(pc),a3	; String erzeugen
				move.b		#32,(a3)+
				move.b		d7,(a3)
				subi.b		#ANZAHL_SHOW-1,(a3)
				neg.b		(a3)
				addi.b		#'0',(a3)+				; Nummer
				move.b		#',',(a3)+				; ,
				move.b		(a1)+,(a3)
				addi.b		#'0'+2,(a3)+			; Listflag
				move.b		#':',(a3)+				; :
				move.w		#MENUE_LENGTH-1,d0
.create: 		move.b		(a1)+,(a3)+				; String
				dbra		d0,.create
				lea			.show_string(pc),a3
				bsr			RawMessageDown_P		; Printen
.no_term:		lea			MENUE_LENGTH+2(a0),a0
				subq.w		#1,d7
				smi			d0
				tst.b		d0
				rts

.show_string:	dc.b		MENUE_LENGTH+5
				ds.b		MENUE_LENGTH+5
		.EVEN

*-------------------------------------------------------------------------------

_SLOW:			cmpi.b		#'-',(a2)+
				bne.s		.kein_minus
				subq.w		#1,d0					; S -
				sf			SLOW_MODE
				bra.s		.show
.kein_minus:	cmpi.b		#'+',-(a2)
				bne.s		.show
				addq.w		#1,a2					; S +
				subq.w		#1,d0
				st			SLOW_MODE

.show:			bsr			Umlenkung
				lea			.SLOW_OFF_MESSAGE,a3
				tst.b		SLOW_MODE
				beq.s		.off
				lea			.SLOW_ON_MESSAGE,a3
.off:			bra			MessageDown_C

*---------------

				MessageC	.SLOW_ON_MESSAGE,'Slowmode on'
				MessageC	.SLOW_OFF_MESSAGE,'Slowmode off'

*-------------------------------------------------------------------------------

_SWITCH:		cmpi.b		#3,VDO				; nur ST/STE/TT
				blo.s		.cont
				rts

.cont:			jsr			GetFirstValue
				bgt			NumberError
				bne			.only_program
				movem.l		d0/a2,SAVE_POSITION

				st			Ueberlauf
				tst.l		d3
				bmi			NumberError
				cmpi.l		#7,d3
				bhi			NumberError
				lea			ResolutionTT,a6
				cmpi.b		#2,VDO
				beq.s		.TT_VIDEO_1
				cmpi.l		#3,d3
				bhi			NumberError
				lea			ResolutionST,a6
.TT_VIDEO_1:	lsl.l		#3,d3
				movem.w		(a6,d3.l),d0-d3
				tst.w		d0
				beq			NumberError

				tst.b		SCREEN_LOCK
				bne			NOT_AVAILABLE
				st			SCREEN_LOCK
				jsr			SHOW_PROGRAMM
				cmpi.b		#2,VDO
				beq.s		.TT_VIDEO_2
				move.b		d3,SET_SHIFTMD_ST
				bra.s		.ST_VIDEO
.TT_VIDEO_2:	move.w		d3,SET_SHIFTMD_TT
.ST_VIDEO:		sf			SCREEN_LOCK

.only_program:	jsr			GetNextValue
				bgt			NumberError
				bne.s		.ende

				cmpi.b		#2,VDO
				beq.s		.SWITCH_TT
				sf			KEEP_SCREEN
				jsr			SHOW_DEBUGGER
				move.b		d3,SAVE_SHIFTMODE
				jsr			SHOW_PROGRAMM
.ende:			movem.l		d0/a2,SAVE_POSITION
				jmp			SHOW_DEBUGGER

.SWITCH_TT:		lsl.w		#8,d3				; $X ---> $X00
				sf			KEEP_SCREEN
				jsr			SHOW_DEBUGGER
				move.w		d3,SAVE_SHIFTMODE
				jsr			SHOW_PROGRAMM
				bra.s		.ende

*-------------------------------------------------------------------------------

_SYMBOL:		jsr			GetFirstValue
				bgt			NumberError
				beq.s		.from_io
				moveq		#0,d3				; [From] default = 0
.from_io:		move.l		d3,d6				; d6 = [From]
				jsr			GetNextValue
				bgt			NumberError
				beq.s		.to_io
				moveq		#-1,d3				; [,To] default = -1
.to_io:			bsr			Umlenkung
				move.l		d6,d0				; d0 = [From]
				move.l		d3,d1				; d1 = [,To]
				lea			.SYMBOL(pc),a6
				bra			PrintManager

.SYMBOL:		jsr			SEARCH_WITHIN
				beq.s		.ende
				lea			.SYMBOL_MESSAGE,a2
				move.b		#32,(a2)+
				move.l		d0,d3
				bsr			PRINT_HEXADEZIMAL
				move.b		#32,(a2)+
				move.b		#'=',(a2)+
				move.b		#32,(a2)+
				move.w		MENUE_LENGTH,d2
.copy:			move.b		(a0)+,(a2)+
				dbeq		d2,.copy
				clr.b		(a2)
				addq.l		#1,d0
				lea			.SYMBOL_MESSAGE,a3
				bsr			RawMessageDown_C
				moveq		#0,d4
				rts
.ende: 			moveq		#-1,d4
				rts

		.BSS
.SYMBOL_MESSAGE:ds.b		MENUE_LENGTH+2
		.EVEN
		.TEXT

*-------------------------------------------------------------------------------

_SYSINFO:		bsr			Umlenkung
				st			BreakFlag

				move.l		#VDI_VERSION,.SysinfoMessage+28
				jsr			TestNVDI
				beq.s		.gdos
				tst.b		GDOS_INSTALLED
				beq.s		.no_gdos
.gdos:			move.l		#VDI_VERSION_1,.SysinfoMessage+28

.no_gdos:		movea.l		$4f2.w,a0
				lea			.SysinfoMessage,a1
				lea			FEHLER_ADRESSEN,a2

				move.l		(a1)+,a3
				move.l		8(a0),(a2)
				bsr			MessageDown_C			; OSBASE

				movea.l		(a1)+,a3
				move.l		4(a0),(a2)
				bsr			MessageDown_C			; OSSTART

				movea.l		(a1)+,a3
				move.l		12(a0),(a2)
				bsr			MessageDown_C			; OSMEMBOT

				movea.l		(a1),a3
				lea			18(a3),a3
				move.l		#'NTSC',(a3)+
				movea.l		8(a0),a5
				move.w		28(a5),d0
				BTST		#0,d0
				beq.s		.NTSC
				move.l		#'PAL ',-(a3)
				addq.w	    #3,a3
.NTSC:			lsr.w		#1,d0
				andi.w		#15,d0
				lsl.w		#2,d0
				lea			LAENDER_KENNUNG,a5
				lea			(a5,d0.w),a5
				move.b		(a5)+,(a3)+
				move.b		(a5)+,(a3)+
				move.b		(a5)+,(a3)+
				move.b		(a5)+,(a3)+
				move.b		#32,(a3)+
				movea.l		(a1)+,a3
				lea			29(a3),a6
				move.b		2(a0),d0
				moveq		#1,d7
				bsr.s		.PRINT_BCD				; TOS-Version
				addq.w		#3,a6
				move.b		3(a0),d0
				bsr.s		.PRINT_BCD				; TOS-Version
				addq.w		#4,a6
				move.b		25(a0),d0
				bsr.s		.PRINT_BCD				; TOS-Datum
				addq.w		#3,a6
				move.b		24(a0),d0
				bsr.s		.PRINT_BCD				; TOS-Datum
				addq.w		#5,a6
				move.w		26(a0),d0
				moveq		#3,d7
				bsr.s		.PRINT_BCD				; TOS-Datum
				bsr			MessageDown_C

				movea.l		(a1)+,a3
				bsr			MessageDown_C			; GEMDOS-Version

				movea.l		(a1)+,a3
				bsr			MessageDown_C			; METADOS-Version

				lea			AES_VERSION+20,a6
				moveq		#1,d7
				move.b		GLOBAL,d0
				bsr.s		.PRINT_BCD
				addq.w		#3,a6
				move.b		GLOBAL+1,d0
				bsr.s		.PRINT_BCD
				movea.l		(a1)+,a3
				bsr			MessageDown_C			; AES-Version

				movea.l		(a1)+,a3
				bsr			MessageDown_C			; VDI-Version
				sf			BreakFlag
				rts

*---------------

.PRINT_BCD:		movem.l		d0-a6,-(sp)
.loop:			moveq		#15,d1
				and.l		d0,d1
				lsr.l		#4,d0
				addi.b		#48,d1
				move.b	    d1,-(a6)
				dbra		d7,.loop
				movem.l		(sp)+,d0-a6
				rts

*---------------

		.DATA
.SysinfoMessage:dc.l		OSBASE,OSSTART,OSMEMBOT,OSVERSION,GEMDOS_VERSION
				dc.l		METADOS_VERSION,AES_VERSION,VDI_VERSION

				MessageC	OSBASE,'OS_Base:          $'
				MessageC	OSSTART,'OS_Start:         $'
				MessageC	OSMEMBOT,'OS_Membot:        $'
				MessageC	OSVERSION,'TOS-Version:      NTSC-SWG 00.00, 00.00.0000'
				MessageC	GEMDOS_VERSION,'GEMDOS-Version:   --.--'
				MessageC	AES_VERSION,'AES-Version:      --.--'
				MessageC	METADOS_VERSION,'METADOS-Version:  Metados not installed'
				MessageC	METADOS_VERSION_1,'METADOS-Version:  123456789012345678901234567890'
				MessageC	VDI_VERSION,'VDI-Version:      no GDOS installed'
				MessageC	VDI_VERSION_1,'VDI-Version:      GDOS installed'

*---------------

		.DATA
LAENDER_KENNUNG:dc.b		'-USA'
				dc.b		'-BRD'
				dc.b		'-FRA'
				dc.b		'-UK '
				dc.b		'-SPA'
				dc.b		'-ITA'
				dc.b		'-SWE'
				dc.b		'-SWF'
				dc.b		'-SWG'
				dc.b		'-TUR'
				dc.b		'-FIN'
				dc.b		'-NOR'
				dc.b		'-DEN'
				dc.b		'-SAU'
				dc.b		'-HOL'
				dc.b		'-FRG'
		.TEXT

*-------------------------------------------------------------------------------

_TRACE:			move.b		(a2)+,d1
				cmpi.b		#'*',d1
				beq.s		.trace_all
				cmpi.b		#'-',d1
				beq.s		.trace_minus
				cmpi.b		#'+',d1
				beq.s		.trace_plus
		 		cmpi.b		#'/',d1
				beq.s		.trace_reset
				subq.w		#1,a2
				jsr			GetFirstValue
				bgt			NumberError
				beq.s		.trace_number
				moveq		#1,d3						; Trace
.trace_number:	addq.l		#1,d3
				move.l	    d3,TRACE_ZAEHLER
				bsr.s		.DoIt						; Trace Number
				bra			FTASTE1
.trace_all:		bset		#TRACE_ALL,TRACE_MODUS_1	; Trace *
				bra.s		.trace_plus
.trace_minus:	bset		#TRACE_MINUS,TRACE_MODUS_1	; Trace -
				bra.s		.cont
.trace_plus:	bset		#TRACE_PLUS,TRACE_MODUS_1	; Trace +
.cont:			subq.w		#1,d0
				bsr.s		.DoIt
				bra			GOTO_PROGRAM
.trace_reset:	subq.w		#1,d0						; Trace /
				bsr.s		.DoIt
				move.l		#USER_TRACE,USERTRACE
				rts

.DoIt:			movem.l		d0/a2,SAVE_POSITION
				bra			HoldTheLine

*-------------------------------------------------------------------------------

_XBRA:			sf			d7					; keine Parameter
				sf			d6
				lea			$8.w,a5				; Startvektor
				lea			$1000.w,a1			; Endvektor
				jsr			GetFirstValue
				bgt			NumberError
				bne.s		.no_first			; [FirstVector] ?
				st			d6
				st			d7					; mit Parameter
				movea.l		d3,a5				; a5 = [Firstvector]
.no_first:		jsr			GetNextValue
				bgt			NumberError
				bne.s		.no_last
				sf			d6
				st			d7					; mit Parameter
				movea.l		d3,a1				; a1 = [,LastVector]
.no_last:		move.l		#_XBRA,d5			; wenn d5 = #_XBRA ---> keine ID
				jsr			GetNextValue
				bgt			NumberError
				bne.s		.no_id
				sf			d6
				st			d7					; mit Parameter
				move.l		d3,d5				; d5 = ID
.no_id:			tst.b		d6					; wenn nur FirstVector, dann gilt
				beq.s		.morethan_first		; LastVector=FirstVector
				movea.l		a5,a1				; a1 = [,LastVector]
.morethan_first:tst.b		d7
				bne			.WITH_PARAMETER

*---------------
*-------------- Vektoren nach ID's durchsuchen

				bsr			Umlenkung
				cmpi.w		#12,BILD_BREITE		; Screen zu schmal?
				bhs.s		.breite_io
				rts

.breite_io:		moveq		#100,d0				; d0 = 100-Anzahl Kennungen
				move.w		#($1000-8)/2-1,d1	; SchleifenzÑhler
				link		a0,#-4*100			; Platz fÅr 100 Kennungen
				lea			8.w,a1				; Anfangsadresse
				pea			.vector_fail(pc)
				bsr			TestBusOn
.xbra_loop_2:	movea.l		(a1),a2				; erste Routine holen

* Vektor testen
				moveq		#99,d3				; hîchstens 100 Links
.xbra_loop_1:	cmpi.l		#'XBRA',-12(a2)		; Routinen testen
				bne.s		.cont

* ID schon vorhanden?
				move.l		-8(a2),d4
				movea.l		a0,a3				; gefundene Kennungen
				moveq		#99,d5
				sub.w		d0,d5				; SchleifenzÑhler
				bmi.s		.new_id
.xbra_loop_0:	cmp.l		(a3)+,d4			; ID's testen
				beq.s		.no_new_id
				dbra		d5,.xbra_loop_0

.new_id:		move.l		d4,-(a0)			; neue Kennung eintragen
				subq.w		#1,d0				; ZÑhler-1
				beq.s		.no_more_ids		; schon 100 ID's?
.no_new_id:		movea.l		-(a2),a2			; neuer XBRA Link
				dbra		d3,.xbra_loop_1
				bra.s		.cont

.vector_fail:	pea			.vector_fail(pc)	; falls Bus-/Addresserror
				bsr			TestBusOn			; auftritt
.cont:			addq.w		#2,a1				; nÑchster Vektor
				dbra		d1,.xbra_loop_2
				bsr			TestBusOff
				addq.w		#4,sp

*-------------- ID's Sortieren

.no_more_ids:	subi.w		#99,d0
				bls.s		.id_found
				rts
.id_found:		neg.w		d0

				move.w		d0,d1				; jetzt ID's sortieren
				movea.l		a0,a1				; mit Minimumsort
.sort:			move.l		(a1),d3				; Kennung holen
				move.w		d1,d2
				movea.l		a1,a2
.search:		cmp.l		(a2)+,d3			; hîchsten Wert suchen
				bls.s		.dont_change
				move.l		-(a2),d4			; Werte vertauschen
				move.l		d3,(a2)+
				move.l		d4,d3
.dont_change:	dbra		d2,.search
				move.l		d3,(a1)+			; kleinste Kennung schreiben
				dbra		d1,.sort

*-------------- Printen vorbereiten und PrintManager aufrufen

				moveq		#0,d7
				move.w		BILD_BREITE,d7
				subq.w		#5,d7
				divu		#7,d7
				cmp.w		#ANZAHL_ADRESSEN,d7
				bls.s		.anzahl_io
				moveq		#ANZAHL_ADRESSEN,d7
.anzahl_io:		lea			.XBRA_ALL,a3
				lea			.PRINT_XBRA(pc),a6
				bsr			PrintManager
				unlk		a0
				rts

*-------------- Sortierte Liste printen

* d0 = Anzahl ID's
* d7 = Maximale Anzahl Vektoren pro Zeile
* a0 = ID-Liste
* a3 = XBRA_ALL
.PRINT_XBRA:	move.l		(a0),d5				; ID holen
				lea			2(a3),a2
				move.b		(a0)+,(a2)+			; ID schreiben
				move.b		(a0)+,(a2)+
				move.b		(a0)+,(a2)+
				move.b		(a0)+,(a2)+
				move.b		#':',(a2)+
				move.b		#32,(a2)+

				lea			8.w,a5				; Anfangsvektor
				move.w		#($1000-8)/2-1,d1	; SchleifenzÑhler
				move.w		d7,d4
.print_loop:	bsr			.Test_ID			; enthÑlt der Vektor
				bne.s		.next_vector		; die Kennung?
				move.l		a5,d3
				bsr			PRINT_HEXADEZIMAL
				move.b		#',',(a2)+
				move.b		#32,(a2)+
				subq.w		#1,d4
				bne.s		.next_vector
				subq.w		#3,a2
				move.l		a2,d6				; Zeile printen
				sub.l		a3,d6
				move.b		d6,(a3)				; LÑnge eintragen
				bsr			RawMessageDown_P
				move.w		d7,d4				; und auf neuer Zeile starten
				lea			2(a3),a2
				moveq		#32,d6
				move.b		d6,(a2)+
				move.b		d6,(a2)+
				move.b		d6,(a2)+
				move.b		d6,(a2)+
				move.b		d6,(a2)+
				move.b		d6,(a2)+
.next_vector:	addq.w		#2,a5				; nÑchster Vektor
				dbra		d1,.print_loop

				sub.w		d7,d4				; Rest der Zeile
				beq.s		.ende				; nichts mehr Åbrig?
				subq.w		#3,a2
				move.l		a2,d6				; Zeile printen
				sub.l		a3,d6
				move.b		d6,(a3)				; LÑnge eintragen
				bsr			RawMessageDown_P
.ende:			subq.w		#1,d0				; schone alle ID's?
				smi			d4
				tst.b		d4
				rts

*---------------
*---------------

.WITH_PARAMETER:bsr			Umlenkung

				suba.l		a0,a0				; VBR testen
				tst.b		CPU
				beq.s		.no_MC68000
				dc.w		$4e7a,$8801			; movec VBR,a0
.no_MC68000:	move.l		a0,FEHLER_ADRESSEN
				beq.s		.no_VBR
				lea			.XBRA_VBR,a3
				bsr			MessageDown_C

.no_VBR: 		st			d6					; zuerst keine Leerzeile
				lea			.XBRA_STEP(PC),a6
				st			BreakFlag
				bsr.s		.XBRA_START
				sf			BreakFlag
				bpl			PrintManager
				rts

*-------------- Titelzeile ausgeben, erste Routine holen

.XBRA_START:	cmpi.l		#_XBRA,d5			; keine gÅltige ID?
				beq.s		.take_it
				bsr			.Test_ID
				bne			.SearchNextXBRA
.take_it:		tst.b		d6					; erste Zeile?
				bne.s		.first_line			; ja dann keine Leerzeile
				lea			NULL_BYTE,a3		; zuerst Mal ne Leerzeile
				bsr			MessageDown_C

.first_line:	sf			d6					; ab jetzt immer Leerzeilen
				move.l		a5,FEHLER_ADRESSEN	; Vektoradresse
				lea			.XBRA_TITEL,a3		; Titelzeile ausgeben

				movem.l		d3/a0/a2,-(sp)
				move.l		a5,d3
				jsr			SEARCH_SYMBOL
				beq.s		.symbol_fail
				lea			PrintPuffer,a2
.copy1:			move.b		(a3)+,(a2)+
				bne.s		.copy1
				move.b		#32,-2(a2)
				move.b		#'=',-1(a2)
				move.b		#32,(a2)+
				move.b		#'.',(a2)+
.copy2:			move.b		(a0)+,(a2)+
				bne.s		.copy2
				move.b		#':',-1(a2)
				clr.b		(a2)
				lea			PrintPuffer,a3
.symbol_fail:	movem.l		(sp)+,d3/a0/a2
				bsr			MessageDown_C

				movea.l		a5,a0				; a0 = p Vector = erste Routine
				pea			.cont_start(pc)
				bsr			TestBusOn
				movea.l		(a5),a0				; erste Routine holen
				bsr			TestBusOff
				addq.w		#4,sp

.cont_start:	cmpa.l		#$8,a5				; TestBus-Routine geholt?
				bne.s		.no_bus_1
				movea.l		OLD_TEST_BUS,a0
.no_bus_1:		cmpa.l		#$c,a5
				bne.s		.no_address_1
				movea.l		OLD_TEST_ADRESS,a0

.no_address_1:	moveq		#100,d7				; d7 = ZÑhler wegen Endlosloop
				moveq		#0,d0				; und weitermachen
				rts

*-------------- Link printen, nÑchste Verkettung holen

.XBRA_STEP:		lea			XBRA_MESSAGE,a3		; nÑchste Verkettung suchen
				subq.w		#1,d7				; 100 Verkettungen...
				beq			.too_many
				pea			.fertig(PC)
				bsr			TestBusOn			; isses XBRA?
				cmpi.l		#'XBRA',-12(a0)
				beq			.cont_xbra
				bsr			TestBusOff
				addq.w		#4,sp
				bra			.fertig

.cont_xbra:		moveq		#7,d2
				move.l		a0,d3				; Vektor eintragen
				lea			2(a3),a2
				bsr			PRINT_HEX

				lea			13(a3),a2			; ID eintragen
				lea			-8(a0),a4
				move.b		(a4)+,(a2)+
				move.b		(a4)+,(a2)+
				move.b		(a4)+,(a2)+
				move.b		(a4)+,(a2)+

				lea			38(a3),a2			; gesuchte ID?
				move.b		#32,(a2)
				cmp.l		-(a4),d5
				bne.s		.not_same_ID
				move.b		#4,(a2)
.not_same_ID:	move.b		#32,1(a2)			; innerhalb des Debuggers?
				cmpa.l		ProgrammStart,a0
				blo.s		.not_within
				cmpa.l		ProgrammEnde,a0
				bhs.s		.not_within
				move.b		#'*',1(a2)
				cmpi.b		#4,(a2)
				beq.s		.not_within
				move.b		#'*',(a2)
				move.b		#32,1(a2)

.not_within:	lea			29(a3),a2			; Link eintragen
				movea.l		a0,a4
				move.l		-(a0),a0			; nÑchster Link
				moveq		#7,d2
				move.l		a0,d3
				bsr			PRINT_HEX
				bsr			RawMessageDown_P
				bsr			TestBusOff
				addq.w		#4,sp
				cmpa.l		a0,a4
				beq.s		.endlos_schleife
				moveq		#0,d0
				rts

.endlos_schleife:								; Link auf sich selber
				lea			XBRA_FEHLER,a3
				lea			12(a3),a2
				subq.w		#8,a4				; Kennung
				move.b		(a4)+,(a2)+			; ID kopieren
				move.b		(a4)+,(a2)+
				move.b		(a4)+,(a2)+
				move.b		(a4)+,(a2)+
				bsr			RawMessageDown_P
				bra.s		.SearchNextXBRA

*-------------- zu viele Verkettungen

.too_many:		lea			.XBRA_FEHLER_2,a3	; mehr als 100 Verkettungen
				bsr			MessageDown_C
				bra.s		.SearchNextXBRA

*-------------- Ende der XBRA-Links gefunden

.fertig:		lea			.XBRA_WITHOUT,a3	; $7 without XBRA...
				move.l		a0,FEHLER_ADRESSEN	; --> XBRA-Kette unterbrochen
				bsr			MessageDown_C

*-------------- nÑchsten Vektor suchen

.SearchNextXBRA:addq.w		#1,a5				; a5 auf gerade Adresse bringen
				move.w		a5,d0
				andi.w		#1,d0
				bne.s		.SearchNextXBRA
				pea			.SearchNextXBRA(pc)
				bsr			TestBusOn
				movea.l		(a5),a0
				cmpi.l		#'XBRA',-12(a0)
				bsr			TestBusOff
				addq.w		#4,sp
				bne.s		.SearchNextXBRA
.cont_step:		cmpa.l		a5,a1				; Adresse<=Endadresse?
				bge			.XBRA_START			; dann neu starten
				moveq		#-1,d0				; sonst endgÅltig abbrechen
				rts

*---------------
*---------------

* ---> D5 = Kennung
* ---> A5 = Vektor
* flag.ne = nichts gefunden, flag.eq = gefunden
.Test_ID:		movem.l		d0-a6,-(sp)
				pea			.error(PC)
				bsr			TestBusOn
				move.l		a5,a0
				move.l		(a5),a5				; erste Routine holen
				cmpa.l		#$8,a0				; Busvektor?
				bne.s		.no_bus_2
				movea.l		OLD_TEST_BUS,a5
.no_bus_2:		cmpa.l		#$c,a0				; Addressvektor?
				bne.s		.no_address_2
				movea.l		OLD_TEST_ADRESS,a5
.no_address_2:	moveq		#99,d7				; maximal 100 Verkettungen
.ID_loop:		cmpi.l		#'XBRA',-12(a5)		; XBRA?
				bne.s		.not_found
				cmp.l		-8(a5),d5			; ID gefunden?
				beq.s		.found
				movea.l		-(a5),a5			; nÑchster XBRA-Link
				dbra		d7,.ID_loop
.not_found:		bsr			TestBusOff
				addq.w		#4,sp
.error:			moveq		#-1,d0
				movem.l		(sp)+,d0-a6
				rts
.found:			bsr			TestBusOff
				addq.w		#4,sp
				moveq		#0,d0
				movem.l		(sp)+,d0-a6
				rts

*---------------

		.DATA
.XBRA_ALL:		dc.b		0,' PBUG: $12345678'
			.REPT ANZAHL_ADRESSEN-1
				dc.b		', $12345678'
			.ENDM
				MessageC	.XBRA_VBR,'ATTENTION: the VectorBaseRegister points to $!'
				MessageC	.XBRA_TITEL,'XBRA links for $:'
				MessageC	.XBRA_WITHOUT,'$ without XBRA'
				MessageC	.XBRA_FEHLER_2,'Warning: more than 100 routines are linked, probably there is something wrong?'

				MessageP	XBRA_MESSAGE,' $12345678 "PBUG" points to $12345678-*'
				MessageP	XBRA_FEHLER,' Warning: "PBUG" points to itself!'

*-------------------------------------------------------------------------------

_FRAGEZEICHEN:	lea			.puffer,a5
				jsr			GetFirstValue
				bgt.s		.error
				bmi.s		.no_number
.getnext:		clr.w		(a5)+
				move.l		d3,(a5)+
				jsr			GetNextValue
				beq.s		.getnext
				bmi.s		.no_number
.error:			move.w		#1,(a5)+
				move.l		d3,(a5)+
				bra.s		.cont
.no_number:		move.w		#-1,(a5)+
				move.l		d3,(a5)+

.cont:			bsr			Umlenkung
				lea			.puffer,a5
				lea			.FRAGEZEICHEN(pc),a6
				bra			PrintManager

*---------------

.FRAGEZEICHEN:	tst.w		(a5)+
				bne			.ende
				move.l		(a5)+,d3

				lea			PrintPuffer+1,a3

				move.b		#32,(a3)+			; Hexadezimal
				move.b		#'$',(a3)+
				moveq		#7,d6
				moveq		#16,d2
				bsr			.wandeln

				move.b		#32,(a3)+			; Dezimal
				move.b		#'.',(a3)+
				moveq		#9,d6
				moveq		#10,d2
				bsr			.wandeln

				move.b		#32,(a3)+			; BinÑr
				move.b		#'%',(a3)+
				moveq		#31,d6
				moveq		#2,d2
				bsr			.wandeln

				move.b		#32,(a3)+			; Oktal
				move.b		#'o',(a3)+
				moveq		#10,d6
				moveq		#8,d2
				bsr			.wandeln

				move.b		#32,(a3)+			; ASCII
				move.b		#'"',(a3)+
				moveq		#3,d4
.ascii_loop:	rol.l		#8,d3
				move.b		d3,(a3)+
				dbra		d4,.ascii_loop
				move.b		#'"',(a3)+

				bsr.s		.printen

				tst.l		d3
				bpl.s		.continue

				neg.l		d3
				lea			PrintPuffer+1,a3
				move.b		#32,(a3)+			; - Hexadezimal
				move.b		#'-',(a3)+
				move.b		#'$',(a3)+
				moveq		#7,d6
				moveq		#16,d2
				bsr.s		.wandeln

				move.b		#32,(a3)+			; - Dezimal
				move.b		#'-',(a3)+
				move.b		#'.',(a3)+
				moveq		#9,d6
				moveq		#10,d2
				bsr.s		.wandeln

				bsr.s		.printen

.continue:		moveq		#0,d1
				rts

*---------------

.ende:			bpl.s		.fehler
				rts
.fehler:		movem.l		SAVE_POSITION,d0/a2
				bsr			NumberError
				moveq		#-1,d1
				rts

*---------------

.printen:		move.l		a3,d0
				lea			PrintPuffer,a3
				sub.l		a3,d0
				subq.b		#1,d0
				move.b		d0,(a3)
				bra			RawMessageDown_P

*---------------

.wandeln:		tst.l		d3
				bne.s		.not_zero
				move.b		#'0',(a3)+
				rts
.not_zero:		movem.l		d0-a2/a5,-(sp)
				link		a6,#-32
				movea.l		a6,a5
				move.w		d6,d5
.loop:			jsr			LongDivu
				cmp.b		#9,d1
				bls.s		.number
				add.b		#'A'-'0'-10,d1
.number:		add.b		#'0',d1
				move.b		d1,-(a5)
				dbra		d6,.loop
.loop_shorten:	cmpi.b		#'0',(a5)+
				dbne		d5,.loop_shorten
				beq.s		.all_zero
				subq.w		#1,a5
.copy:			move.b		(a5)+,(a3)+
				dbra		d5,.copy
.all_zero:		unlk		a6
				movem.l		(sp)+,d0-a2/a5
				rts

*---------------

		.BSS
.puffer:		ds.b		MENUE_LENGTH*3
		.TEXT

*-------------------------------------------------------------------------------

_ASSEMBLER:		movea.l		FIRST_ADRESS,a1
				jsr			Assembler
				beq.s		.fail
				bgt.s		.buserror
				st			LIST_FLAG
				move.l		a1,a3
				bra			PRINT_NEXT_LINE
.buserror:		bsr.s		.set_a2
				lea			SPEICHER_BEREICH,a3
				bra			MessageRawDown_C
.fail:			bsr.s		.set_a2
				lea			SYNTAX_FEHLER,a3
				bra			MessageRawDown_C

.set_a2:		lea			1(a2,d0.w),a2
				moveq		#-1,d0
				movem.l		d0/a2,SAVE_POSITION
				rts

				MessageC	SPEICHER_BEREICH,'Access fault exception (Bus error)'

*-------------------------------------------------------------------------------

_SLASH: 		sf			LIST_FLAG
				moveq		#2,d1				; Default Word
				bra.s		SLASH_EINSTIEG

*---------------

_KOMMA: 		move.b		#1,LIST_FLAG
				moveq		#0,d1				; kein Default
SLASH_EINSTIEG: jsr			GetLength
				bmi			LengthError
				beq.s		.default
				move.w		d3,d1				; d1=LÑnge, Input fÅr GetTerm_2
.default:		jsr			GetTerm_2
				bmi			NumberError
				movea.l		FIRST_ADRESS,a0
				bra.s		.entry
.loop:			move.b		(a3)+,(a0)+
.entry:			dbra		d7,.loop
.listen:		movea.l		FIRST_ADRESS,a3
				bra			PRINT_NEXT_LINE

*-------------------------------------------------------------------------------

_DOPPELPUNKT:	jsr			GetFirstValue
				bne			NumberError
				movea.l		d3,a0				; a0 = Address
				jsr			GetTerm				; Der String ist Nullterminiert
				bmi			NumberError
				movem.l		d0/a2,SAVE_POSITION
				bra.s		.entry
.loop:			move.b		(a3)+,(a0)+
.entry:			dbra		d7,.loop
				rts

*-------------------------------------------------------------------------------

_KLAMMER:		cmpi.b		#'"',(a2)			; Stringanfang?
				beq.s		.cont
				cmpi.b		#"'",(a2)
				bne.s		.missing
.cont:			lea			(a2,d0.w),a0		; Stringende?
				cmpi.b		#'"',(a0)
				beq.s		.found
				cmpi.b		#"'",(a0)
				beq.s		.found
.missing:		lea			.STRING_FEHLER,a3
				bra			MessageRawDown_C

.found:			addq.w		#1,a2
				movea.l		FIRST_ADRESS,a3
				subq.w		#2,d0
				bmi.s		.empty
.loop:			move.b		(a2)+,(a3)+			; kopieren
				dbra		d0,.loop
.empty:			move.b		#2,LIST_FLAG
				movea.l		FIRST_ADRESS,a3
				bra			PRINT_NEXT_LINE

				MessageC	.STRING_FEHLER,'" or '' is missing'

*-------------------------------------------------------------------------------

_DISASSEMBLE:	cmpi.b		#':',(a2)
				bne			NOT_CPU

				addq.w		#1,a2				; d:
				subq.w		#1,d0
				jsr			GetFirstValue
				bgt			NumberError
				bmi.s		.ohne_CPU

				move.l		#%1011111,d2		; d:CPUs
				and.l		d3,d2
				cmp.l		d3,d2
				sne			Ueberlauf
				bne			NumberError
				move.b		D3,DisassemCPU

.ohne_CPU:		bsr			Umlenkung
				move.b		DisassemCPU,d3		; CPUs printen
				beq.s		.StrangeCPU
				moveq		#4,d0
				moveq		#'0',d2
				lea			.CPU_MESSAGE_1+39,a3; CPU's eintragen
.loop:			lsr.w		#1,d3
				bcc.s		.not_set
				move.b		d2,(a3)
				addq.w		#3,a3
.not_set:		addq.w		#1,d2
				dbra		d0,.loop
				lsr.w		#2,d3				; FPU eintragen
				bcc.s		.no_FPU
				moveq		#%11111,d3			; nur FPU?
				and.b		DisassemCPU,d3
				bne.s		.MoreThanFPU
				lea			.CPU_MESSAGE_1+34,a3
.MoreThanFPU:	move.b		#'F',(a3)+
				move.b		#'P',(a3)+
				move.b		#'U',(a3)+
				addq.w		#1,a3
.no_FPU:		clr.b		-(a3)				; Stringende
				lea			.CPU_MESSAGE_1,a3
				bsr			MessageDown_C
				lea			.CPU_MESSAGE_2,a0
.copy:			move.b		(a0)+,(a3)+
				bne.s		.copy
				rts

.StrangeCPU:	lea			.STRANGE_MESSAGE,a3
				bra			MessageDown_C

				MessageC	.CPU_MESSAGE_1,'Disassembler/Assembler active for MC68000/10/20/30/40/FPU'
				MessageC	.CPU_MESSAGE_2,'Disassembler/Assembler active for MC68000/10/20/30/40/FPU'
				MessageC	.STRANGE_MESSAGE,'The Disassembler/Assembler will not disassemble/assemble any opcodes !?!'

*-------------------
*------------------ List, Disassemble, Dump, Ascii

NOT_CPU:		sf			LIST_FLAG
				bra.s		ANZEIGEN

_LIST:			st			LIST_FLAG
				bra.s		ANZEIGEN

_DUMP:			move.b		#1,LIST_FLAG
				bra.s		ANZEIGEN

_ASCII:			move.b		#2,LIST_FLAG

*-------------------

ANZEIGEN:		cmpi.b		#'.',(a2)			; Falls am Anfang ein . steht
				bne.s		.no_point			; und dann ein Fehler bei
				movem.l		d0/a2,-(sp)			; GetFirstValue auftritt,
				jsr			GetFirstValue		; wird der . als Endlosausgabe
				beq.s		.first_io			; interpretiert
				movem.l		(sp)+,d0/a2
				move.l		SAVE_PC,d3
				bra.s		.from_io
.first_io:		addq.w		#8,sp
				bra.s		.from_io

.no_point:		jsr			GetFirstValue
				bgt			NumberError
				beq.s		.from_io
				move.l		SAVE_PC,d3
.from_io:		movea.l		d3,a3				; a3 = [From]

				cmpi.b		#'.',(a2)			; Endlos?
				bne.s		.no_endlos
				moveq		#-1,d7				; d7 = Anzahl Zeilen
				subq.w		#1,d0
				addq.w		#1,a2
				bra.s		.LINES

.no_endlos:		cmpi.b		#'[',(a2)			; [Bytes]?
				bne.s		.no_bytes
				subq.w		#1,d0
				addq.w		#1,a2
				jsr			GetFirstValue
				bne			NumberError
				add.l		a3,d3
				cmpi.b		#']',(a2)
				bne.s		.LIMIT
				subq.w		#1,d0
				addq.w		#1,a2
				bra.s		.LIMIT

.no_bytes:		cmpi.b		#'#',(a2)			; #Lines?
				bne.s		.no_lines
				subq.w		#1,d0
				addq.w		#1,a2
				jsr			GetFirstValue
				bne			NumberError
				move.l		d3,d7				; d7 = Anzahl Zeilen
				bra.s		.LINES

.no_lines:		jsr			GetNextValue		; GetNextValue
				bgt			NumberError
				beq.s		.LIMIT
				move.l		ANZAHL_ZEILEN,d7

*---------------

.LINES:			bsr			Umlenkung
				lea			._LINES(PC),a6
				bra			PrintManager

._LINES:		bsr.s		.PRINTEN
				subq.l		#1,d7
				bne.s		.CONT
				bra.s		.BREAK

*---------------

.LIMIT:			bsr			Umlenkung
				movea.l		d3,a1				; a1 = [,To]
				cmpa.l		a3,a1
				bgt.s		.cont
				rts
.cont:			lea			._LIMIT(PC),a6
				bra			PrintManager

._LIMIT:		bsr.s		.PRINTEN
				cmpa.l		a3,a1
				bgt.s		.CONT

.BREAK:			moveq		#-1,d0
				rts
.CONT:			moveq		#0,d0
				rts

*---------------

.PRINTEN:		bsr			ListLineDown
				adda.w		DisassemblyLength,a3
				move.l		a3,FIRST_ADRESS
				rts

*-------------------------------------------------------------------------------
* PRINT_NEXT_LINE: Nachdem der Speicher verÑndert wurde, wird die aktuelle
*				   und die darauffolgende Zeile neu geprintet. D.h. weder die
*				   alte noch die neue Zeile muss neu geprintet werden.
*				   Wird nur von ! / , und ) benutzt.
* ---> A3.l = Ab dieser Adresse wird geprintet.
*-------------------------------------------------------------------------------

PRINT_NEXT_LINE:move.w		d3,-(sp)
				sf			PRINT_NEW_LINE			; weder neue noch alte Zeile printen
				move.w		Y_POSITION,d3
				bsr			ListLineRaw				; erste Zeile printen
				adda.w		DisassemblyLength,a3
				addq.w		#1,d3
				move.w		d3,Y_POSITION
				move.w		#12,X_POSITION
				bsr			POSITIONIEREN
				bsr			ListLineRaw				; nÑchste Zeile printen
				move.w		(sp)+,d3
				rts

*-------------------------------------------------------------------------------

TEST_CHEAT:		tst.b		CHEAT_MODE
				bne			.cont
				addq.w		#4,sp
.cont:			rts

*-------------------------------------------------------------------------------
* GetRegister: sucht nach einem Register
* <--- d2.l = Symbolnummer (0-...)
* <--- d3.l = LÑnge des gefundenen Registers oder 0
* <--- a0.l = Adresse des gefundenen Registers
*-------------------------------------------------------------------------------

GetRegister:	movem.l		d1/d4-d7/a1/a3-a6,-(sp)
				jsr			KillSpace
				bmi.s		.fail

				moveq		#ANZAHL_REGISTER-1,d2
				moveq		#0,d7
				lea			.REG_TABELLE_1(PC),a0
				lea			Convert,a1
.loop:			movea.l		a2,a3
.search_reg:	tst.b		(a0)						; end of string?
				beq.s		.found
				move.b		(a3)+,d7
				move.b		(a1,d7.w),d7				; Grossbuchstaben
				cmp.b		(a0)+,d7
				beq.s		.search_reg
.search_zero:	tst.b		(a0)+
				bne.s		.search_zero
				dbra		d2,.loop
.fail:			moveq		#0,d3
				movem.l		(sp)+,d1/d4-d7/a1/a3-a6
				rts

.found:			subi.w		#ANZAHL_REGISTER-1,d2
				neg.w		d2
				moveq		#0,d3
				move.b		.REG_TABELLE_2(pc,d2.w),d3	; d3 = LÑnge
				move.w		d2,d7
				add.w		d7,d7
				add.w		d7,d7
				movea.l		.REG_TABELLE_3(pc,d7.w),a0	; Adresse
				add.l		a2,d0
				movea.l		a3,a2
				sub.l		a2,d0						; neue StringlÑnge
				cmpi.w		#-1,d0						; < -1?
				blt.s		.fail
				cmpi.b		#4,CPU
				bne.s		.eight_allowed
				cmpi.b		#ANZAHL_REGISTER-1,d1
				bne.s		.no_TC
				moveq		#2,d3
				lea			SAVE_TC_40,a0
.no_TC:			cmpi.b		#8,d3
				bne.s		.eight_allowed
				moveq		#4,d3
.eight_allowed:	movem.l		(sp)+,d1/d4-d7/a1/a3-a6
				rts

*---------------

.REG_TABELLE_2:	dc.b	4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
				dc.b	8,4,4,4,4,4,4,4,4,4,4,4,2,1,2,8,4,4,4,4,4,4,4,2,4
		.EVEN

.REG_TABELLE_3:	dc.l	DATEN_REGISTER,DATEN_REGISTER+4,DATEN_REGISTER+8
				dc.l	DATEN_REGISTER+12,DATEN_REGISTER+16,DATEN_REGISTER+20
				dc.l	DATEN_REGISTER+24,DATEN_REGISTER+28
				dc.l	ADRESS_REGISTER,ADRESS_REGISTER+4,ADRESS_REGISTER+8
				dc.l	ADRESS_REGISTER+12,ADRESS_REGISTER+16,ADRESS_REGISTER+20
				dc.l	ADRESS_REGISTER+24,ADRESS_REGISTER+28
				dc.l	SAVE_SRP,SAVE_PC,SAVE_ISP,SAVE_MSP,SAVE_USP,SAVE_ISP
				dc.l	SAVE_A7,SAVE_SFC,SAVE_DFC,SAVE_VBR,SAVE_CAAR
				dc.l	SAVE_CACR,SAVE_STATUS,SAVE_STATUS+1,SAVE_MMUSR
				dc.l	SAVE_CRP
				dc.l	SAVE_TT0,SAVE_TT1,SAVE_ITT0,SAVE_ITT1,SAVE_DTT0
				dc.l	SAVE_DTT1,SAVE_URP,SAVE_MMUSR,SAVE_TC_30

.REG_TABELLE_1:	dc.b	'D0',0,'D1',0,'D2',0,'D3',0,'D4',0,'D5',0,'D6',0,'D7',0
				dc.b	'A0',0,'A1',0,'A2',0,'A3',0,'A4',0,'A5',0,'A6',0,'A7',0
				dc.b	'SRP',0,'PC',0,'ISP',0,'MSP',0,'USP',0,'SSP',0
				dc.b	'SP',0,'SFC',0,'DFC',0,'VBR',0,'CAAR',0,'CACR',0
				dc.b	'SR',0,'CCR',0,'MMUSR',0,'CRP',0,'TT0',0,'TT1',0
				dc.b	'ITT0',0,'ITT1',0,'DTT0',0,'DTT1',0,'URP',0
				dc.b	'PSR',0,'TC',0
		.EVEN

*-------------------------------------------------------------------------------
* NEW_HISTORY: reserviert einen neuen Historypuffer
* ---> 4(SP).l = Anzahl Bytes
* <--- 4(SP).l = 0 = Fehler beim reservieren, != 0 = alles io
*-------------------------------------------------------------------------------
NEW_HISTORY:	movem.l		d0-a6,-(sp)
				movea.l		64(sp),a0
				pea			(a0)
				jsr			MALLOC
				move.l		d0,64(sp)
				beq.s		.error
				move.l		d0,HISTORY_POINTER
				move.l		d0,HISTORY_READ
				move.l		d0,HISTORY_WRITE
				move.l		a0,HISTORY_LENGTH
.error:			movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------
* SET_PC: PrÅft ob sich der PC geÑndert hat und printen gegebenenfalls die
*		  Zeilen neu, die invers waren oder neu invers sein mÅssen. Muss immer
*		  dann aufgerufen werden, wenn der PC verÑndert worden sein kînnte.
*
* CLEAR_KEYBOARD: lîscht den IKBD- und MIDI-Puffer
*
* SearchUp: sucht nach einem Opcode in Richtung niedriger Adresse
* ---> A3.l = Startadresse
* <--- A3.l = gefundene Adresse
* <--- flag.ne = gefunden, flag.eq = nichts gefunden
*
* GET_KBSHIFT: Holt sich den aktuellen Status der Umschalttasten.
* <--- D0.l = Werte von KBSHIFT
*-------------------------------------------------------------------------------

SET_PC: 		movem.l		d0-d3,-(SP)
				move.l		OLD_PC,d1
				move.l		SAVE_PC,d2
				cmp.l		d1,d2				; PC unverÑndert?
				beq.s		.same_pc
				clr.l		OLD_PC
				move.w		ZEILEN_SCREEN,d3	; d3 = SchleifenzÑhler
				subq.w		#1,d3
.loop:			jsr			GET_ADRESS_1		; Zeilenadresse holen
				bne.s		.not_new
				cmp.l		d0,d1				; wenn alter inverser PC
				bne.s		.not_old
				bsr			PRINT_LINE			; dann Zeile printen
.not_old: 		cmp.l		d0,d2				; oder neuer aktueller PC
				bne.s		.not_new
				bsr			PRINT_LINE			; dann Zeile printen
.not_new: 		subq.w		#1,d3
				cmp.w		FIRST_LINE(pc),d3
				bhs.s		.loop
.same_pc:		movem.l		(sp)+,d0-d3
				rts

*-------------------------------------------------------------------------------

CLEAR_KEYBOARD: move.l		a0,-(sp)
				movea.l		KBSHIFT,a0
				clr.b		(a0)
				movea.l		IOREC_IKBD,a0
				clr.l		6(a0)
				movea.l		(sp)+,a0
				rts

*-------------------------------------------------------------------------------

CHEAT_KEY:		tst.b		CHEAT_MODE
				bne			CHEAT_KEYBOARD
				rts

*-------------------------------------------------------------------------------

SearchUp:		MOVEM.L		d0-a1,-(SP)
				MOVEQ		#GENAUIGKEIT-1,D1			; BefehlslÑnge rÅckwÑrts
				LEA			OpcodeLength(pc),A1			; ermitteln
.loop1:			SUBQ.W		#2,A3						; Adresse
				jsr			DisassemLength				; d0=LÑnge, a0=DisassemblyArray
				MOVE.W		D0,(A1)+
				DBRA		D1,.loop1

				MOVEQ		#2<<(GENAUIGKEIT-2)-1,D0
.loop2:			LEA			OpcodeLength(pc),A0
				MOVEQ		#GENAUIGKEIT-1,D1
				MOVE.W		D0,D2
				MOVEQ		#0,D3
				MOVEQ		#0,D4
.loop3:			ADDQ.W		#2,D4
				LSR.W		#1,D2
				BCS.S		.Ausblenden
				CMP.W		(A0),D4
				BNE.S		.FalscheKombination
				ADD.W		(A0),D3
				MOVEQ		#0,D4
.Ausblenden:	ADDQ.W		#2,A0
				DBRA		D1,.loop3
				CMP.W		#2*GENAUIGKEIT,D3
.FalscheKombination:
				DBEQ		D0,.loop2
				BNE.S		NICHT_GEFUNDEN

				MOVEQ		#0,D1
NOCH_NICHT:		ADDQ.W		#2,D1
				LSR.W		#1,D0
				BCS.S		NOCH_NICHT
				NEG.W		D1
				LEA			(A3,D1.w),A3
				LEA			2*GENAUIGKEIT(A3),A3
				moveq		#-1,d0
				MOVEM.L		(SP)+,d0-a1
				RTS
NICHT_GEFUNDEN: LEA			2*GENAUIGKEIT-2(A3),A3
				moveq		#0,d0
				MOVEM.L		(SP)+,d0-a1
				RTS

OpcodeLength:	ds.w		GENAUIGKEIT

*-------------------------------------------------------------------------------

NOT_AVAILABLE:	move.l		a3,-(sp)
				lea			.AVAILABLE_ERROR,A3
				bsr			MessageRawDown_C
				movea.l		(sp)+,a3
				rts

				MessageC	.AVAILABLE_ERROR,'This function is locked at the moment'

*-------------------------------------------------------------------------------

* ---> A3.l = Adresse
* <--- A3.l = next position
NEXT_HISTORY:	movem.l		d0-a2/a5-a6,-(sp)
				movea.l		HISTORY_POINTER,a0
				adda.l		HISTORY_LENGTH,a0
				adda.w		ZEILEN_LAENGE,a3
				cmpa.l		a3,a0
				bhi.s		.next
				movea.l		HISTORY_POINTER,a3
.next:			movem.l		(sp)+,d0-a2/a5-a6
				rts

*-------------------------------------------------------------------------------

GET_KBSHIFT:	movem.l	d1-d2/a0-a2,-(SP)
				pea		$bffff
				trap	#13							; KBSHIFT 11
				addq.w	#4,sp
				movem.l	(sp)+,d1-d2/a0-a2
				rts

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

* setzt a7 (SAVE_A7) auf den Wert des aktuellen Stackpointers (gemÑss SR)
GET_SP:			move.l		SAVE_USP,SAVE_A7		; USP
				btst		#5,SAVE_STATUS
				beq.s		.ende
				move.l		SAVE_ISP,SAVE_A7		; ISP
				cmpi.b		#2,CPU
				blo.s		.ende
				btst		#4,SAVE_STATUS
				beq.s		.ende
				move.l		SAVE_MSP,SAVE_A7		; MSP
.ende:			rts

*-------------------------------------------------------------------------------

* setzt den aktuellen Stackpointer (gemÑss SR) auf den Wert von a7 (SAVE_A7)
PUT_SP:			move.l		a0,-(sp)
				lea			SAVE_USP,a0
				btst		#5,SAVE_STATUS		; Interruptstackpointer?
				beq.s		.ende
				lea			SAVE_ISP,a0
				cmpi.b		#2,CPU
				blo.s		.ende
				btst		#4,SAVE_STATUS		; Masterstackpointer?
				beq.s		.ende
				lea			SAVE_MSP,a0
.ende:			move.l		SAVE_A7,(a0)
				move.l		(sp)+,a0
				rts

*-------------------------------------------------------------------------------

BPT_LOESCHEN:	 MOVEM.L     D0/A0-A1,-(SP)
		LEA	    BREAK_POINT,A0
		MOVEQ	    #ANZAHL_BREAKPOINTS+5,D0
BPT_CLEAR:	TST.L	    (A0)
		BEQ.S	    NICHT_LOESCHEN
		MOVEA.L     (A0),A1
		CMPI.W	    #ILLEGAL_OPCODE,(A1)
		BNE.S	    NICHT_ILLEGAL
		PEA	    NICHT_ILLEGAL(PC)
		BSR	    TestBusOn
		MOVE.W	    14(A0),(A1)
		BSR	    TestBusOff
		ADDQ.W	    #4,SP
NICHT_ILLEGAL:	CMPI.W	    #2,12(A0)
		BLO.S	    NICHT_LOESCHEN	   ; Permanent und ZÑhler
		BNE.S	    NO_ANZAHL
		TST.L	    8(A0)		  ; Anzahl
		BNE.S	    NICHT_LOESCHEN
NO_ANZAHL:	CLR.L	    (A0)
NICHT_LOESCHEN:  LEA	     16(A0),A0
		DBRA	    D0,BPT_CLEAR
		MOVEM.L     (SP)+,D0/A0-A1
		RTS

*-------------------------------------------------------------------------------

BPT_SETZEN:	LEA	    BREAK_POINT,A0
		MOVE.W	    #4,12(A0)
		MOVE.W	    #4,12+16(A0)
		MOVE.W	    #4,12+2*16(A0)
		MOVE.W	    #4,12+3*16(A0)
		MOVE.W	    #3,12+4*16(A0)
		MOVE.W	    #3,12+5*16(A0)
		MOVEQ	    #ANZAHL_BREAKPOINTS+5,D0
SETZEN_SCHLEIFE:TST.L	    (A0)
		BEQ	    CONT_BPT

		MOVEA.L     (A0),A1
		MOVE.W	    (A1),14(A0) 	  ; Opcode holen
		PEA	    IST_IM_ROM(PC)
		BSR	    TestBusOn
		MOVE.W	    #ILLEGAL_OPCODE,(A1)
		BSR	    TestBusOff
		ADDQ.W	    #4,SP

		CMPA.L	    SAVE_PC,A1
		SEQ	    TRACE_MODUS_3
		MOVE.L	    #PERMANENT_RAM,4(A0)
		TST.W	    12(A0)		  ; Permanentbpt
		BLE.S	    CONT_BPT
		CMPI.W	    #4,12(A0)		  ; Gemdos/Gem/Bios/Xbios
		BEQ.S	    CONT_BPT
		CMPI.W	    #3,12(A0)		  ; DO/GO
		BEQ.S	    CONT_BPT
		MOVE.L	    #ZAEHLER_RAM_1,4(A0)   ; ZÑhler_ram
		CMPI.W	    #1,12(A0)
		BEQ.S	    CONT_BPT
		MOVE.L	    #ANZAHL_RAM_1,4(A0)
		BRA.S	    CONT_BPT

IST_IM_ROM:
		st	    TRACE_MODUS_3
		MOVE.L	    #PERMANENT_ROM,4(A0)
		TST.W	    12(A0)		  ; Bedingungsbpt
		BLE.S	    CONT_BPT
		CMPI.W	    #4,12(A0)		  ; Gemdos/Gem/Bios/Xbios
		BEQ.S	    CONT_BPT
		CMPI.W	    #3,12(A0)		  ; DO/GO
		BEQ.S	    CONT_BPT
		MOVE.L	    #ZAEHLER_ROM,4(A0)	   ; ZÑhler_rom
		CMPI.W	    #1,12(A0)
		BEQ.S	    CONT_BPT
		MOVE.L	    #ANZAHL_ROM,4(A0)

CONT_BPT:	LEA	    16(A0),A0
		DBRA	    D0,SETZEN_SCHLEIFE
		RTS

*-------------------------------------------------------------------------------

RESET_VECTORS:	move.l		#USER_TRACE,USERTRACE		; Vektoren installieren
				move.l		#USER_ENTER,USERENTER
				move.l		#USER_QUIT,USERQUIT
				move.l		#USER_SWITCH_1,USERSWITCH_1
				move.l		#USER_SWITCH_2,USERSWITCH_2
				move.l		#USER_RESET,USERRESET
				rts

*-------------------------------------------------------------------------------

CHEAT_ON:		move.w		#$700,STATUS
				st			CHEAT_MODE
				rts

CHEAT_OFF:		move.w		#$500,STATUS
				sf			CHEAT_MODE
				rts

CHEAT_TEST:		tst.b		CHEAT_MODE
				rts

*-------------------------------------------------------------------------------

				MessageC	CALL_MESSAGE_1,'Called by CALL_DEBUGGER_1. Continue with Quit.'
				dc.l		CALL_MESSAGE_1
CALL_DEBUGGER_1:MOVE.W	    (SP)+,SAVE_STATUS
		JSR	    CREATE_FRAME_PC
		MOVE.W	    SAVE_STATUS,-(SP)
		BSR	    GOTO_DEBUGGER
		MOVE.L	    #_USER_USP,SAVE_USP
		MOVE.L	    #_USER_ISP,SAVE_ISP
		MOVE.L	    #_USER_MSP,SAVE_MSP
		BSR	    GET_SP
		jsr			CACHE_PUT
		MOVEA.L     CALL_DEBUGGER_1-4(PC),A3
		BSR	    PRINT_ERROR
		MOVE.L	    #CALL_MESSAGE_1,CALL_DEBUGGER_1-4
		BRA	    EDITOR

*---------------

				MessageC	CALL_MESSAGE_2,'Called by CALL_DEBUGGER_2. Continue with GoPC.'
				dc.l		CALL_MESSAGE_2
CALL_DEBUGGER_2:MOVE.W	    (SP)+,SAVE_STATUS
		JSR	    CREATE_FRAME_PC
		MOVE.W	    SAVE_STATUS,-(SP)
		BSR	    GOTO_DEBUGGER
		MOVEA.L     CALL_DEBUGGER_2-4(PC),A3
		BSR	    PRINT_ERROR
		MOVE.L	    #CALL_MESSAGE_2,CALL_DEBUGGER_2-4
		BRA	    EDITOR

*---------------

				MessageC	CALL_MESSAGE_SYSMON,'Called by Sysmon. Continue with GoPC.'
				dc.l		CALL_MESSAGE_SYSMON
CALL_SYSMON:	MOVE.L	    (SP)+,SAVE_PC
		st	    SUPERVISOR
		ILLEGAL
		JSR	    CREATE_FRAME
		MOVE.L	    SAVE_PC,-(SP)
		MOVE.W	    ILLEGAL_SR,-(SP)
		BSR	    GOTO_DEBUGGER
		BSR	    FLUSH_KEY
		MOVEA.L     CALL_SYSMON-4(PC),A3
		TST.B	    (A3)
		BEQ.S	    NO_MSG
		BSR	    PRINT_ERROR
NO_MSG: 	MOVE.L	    #CALL_MESSAGE_SYSMON,CALL_SYSMON-4
		BRA	    EDITOR

*-------------------------------------------------------------------------------

TRACE_ALWAYS:	bset		#TRACE_ALL,TRACE_MODUS_1	; Trace *
				bra.s		CALL_TRACE
TRACE_WITHOUT:	bset		#TRACE_MINUS,TRACE_MODUS_1	; Trace -
				bra.s		CALL_TRACE
TRACE_WITH:		bset		#TRACE_PLUS,TRACE_MODUS_1	; Trace +
CALL_TRACE:		jsr			CREATE_FRAME_PC
				move.w		sr,-(sp)
				bra			TRACE

*-------------------------------------------------------------------------------

* Wird bei programminternem Unterbruch benutzt: Escape, Bus-/Addresserror, Move
CLEAN_UP:		st			STOP_TRACE
				sf			STOP_TRACE
				BSR			TestBusOff
				MOVE.L		#1,TRACE_ZAEHLER
				MOVE.W		#SCREEN,DEVICE
				move.w		BILD_BREITE,BILD_BREITE_
				subq.w		#1,BILD_BREITE_
				CLR.L		GO_BREAKPT
				CLR.L		DO_BREAKPT
				CLR.L		GEMDOS_BREAKPT
				CLR.L		GEM_BREAKPT
				CLR.L		BIOS_BREAKPT
				CLR.L		XBIOS_BREAKPT
				sf			BreakFlag
				sf			KEEP_SCREEN
				sf			LOCAL_FLAG
				sf			SUPERVISOR
				sf			TRACE_MODUS_1
				sf			TRACE_MODUS_2
				sf			TRACE_MODUS_3
				sf			TRACE_MODUS_4
				sf			TRACE_MODUS_5
				sf			OPCODE_PC
				sf			KILLED_MOUSE
				sf			OPCODE
				sf			SECOND_LINE
				sf			DEVICE_BUSY
				sf			CURSOR_ZAEHLER
				sf			OBSERVE_FOUND
				sf			ONLY_LEXE
				sf			OnlyWord
				sf			DO_A_RESET
				MOVE.B		#1,MAUS_ZAEHLER
				BSR			HIDEM
				BSR			HELL_OFF
				BSR			INVERS_OFF
				BSR			UNDERLINE_OFF
				BRA			FLUSH_KEY

*-------------------------------------------------------------------------------

CLOCK:			movem.l		d0-a6,-(sp)
				lea			TIME_PRINT,a1
				tst.b		KIND_OF_CLOCK
				beq.s		.IKBD_UHR
				bmi.s		.MEGA_UHR

*---------------

		LEA	    $FFFF8961.w,A0	  ; TT Uhr
		MOVEQ	    #0,D0
		CLR.B	    (A0)
		MOVE.B	    2(A0),D0
		DIVU	    #10,D0
		MOVE.B	    D0,6(A1)
		SWAP	    D0
		MOVE.B	    D0,7(A1)
		MOVEQ	    #0,D0
		MOVE.B	    #2,(A0)
		MOVE.B	    2(A0),D0
		DIVU	    #10,D0
		MOVE.B	    D0,3(A1)
		SWAP	    D0
		MOVE.B	    D0,4(A1)
		MOVEQ	    #0,D0
		MOVE.B	    #4,(A0)
		MOVE.B	    2(A0),D0
		DIVU	    #10,D0
		MOVE.B	    D0,(A1)
		SWAP	    D0
		MOVE.B	    D0,1(A1)
		BRA.S	    .printen

*---------------

.MEGA_UHR:	LEA	    $FFFFFC2C.w,A0	  ; MEGA Uhr
		MOVEQ	    #5,D0
		MOVEQ	    #1,D1
.mega_loop:		MOVE.W	    -(A0),D2
				AND.B	    #15,D2
		MOVE.B	    D2,(A1)+
		EORI.W	    #1,D1
		ADDA.W	    D1,A1
		DBRA	    D0,.mega_loop
		BRA.S	    .printen

*---------------

.IKBD_UHR:		LEA			ACIA_STATUS_IKBD.w,A0
				BTST		#1,(A0)
				BEQ.S		RTS_REG
				MOVE.B		#$1C,2(A0)
				LEA			IKBD_ZEIT,A0
				SUBQ.W		#1,A1
				MOVEQ		#2,D2
.ikbd_loop:		MOVE.B		(A0)+,D0
				MOVE.B		D0,D1
				LSR.B		#4,D0
				AND.B		#$F,D1
				ADDQ.W		#1,A1
				MOVE.B		D0,(A1)+
				MOVE.B		D1,(A1)+
				DBRA		D2,.ikbd_loop

*---------------

.printen:	MOVEQ		#72,d0
				ADD.W		ZEILEN_LAENGE,D0
		LEA	    TIME_PRINT,A0
		MOVEQ	    #$30,D1
		ADDI.W	    #$3030,(A0)
		ADD.B	    D1,3(A0)
		ADD.B	    D1,4(A0)
		ADDI.W	    #$3030,6(A0)
		MOVEA.L     ZEICHEN_ADRESSE,A1
		LEA	    MenueFlags+72,A2
		ADDA.W	    D0,A1
		MOVEQ	    #7,D1
COPY_TIME:	MOVE.B	    (A0),(A1)+
		MOVE.B	    (A0)+,(A2)+
		DBRA	    D1,COPY_TIME
		MOVEQ	    #72,D0
		MOVEQ	    #1,D1
		MOVEQ	    #7,D2
		BSR	    INVERS_ON
		BSR	    CURSOR_ON
		BSR	    PRINT_AT
		BSR	    CURSOR_OFF
		BSR	    INVERS_OFF
RTS_REG:	MOVEM.L     (SP)+,d0-a6
		RTS

**********************	Ausgaben, GerÑte-Treiber  ******************************

*-------------------------------------------------------------------------------
* PrintManager: Diese Routine managt das Printen mehrerer Zeilen. Die Ausgabe
*				kann angehalten oder abgebrochen werden. Es werden keine
*				Register verÑndert, benutzt wird nur a6.
* ---> A6.l = Routine, die nach jeder Zeile aufgerufen wird
* <--- Flag.ne = Abbrechen, Flag.eq = Weitermachen
*-------------------------------------------------------------------------------
* Message_C: Mit Umlenkung, $, nullterminiert.
* ---> A3.l = Adresse des Strings
* (---> D3.w = Zeile), nur Screendevice
*
* MessageDown_C: Mit Umlenkung, $, Y_POSITION+1, nullterminiert.
*
* MessageRaw_C: Ohne Umlenkung, $, nullterminiert.
*
* MessageRawDown_C: Ohne Umlenkung, $, Y_POSITION+1, nullterminiert.
*-------------------------------------------------------------------------------
* RawMessage_C: Mit Umlenkung, nullterminiert.
* ---> A3.l  = Adresse des Strings
* (---> D3.w = Zeile), nur Screendevice
*
* RawMessageDown_C: Mit Umlenkung, Y_POSITION+1, nullterminiert.
*
* RawMessageRaw_C: Ohne Umlenkung, nullterminiert.
*
* RawMessageRawDown_C: Ohne Umlenkung, Y_POSITION+1, nullterminiert.
*-------------------------------------------------------------------------------
* RawMessage_P: Mit Umlenkung, LÑngenbyte.
* ---> A3.l  = Adresse des Strings
* (---> D3.w = Zeile), nur Screendevice
*
* RawMessageDown_P: Mit Umlenkung, Y_POSITION+1, LÑngenbyte.
*-------------------------------------------------------------------------------
* ListLine: Printet eine Zeile gemÑss LIST_FLAG.
* ---> A3.l = ab dieser Adresse wird geprintet
* ---> D3.w = und diese Zeile soll geprintet werdem
* <--- A0.l = Pointer auf einen Record (siehe Disassembler)
*
* ListLineDown: Printet eine Zeile gemÑss LIST_FLAG unterhalt Y_POSITION.
*
* ListLineRaw: Printet eine Zeile gemÑss LIST_FLAG.
* ---> A3.l = ab dieser Adresse wird geprintet
* ---> D3.w = und diese Zeile soll geprintet werdem
* <--- A0.l = Pointer auf einen Record (siehe Disassembler)
*
* ListLineRawDown: Printet eine Zeile gemÑss LIST_FLAG unterhalb Y_POSITION.
*-------------------------------------------------------------------------------
* ListA3: Printet den ganzen Screen voll gemÑss LIST_FLAG.
* ---> A3.l = ab dieser Adresse wird gelistet
*
* ListPC: Sucht den Screen nach dem PC ab, wenn er ihn findet, listet er ab
*		  dort, sonst printet er den ganzen Screen neu.
*-------------------------------------------------------------------------------
* NumberError: GemÑss den Fehlern bei der Auswertung von Termen wird eine
*			   Meldung ausgegeben.
*
* LengthError: Printet die Meldung: Illegal length of the operand.
*
* PathError: Printet die Meldung: Path does not exist.
*-------------------------------------------------------------------------------
* PRINT_ERROR: Printet einen Error (Invers in der ersten Zeile), das Format ist
*			   das gleiche wie bei Message_C. ZusÑtzlich wird ListPC aufgerufen.
* ---> A3.l = Adresse des Strings
*
* PRINT_ADRESSE: Printet die Adresse am Anfang der Zeile.
* ---> A2.l = Stringanfang
* ---> A3.l = zu printende Adresse
* <--- A2.l = Stringende
*
* PRINT_HEX: Printet eine Hexadezimale Zahl (inkl. $).
* ---> D2.w = Anzahl Stellen (0...)
* ---> D3.l = zu printende Zahl
* ---> A2.l = Stringanfang
* <--- A2.l = Stringende
*
* PRINTHEX: Printet eine Hexadezimale Zahl (ohne $).
* ---> D2.w = Anzahl Stellen (0...)
* ---> D3.l = zu printende Zahl
* ---> A2.l = Stringanfang
* <--- A2.l = Stringende
*
* PRINT_HEXADEZIMAL: Printet eine Hexadezimale Zahl (inkl. $) ohne fÅhrende Nullen.
* ---> D3.l = zu printende Zahl
* ---> A2.l = Stringanfang
* <--- A2.l = Stringende
*
* PRINT_DEZ: Printet eine Dezimale Zahl (dynamische LÑnge).
* ---> D3.l = zu printende Zahl
* ---> A2.l = Stringadresse, ab der geprintet wird
* <--- A2.l = Stringende
*
* PRINT_DEZIMAL: Printet eine Dezimale Zahl (feste LÑnge).
* ---> D2.w = Anzahl Stellen (0...)
* ---> D3.l = zu printende Zahl
* ---> A2.l = Stringadresse, ab der geprintet wird
* <--- A2.l = Stringende
*
* PRINT_MENU: Printet MenÅ und Register.
*
* PRINT_REGISTER: Printet Register+Showmemory.
*
* PRINT_SHOW: Printet Showmemory.
*
* Calc_FIRST_LINE: Berechnet FIRST_LINE. Muss vor jedem Einsprung und immer dann
*				   aufgerufen werden, wenn sich am Bildaufbau etwas Ñndert.
*
* CHECK_POSITION: öberprÅft ob eine Zeile existiert, sonst wird gescrollt.
*				  Message_zÑhler wird erhîht wenn Device = Screen.
* ---> D3.w = Zeile
* <--- D3.w = korrigierte Zeile
*-------------------------------------------------------------------------------

		.BSS
PUFFER_OUTPUT:	ds.b		MENUE_LENGTH+2		; darf nur in diesem Teil
		.TEXT									; benutzt werden

*-------------------------------------------------------------------------------

PrintManager:	st			BreakFlag
				bsr			CHEAT_KEY
				cmpi.b		#57,KEY				; Space gedrÅckt?
				bne.s		.no_space
.wait_space_1:	bsr			CHEAT_KEY
				cmpi.b		#185,KEY			; wait for Space loslassen
				bne.s		.wait_space_1
.wait_space_2:	bsr			CHEAT_KEY
				cmpi.b		#185,KEY			; Wait for key ohne Space
				beq.s		.wait_space_2
.wait_space_3:	bsr			CHEAT_KEY
				btst		#7,KEY				; Wait for key loslassen
				beq.s		.wait_space_3
.no_space:		tst.b		CONTROL_FLAG		; Wait Scrolling
				bne.s		PrintManager
				jsr			(a6)
				beq.s		PrintManager
				sf			BreakFlag
				rts

*-------------------------------------------------------------------------------

MessageRawDown_C:
				move.w		DEVICE,-(sp)
				move.w		#SCREEN,DEVICE
				bsr.s		MessageDown_C
				move.w		(sp)+,DEVICE
				rts

*---------------

MessageDown_C:	move.w		d3,-(sp)
				move.w		Y_POSITION,d3
				addq.w		#1,d3
				bsr.s		Message_C
				move.w		(sp)+,d3
				rts

*---------------

MessageRaw_C:	move.w		DEVICE,-(sp)
				move.w		#SCREEN,DEVICE
				bsr.s		Message_C
				move.w		(sp)+,DEVICE
				rts

*---------------

Message_C:		movem.l		d0-a6,-(sp)
				bsr			CHECK_POSITION
				move.w		d3,d4				; Position sichern
				lea			PUFFER_OUTPUT,a2	; Hierhin wird geschrieben
				move.b		#32,(a2)+			; einleitendes Space
				lea			FEHLER_ADRESSEN,a6
.printen:		cmpi.b		#'$',(a3)
				bne.s		.copy
				addq.w		#1,a3
				move.l		(a6)+,d3			; Zahl
				bsr			PRINT_HEXADEZIMAL
.copy:			move.b		(a3)+,(a2)+			; Zeichen kopieren
				bne.s		.printen
				move.w		d4,d3				; Zeile
				lea			PUFFER_OUTPUT,a3	; Stringadresse
				bsr			PRINT_STRING_C
				movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

RawMessageRawDown_C:
				move.w		DEVICE,-(sp)
				move.w		#SCREEN,DEVICE
				bsr.s		RawMessageDown_C
				move.w		(sp)+,DEVICE
				rts

*---------------

RawMessageDown_C:
				move.w		d3,-(sp)
				move.w		Y_POSITION,d3
				addq.w		#1,d3
				bsr.s		RawMessage_C
				move.w		(sp)+,d3
				rts

*---------------

RawMessageRaw_C:move.w		DEVICE,-(sp)
				move.w		#SCREEN,DEVICE
				bsr.s		RawMessage_C
				move.w		(sp)+,DEVICE
				rts

*---------------

RawMessage_C:	movem.l		d0-a6,-(sp)
				bsr			CHECK_POSITION
				lea			PUFFER_OUTPUT,a2
.loop:			move.b		(a3)+,(a2)+
				bne.s		.loop
				lea			PUFFER_OUTPUT,a3
				bsr			PRINT_STRING_C
				movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

RawMessageDown_P:move.w		d3,-(sp)
				move.w		Y_POSITION,d3
				addq.w		#1,d3
				bsr.s		RawMessage_P
				move.w		(sp)+,d3
				rts

RawMessage_P:	movem.l		d0-a6,-(sp)
				bsr			CHECK_POSITION
				lea			PUFFER_OUTPUT,a2
				moveq		#0,d7
				move.b		(a3)+,d7
				move.b		d7,(a2)+
				bra.s		.entry
.loop:			move.b		(a3)+,(a2)+
.entry:			dbra		d7,.loop
				lea			PUFFER_OUTPUT,a3
				bsr			PRINT_STRING_P
				movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

ListLineRawDown:move.w		DEVICE,-(sp)
				move.w		#SCREEN,DEVICE
				bsr.s		ListLineDown
				move.w		(sp)+,DEVICE
				rts

ListLineDown:	move.w		d3,-(sp)
				move.w		Y_POSITION,d3
				addq.w		#1,d3
				bsr.s		ListLine
				move.w		(sp)+,d3
				rts

ListLineRaw: 	move.w		DEVICE,-(sp)
				move.w		#SCREEN,DEVICE
				bsr.s		ListLine
				move.w		(sp)+,DEVICE
				rts

ListLine:		movem.l		d0/a2/a3,-(sp)
				bsr			CHECK_POSITION
				lea			PUFFER_OUTPUT+1,a2
				bsr			PRINT_ADRESSE
				move.b		LIST_FLAG,d0
				add.b		d0,d0
				ext.w		d0
				move.w		LISTDIS_TABELLE+2(pc,d0.w),d0
				jsr			LISTDIS_TABELLE(pc,d0.w)
				suba.l		#PUFFER_OUTPUT+1,a2
				move.w		a2,d0				; StringlÑnge
				lea			PUFFER_OUTPUT,a3
				move.b		d0,(a3)
				bsr			PRINT_STRING_P
				movem.l		(sp)+,d0/a2/a3
				rts

*---------------
LISTDIS_TABELLE:dc.w		.LISTEN_ZEILE-LISTDIS_TABELLE,.DIS_ZEILE-LISTDIS_TABELLE,.DUMP_ZEILE-LISTDIS_TABELLE,.ASCII_ZEILE-LISTDIS_TABELLE
*---------------

.ASCII_ZEILE:	movem.l		d3/a3,-(sp)
				move.w		ASCII_BREITE,d3
				move.w		d3,DisassemblyLength
				beq.s		.ascii_ende
				move.b		#')',(a2)+
				move.b		#'"',(a2)+
				subq.w		#1,d3
				bsr			TestBusOn
				pea			.ascii_fail(pc)
.ascii_loop: 	move.b		(a3)+,(a2)
.ascii_cont: 	addq.w		#1,a2
				dbra		d3,.ascii_loop
				bsr			TestBusOff
				addq.w		#4,sp
				move.b		#'"',(a2)+
.ascii_ende:	movem.l		(sp)+,d3/a3
				rts

.ascii_fail:	pea			.ascii_fail(pc)
				bsr			TestBusOn
				move.b		#'-',(a2)
				bra.s		.ascii_cont

*---------------

.LISTEN_ZEILE:	movem.l		d3/a1/a2,-(sp)
				move.b		#'!',(a2)+
				move.b		#32,(a2)+

				tst.b		SYMBOL_FLAG			; Label suchen
				beq			.listen

				move.l		a3,d3
				jsr			SEARCH_SYMBOL
				beq.s		.suchen
.list_loop:		move.b		(a0)+,(a2)+
				bne.s		.list_loop
				move.b		#':',-1(a2)
				move.b		#32,(a2)+
				bra.s		.einschub

.suchen:		movem.l		d7/a1,-(sp)			; Programmname suchen
				move.l		RES_SYMDRIVER,d7
				beq.s		.no_list
				movea.l		d7,a1
				moveq		#36,d7
				cmpi.w		#$118,(a1)
				bls.s		.lower
				moveq		#38,d7
.lower:			addq.w		#4,a1
.search: 		tst.l		(a1)
				beq.s		.no_list
				movea.l		(a1),a1
				tst.b		(a1)
				beq.s		.no_list
				lea			(a1,d7.w),a1
				cmp.l		(a1)+,d3
				bhs.s		.high
				cmp.l		(a1),d3
				bhs.s		.found
.high:			addq.w		#4,a1
				bra.s		.search
.found:			suba.w		d7,a1
				subq.w		#4,a1
				move.b		#'[',(a2)+
.list_symbol:	cmpi.b		#'.',(a1)
				beq.s		.end_of_string
				move.b		(a1)+,(a2)+
				bne.s		.list_symbol
				subq.w		#1,a2
.end_of_string:	move.b		#']',(a2)+
				move.b		#32,(a2)+
.no_list:		movem.l		(sp)+,d7/a1

.einschub:		move.l		8(sp),d3			; Zeile einrÅcken
				addi.l		#13,d3
.pos_loop_1:	cmp.l		a2,d3
				bls.s		.listen
				move.b		#32,(a2)+
				bra.s		.pos_loop_1

.listen: 		jsr			Disassembler
				move.l		8(sp),d3			; Zeile einrÅcken
				addi.l		#49,d3
.pos_loop_2:	cmp.l		a2,d3
				bls.s		.pos_io
				move.b		#32,(a2)+
				bra.s		.pos_loop_2
.pos_io:		move.b		#32,(a2)+
				move.b		#';',(a2)+
				move.b		#32,(a2)+
				move.w		DisassemblyLength,d3
				bsr			.PRINT_CODE
				move.l		a2,8(sp)
				movem.l		(sp)+,d3/a1/a2
				rts

*---------------

.DIS_ZEILE:		movem.l		d3/a4,-(sp)
				move.b		#'/',(a2)+
				move.b		#32,(a2)+
				movea.l		a2,a4				; a2=a4=Start
				moveq		#26,d3
.dis_loop:		move.b		#32,(a2)+
				dbra		d3,.dis_loop
				move.b		#';',(a2)+
				move.b		#32,(a2)+			; a2=Disassembly
				jsr			Disassembler
				exg			a2,a4				; a2=Start, a4=Ende
				move.w		DisassemblyLength,d3
				bsr			.PRINT_CODE
				movea.l		a4,a2				; a2 = Ende
				movem.l		(sp)+,d3/a4
				rts

*---------------

.DUMP_ZEILE:	movem.l		d0-d2/a3/a4,-(sp)
				moveq		#0,d0
				move.w		DUMP_BREITE,d2
				move.w		d2,DisassemblyLength
				beq.s		.dump_ende
				move.l		a2,a4
				lea			1(a2,d2.w),a2
				adda.w		d2,a2
				adda.w		d2,a2
				move.b		#',',(a4)+
				move.b		#32,(a4)+
				move.b		#32,(a2)+
				move.b		#'"',(a2)+
				pea			.dump_fail(pc)
				bsr			TestBusOn
				subq.w		#1,d2
				bra.s		.dump_entry
.dump_loop:		move.b		#',',(a4)+
.dump_entry:	move.b		(a3)+,d0
				move.b		d0,(a2)+
				moveq		#$f,d1
				and.b		d0,d1
				lsr.b		#4,d0
				move.b		.table(pc,d0.w),(a4)+
				move.b		.table(pc,d1.w),(a4)+
.dump_back:		dbra		d2,.dump_loop
				bsr			TestBusOff
				addq.w		#4,sp
				move.b		#'"',(a2)+
.dump_ende:		movem.l		(sp)+,d0-d2/a3/a4
				rts

.dump_fail:		pea			.dump_fail(pc)
				bsr			TestBusOn
				move.b		#'-',(a4)+
				move.b		#'-',(a4)+
				move.b		#'-',(a2)+
				bra.s		.dump_back

*---------------
.table:	dc.b '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
*---------------

* ---> d3.w = BefehlslÑnge
* ---> a2.l = Stringadresse
* ---> a3.l = Befehlsadresse
* <--- a2.l = Stringende
.PRINT_CODE:	movem.l		d0-d3/a3,-(sp)
				moveq		#0,d0
				lsr.w		#1,d3
				pea			.code_fail(pc)
				bsr			TestBusOn
				bra.s		.entry
.loop_0:		moveq		#1,d2
.loop_1:		move.b		(a3)+,d0
				moveq		#$f,d1
				and.b		d0,d1
				lsr.b		#4,d0
				move.b		.table(pc,d0.w),(a2)+
				move.b		.table(pc,d1.w),(a2)+
.code_back:		dbra		d2,.loop_1
				move.b		#',',(a2)+
.entry:			dbra		d3,.loop_0
				move.b		#32,-(a2)
				bsr			TestBusOff
				addq.w		#4,sp
				movem.l		(sp)+,d0-d3/a3
				rts

.code_fail:		pea			.code_fail(pc)
				bsr			TestBusOn
				move.b		#'-',(a2)+
				move.b		#'-',(a2)+
				bra.s		.code_back

*-------------------------------------------------------------------------------

ListA3:			movem.l		d0/d3/d7/a0/a3,-(sp)
				move.w		FIRST_LINE,d3
				tst.b		SECOND_LINE
				beq.s		.first
				addq.w		#1,d3
.first:			move.w		d3,d7
				move.w		ZEILEN_SCREEN,d0
				sub.w		d3,d0
				bra.s		.entry
.loop:			bsr			ListLineRaw
				adda.w		DisassemblyLength,a3
				addq.w		#1,d3
.entry:			dbra		d0,.loop
				move.w		#10,X_POSITION
				move.w		d7,Y_POSITION
				bsr			POSITIONIEREN
				movem.l		(sp)+,d0/d3/d7/a0/a3
				rts

*-------------------------------------------------------------------------------

ListPC:			bsr			HIDEM
				bsr			CURSOR_OFF

				movem.l		d0-a6,-(sp)

				move.w		FIRST_LINE,d3
				tst.b		SECOND_LINE
				bne.s		.second
				subq.w		#1,d3
.second:		movea.l		SAVE_PC,a3			; PC suchen
				move.w		ZEILEN_SCREEN,d1
				sub.w		d3,d1
				subq.w		#2,d1
				bmi.s		.listen

.loop_1:		addq.w		#1,d3				; Zeile suchen
				jsr			GET_ADRESS_1
				dbeq		d1,.loop_1
				bne.s		.listen
				cmp.l		a3,d0
				dbeq		d1,.loop_1
				beq.s		.found

.listen:		bsr			ListA3				; nichts gefunden
				bra.s		.ende

.found:			movea.l		d0,a3
				move.w		d3,d7
.loop_2:		bsr			ListLineRaw
				adda.w		DisassemblyLength,a3
				addq.w		#1,d3
				jsr			GET_ADRESS_1
				cmp.l		a3,d0
				dbeq		d1,.loop_2
				move.w		#10,X_POSITION
				move.w		d7,Y_POSITION
				bsr			POSITIONIEREN

.ende:			movem.l		(sp)+,d0-a6
				bsr			CURSOR_ON
				bra			SHOWM

*-------------------------------------------------------------------------------

NumberError:	movem.l		d0/a2,SAVE_POSITION
				movem.l		d0-a6,-(sp)
				lea			SYNTAX_FEHLER,a3
				tst.b		NoNumber
				beq.s		.NoNumber
				lea			.NO_NUMBER_FEHLER,a3
.NoNumber:		tst.b		KlammerFehler
				beq.s		.KlammerFehler
				lea			.KLAMMER_FEHLER,a3
.KlammerFehler:	tst.b		Ueberlauf
				beq.s		.Ueberlauf
				lea			.UEBERLAUF_FEHLER,A3
.Ueberlauf:		tst.b		Division
				beq.s		.Division
				lea			.DIVISIONS_FEHLER,a3
.Division:		bsr			MessageRawDown_C
				movem.l		(sp)+,d0-a6
				rts

				MessageC	.NO_NUMBER_FEHLER,'Expression required'
				MessageC	.KLAMMER_FEHLER,'Bracket required'
				MessageC	.UEBERLAUF_FEHLER,'Overflow'
				MessageC	.DIVISIONS_FEHLER,'Division by zero'
				MessageC	SYNTAX_FEHLER,'Syntax Error'

*-------------------------------------------------------------------------------

LengthError:	movem.l		d0/a2,SAVE_POSITION
				move.l		a3,-(sp)
				lea			.ILLEGAL_LENGTH,a3
				bsr			MessageRawDown_C
				move.l		(sp)+,a3
				rts

				MessageC	.ILLEGAL_LENGTH,'Illegal length of the operand'

*-------------------------------------------------------------------------------

PathError:		move.l		a3,-(sp)
				lea			.path_fail,a3
				bsr			MessageRawDown_C
				move.l		(sp)+,a3
				jmp			RESTORE_PATH

				MessageC	.path_fail,'Path does not exist'

*-------------------------------------------------------------------------------

PRINT_ERROR:	movem.l		d0-a6,-(sp)
				move.w		FIRST_LINE,d3
				move.w		d3,d4				; Position sichern
				lea			PUFFER_OUTPUT,a0
				movea.l		a0,a2
				move.b		#32,(a2)+
				lea			FEHLER_ADRESSEN,a6
.printen:		cmpi.b		#'$',(a3)
				bne.s		.copy
				addq.w		#1,a3
				move.l		(a6)+,d3			; Zahl
				bsr			PRINT_HEXADEZIMAL
.copy:			move.b		(a3)+,(a2)+
				bne.s		.printen

				movea.l		a0,a3				; Errorstring speichern wegen
				lea			ERROR_STRING,a1		; Befehl "last"
				moveq		#79,d0
.last_copy:		move.b		(a0)+,(a1)+
				dbeq		d0,.last_copy

				move.w		DEVICE,-(sp)
				move.w		#SCREEN,DEVICE
				move.w		d4,d3				; Zeile
				bsr			PRINT_STRING_C
				move.w		(sp)+,DEVICE
				st			SECOND_LINE
				bsr			ListPC
				sf			SECOND_LINE
				movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

PRINT_ADRESSE:	movem.l		d2/d3,-(sp)
				moveq		#7,d2
				move.l		a3,d3
				bsr.s		PRINT_HEX
				move.b		#'>',(a2)+
				movem.l		(sp)+,d2/d3
				rts

*-------------------------------------------------------------------------------

PRINTHEX:		bra.s		PRINT_HEX_ENTRY
PRINT_HEX:		move.b		#'$',(a2)+
PRINT_HEX_ENTRY:lea			1(a2,d2.w),a2
				movem.l		d1-d3/a2,-(sp)
.loop:			moveq		#$f,d1
				and.b		d3,d1
				lsr.l		#4,d3
				move.b		.table(pc,d1.w),-(a2)
				dbra		d2,.loop
				movem.l		(sp)+,d1-d3/a2
				rts

.table:			dc.b		'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'

*---------------

PRINT_HEXADEZIMAL:
				movem.l		d0-d3,-(sp)
				move.b		#'$',(a2)+
				moveq		#7,d2			; maximal 7 Zeichen
				tst.l		d3
				sne			d0				; Flag fÅr fÅhrende Nullen
				bne.s		.loop
				moveq		#0,d2
.loop:			rol.l		#4,d3
				moveq		#$f,d1
				and.b		d3,d1
				bne.s		.cont
				tst.b		d0
				bne.s		.ignore_zeros
.cont:			sf			d0
				move.b		.table(pc,d1.w),(a2)+
.ignore_zeros:	dbra		d2,.loop
				movem.l		(sp)+,d0-d3
				rts

.table:			dc.b		'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'

*-------------------------------------------------------------------------------

PRINT_DEZ:		link		a6,#-10
				movem.l		d0-d3,-(sp)
				moveq		#-1,d0
				moveq		#10,d2
.loop_0: 		jsr			LongDivu
				addi.b		#48,d1
				move.b		d1,-(a6)
				addq.w		#1,d0
				tst.l		d3
				bne.s		.loop_0
.loop_1:		move.b		(a6)+,(a2)+
				dbra		d0,.loop_1
				movem.l		(sp)+,d0-d3
				unlk		a6
				rts

*-------------------------------------------------------------------------------

PRINT_DEZIMAL:	lea			1(a2,d2.w),a2
				movem.l		d0-d3/a2,-(sp)
				move.w		d2,d0
				moveq		#10,d2
.loop_0:		jsr			LongDivu
				addi.b		#48,d1
				move.b		d1,-(a2)
				tst.l		d3
				dbeq		d0,.loop_0
				beq.s		.entry
				movem.l		(sp)+,d0-d3/a2
				rts
.loop_1:		move.b		#'0',-(a2)
.entry:			dbra		d0,.loop_1
				movem.l		(sp)+,d0-d3/a2
				rts

*-------------------------------------------------------------------------------

PRINT_MENU:		movem.l		d0-d1/d3/a0-a1,-(sp)

				tst.b		SYMBOL_FLAG
				lea			MenueFlags+8*6+6,a0
				bsr.s		.set_char					; Symbolflag setzen
				tst.b		INSERT_FLAG
				lea			MenueFlags+8*7+6,a0
				bsr.s		.set_char					; Insertflag setzen
				move.b		SYMBOL_FLAG,SAVE_SYMBOLFLAG

				lea			MenueZeile,a0				; MenÅ kopieren
				movea.l		ZEICHEN_ADRESSE,a1
				moveq		#4,d0
.copy_0:		move.w		ZEILEN_LAENGE,d1
				subq.w		#1,d1
.copy_1:		move.b		(a0)+,(a1)+
				dbeq		d1,.copy_1
				bne.s		.cont
				subq.w		#1,a0
				subq.w		#1,a1
.fill:			move.b		#32,(a1)+
				dbra		d1,.fill
.cont:			tst.b		(a0)+
				bne.s		.cont
				dbra		d0,.copy_0

				bsr			INVERS_ON
				moveq		#0,d3
				bsr			PRINT_LINE					; Zeile 0 printen
				moveq		#1,d3
				bsr			PRINT_LINE					; Zeile 1 printen
				bsr			INVERS_OFF
				movem.l		(sp)+,d0-d1/d3/a0-a1
				bra.s		PRINT_REGISTER

*---------------

.set_char:		beq.s		.minus
				bmi.s		.plus
				move.b		#'/',(a0)
				rts
.plus:			move.b		#'+',(a0)
				rts
.minus:			move.b		#'-',(a0)
				rts

*-------------------------------------------------------------------------------

PRINT_REGISTER:	movem.l		d0-a6,-(sp)
				bsr			HIDEM
				bsr			CURSOR_OFF

				movea.l		ZEICHEN_ADRESSE,a2
				adda.w		ZEILEN_LAENGE,a2
				adda.w		ZEILEN_LAENGE,a2

				moveq		#32,d0				; Cache nicht auf 0 ?
				jsr			CACHE_TEST			; ---> d3.l=aktueller Eintrag
				beq.s		.no_cache
				moveq		#'',d0
.no_cache:		move.b		d0,(a2)+

				moveq		#'1',d0				; Cache 1 oder 2 ?
				tst.b		CACHE_FLAG
				beq.s		.first_cache
				moveq		#'2',d0
.first_cache:	move.b		d0,(a2)+

				moveq		#3,d2				; 4 Stellen
				addq.w		#1,a2
				bsr			.PrintNumber		; Cacheeintrag
				moveq		#7,d2				; 8 Stellen
				move.l		SAVE_PC,d3			; PC
				lea			8(a2),a2
				bsr			.PrintNumber
				move.l		SAVE_USP,d3			; USP
				lea			13(a2),a2
				bsr			.PrintNumber
				move.l		SAVE_ISP,d3			; ISP
				lea			13(a2),a2
				bsr			.PrintNumber
				move.l		SAVE_MSP,d3			; MSP
				lea			13(a2),a2
				bsr			.PrintNumber

				tst.b		OPCODE				; Opcode vorhanden?
				beq.s		.no_opcode

				lea			10(a2),a4			; Opcode printen
				lea			PUFFER_OUTPUT,a2	; Strinadresse
				movea.l		SAVE_PC,a3			; Befehlsadresse
				jsr			Disassembler
				clr.b		(a2)				; Stringende
				lea			PUFFER_OUTPUT,a2
				moveq		#18,d0
				moveq		#32,d1
.copy:			cmp.b		(a2),d1
				beq.s		.spaces
				move.b		(a2)+,(a4)+
				dbeq		d0,.copy
				beq.s		.eos
				tst.b		(a2)
				beq.s		.cont
				move.b		#3,(a4)
				bra.s		.cont
.eos:			subq.w		#1,a4
.fill:			move.b		d1,(a4)+			; mit Spaces auffÅllen
				dbra		d0,.fill
				bra.s		.cont
.spaces:		cmp.b		(a2)+,d1
				beq.s		.spaces
				subq.w		#1,a2
				move.b		d1,(a4)+
				dbra		d0,.copy
.cont:			moveq		#2,d3
				bsr			PRINT_LINE
				moveq		#19,d0
				lea			-19(a4),a4
				lea			MenueMaske_1+60,a6	; String wieder restoren
.restore:		move.b		(a6)+,(a4)+
				dbra		d0,.restore
				bra.s		.no_status

.no_opcode:		moveq		#2,d3				; Statusregister printen
				bsr			PRINT_LINE
				moveq		#63,d0				; X
				moveq		#2,d1				; Y
				moveq		#0,d2				; 1 Stelle
				move.w		SAVE_STATUS,d3		; SR
				andi.w		#%1111011100011111,d3
				moveq		#15,d4				; 16 Bits
				bsr			HELL_ON
.sr_loop:		add.w		d3,d3
				bcs.s		.dont_print
				bsr			PRINT_AT
.dont_print:	addq.w		#1,d0
				dbra		d4,.sr_loop
				bsr			HELL_OFF

.no_status:		lea			SAVE_REGISTER,a0	; Register printen
				movea.l		ZEICHEN_ADRESSE,a2
				move.w		ZEILEN_LAENGE,d0
				adda.w		d0,a2
				adda.w		d0,a2
				lea			8(a2,d0.w),a2
				moveq		#7,d2				; 8 Stellen
				moveq		#1,d4				; Daten- und Adressregister
.reg_loop_0:	moveq		#7,d5				; je 8 Register
.reg_loop_1:	move.l		(a0)+,d3			; Register holen
				bsr			.PrintNumber
				lea			9(a2),a2
				dbra		d5,.reg_loop_1
				lea			-72(a2,d0.w),a2
				dbra		d4,.reg_loop_0
				moveq		#3,d3
				bsr			PRINT_LINE
				bsr			UNDERLINE_ON
				moveq		#4,d3
				bsr			PRINT_LINE
				bsr			UNDERLINE_OFF
				bra			_PRINT_SHOW

*---------------

* ---> d2.w = Anzahl Stellen (0...)
* ---> d3.l = Zahl
* ---> a2.l = Position
.PrintNumber:	movem.l		d1-d3,-(sp)
				lea			1(a2,d2.w),a2
.loop:			moveq		#$f,d1
				and.w		d3,d1
				lsr.l		#4,d3
				move.b		.table(pc,d1.w),-(a2)
				dbra		d2,.loop
				movem.l		(sp)+,d1-d3
				rts

.table:			dc.b '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'

*-------------------------------------------------------------------------------

PRINT_SHOW:		movem.l		d0-a6,-(sp)
				bsr			HIDEM
				bsr			CURSOR_OFF
_PRINT_SHOW:	st			SHOW_ACTIV			; Showmemory
				move.b		#'0',SHOW_ZAEHLER
				clr.w		SHOW_NUMBER
				lea			SHOW_RECORD,a5
				move.w		SHOW_ANZAHL,d5
				moveq		#ANZAHL_SHOW-1,d6
				moveq		#5,d7
				move.b		LIST_FLAG,-(SP)
.show_loop:		tst.b		(a5)
				beq			.dont_show
				move.b		1(a5),LIST_FLAG
				lea			2(a5),a2
				move.w		#MENUE_LENGTH-1,d0
				jsr			Interpreter
				beq.s		.number_io
				moveq		#0,d3
.number_io:		movea.l		d3,a3				; a3 = Adresse

				lea			PUFFER_OUTPUT+1,a2	; Zeile aufbauen
				move.b		SHOW_ZAEHLER,(a2)+
				move.b		#':',(a2)+
				moveq		#7,d2
				move.l		a3,d3
				bsr			PRINT_HEX
				move.b		#'>',(a2)+
				move.b		LIST_FLAG,d0
				add.b		d0,d0
				ext.w		d0
				lea			LISTDIS_TABELLE(pc),a6
				move.w		2(a6,d0.w),d0
				jsr			(a6,d0.w)			; Zeile listen
				lea			PUFFER_OUTPUT,a3
				suba.l		a3,a2
				subq.w		#1,a2
				move.w		a2,d0
				move.b		d0,(a3)				; ZeilenlÑnge

				bsr			UNDERLINE_OFF
				subq.w		#1,d5
				bne.s		.no_underline
				bsr			UNDERLINE_ON

.no_underline:	move.w		d7,d3
				addq.w		#2,d7
				cmp.w		ZEILEN_SCREEN,d7
				blo.s		.NotLastLine
				beq.s		.LastLine
				bsr			Calc_FIRST_LINE
				bra.s		.ende
.LastLine:		bsr			UNDERLINE_ON
.NotLastLine:	move.w		DEVICE,-(sp)
				move.w		#SCREEN,DEVICE
				bsr			PRINT_STRING_P
				move.w		(sp)+,DEVICE
				subq.w		#1,d7

.dont_show:		addq.b		#1,SHOW_ZAEHLER
				addq.w		#1,SHOW_NUMBER
				lea			MENUE_LENGTH+2(a5),a5
				dbra		d6,.show_loop
.ende:			move.b		(sp)+,LIST_FLAG
				sf			SHOW_ACTIV
				bsr			UNDERLINE_OFF

				bsr			CURSOR_ON
				bsr			SHOWM
				movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

Calc_FIRST_LINE:move.w		d0,-(sp)
				moveq		#5,d0
				add.w		SHOW_ANZAHL,d0
				cmp.w		ZEILEN_SCREEN,d0
				blo.s		.ende
				move.w		ZEILEN_SCREEN,d0
				subq.w		#1,d0
.ende:			move.w		d0,FIRST_LINE
				move.w		(sp)+,d0
				rts

*-------------------------------------------------------------------------------

CHECK_POSITION: cmpi.w		#SCREEN,DEVICE			; Screendevice?
				beq.s		.cont
				rts
.cont:			cmp.w		ZEILEN_SCREEN,d3		; Zeilenposition testen
				blt.s		.zeile_io
				subq.w		#1,SAVE_Y_POSITION
				bsr			SCROLL_DOWN
				move.w		ZEILEN_SCREEN,d3
				subq.w		#1,d3
.zeile_io:		move.w		d3,Y_POSITION
				bsr			POSITIONIEREN
				cmp.w		FIRST_LINE,d3
				bge.s		.ende
				move.w		FIRST_LINE,d3
.ende:			rts

*-------------------------------------------------------------------------------
* PRINT_STRING_C: Printet einen nullterminierten String.
* ---> A3.l = Zeiger auf den zu printenden String
* (---> D3.w) = Zeile auf die geprintet werden soll, keine öberprÅfung.
*				Wird natÅrlich nur auf dem Screendevice ausgewertet (0...).
* (<--- tst.b flag.ne = im Fehlerfall, allerdings nicht beim Screendevice)
*
* PRINT_STRING_P: Printet einen String mit LÑngenbyte.
* ---> A3.l = Zeiger auf den zu printenden String
* (---> D3.w) = Zeile auf die geprintet werden soll, keine öberprÅfung.
*				Wird natÅrlich nur auf dem Screendevice ausgewertet (0...).
* (<--- tst.b flag.ne = im Fehlerfall, allerdings nicht beim Screendevice)
*-------------------------------------------------------------------------------

PRINT_STRING_C:	movem.l		d0-a6,-(sp)
				move.w		DEVICE,d0
				add.w		d0,d0
				move.w		.DEVICES_C(pc,d0.w),d0
				jsr			.DEVICES_C(pc,d0.w)
				movem.l		(sp)+,d0-a6
				rts

*---------------

				dc.w		DEVICE_FILE_2_C-.DEVICES_C
				dc.w		DEVICE_FILE_1_C-.DEVICES_C
.DEVICES_C:		dc.w		DEVICE_PRINTER_C-.DEVICES_C
				dc.w		DEVICE_RS232_C-.DEVICES_C
				dc.w		DEVICE_SCREEN_C-.DEVICES_C
				dc.w		DEVICE_MIDI_C-.DEVICES_C

*-------------------------------------------------------------------------------


PRINT_STRING_P:	movem.l		d0-a6,-(sp)
				move.w		DEVICE,d0
				add.w		d0,d0
				move.w		.DEVICES_P(pc,d0.w),d0
				jsr			.DEVICES_P(pc,d0.w)
				movem.l		(sp)+,d0-a6
				rts


*---------------

				dc.w		DEVICE_FILE_2_P-.DEVICES_P
				dc.w		DEVICE_FILE_1_P-.DEVICES_P
.DEVICES_P:		dc.w		DEVICE_PRINTER_P-.DEVICES_P
				dc.w		DEVICE_RS232_P-.DEVICES_P
				dc.w		DEVICE_SCREEN_P-.DEVICES_P
				dc.w		DEVICE_MIDI_P-.DEVICES_P

*-------------------------------------------------------------------------------

DEVICE_SCREEN_C:move.w		ZEILEN_LAENGE,d1
				move.w		d3,d4
				mulu		d1,d4
				movea.l		ZEICHEN_ADRESSE,a2
				lea			(a2,d4.l),a2			; Adresse des Strings
				move.w		BILD_BREITE,d1
				bra.s		.entry
.loop:			move.b		(a3)+,(a2)+
.entry:			dbeq		d1,.loop
				bne.s		.not_eos

				moveq		#32,d6
				move.b		d6,-(a2)
				move.w		d1,d7					; 1...Bildbreite-1
.clear:			cmp.b		(a2)+,d6
				dbne		d1,.clear
				beq.s		.ende
				move.w		d1,d7					; 1...Bildbreite-1
				move.b		d6,-1(a2)
				dbra		d1,.clear
.ende:			sub.w		BILD_BREITE,d7
				neg.w		d7
				subq.w		#1,d7
				move.w		d7,BILD_BREITE_
				bsr			PRINT_LINE
				move.w		BILD_BREITE,BILD_BREITE_
				subq.w		#1,BILD_BREITE_
				rts
.not_eos:		tst.b		(a3)					; alle Zeichen schon kopiert?
				beq			PRINT_LINE
				cmpi.b		#32,(a3)+				; kommen nur noch Spaces?
				beq.s		.not_eos
				move.b		#3,-(a2)
				bra			PRINT_LINE

*-------------------------------------------------------------------------------

DEVICE_SCREEN_P:move.w		ZEILEN_LAENGE,d1
				move.w		d3,d4
				mulu		d1,d4
				movea.l		ZEICHEN_ADRESSE,a2
				lea			(a2,d4.l),a2			; Adresse des Strings
				move.w		BILD_BREITE,d1			; Bildbreite
				moveq		#0,d7
				move.b		(a3)+,d7				; StringlÑnge
				subq.w		#1,d7
				bmi.s		.cont
				bra.s		.entry1
.loop:			move.b		(a3)+,(a2)+
				subq.w		#1,d7
.entry1:		dbmi		d1,.loop
				bpl.s		.not_eos

.cont:			move.w		d1,d7					; 1...Bildbreite
				moveq		#32,d6
				bra.s		.entry2
.clear:			cmp.b		(a2)+,d6
				dbne		d1,.clear
				beq.s		.ende
				move.w		d1,d7					; 1...Bildbreite
				move.b		d6,-1(a2)
.entry2:		dbra		d1,.clear
.ende:			sub.w		BILD_BREITE,d7
				neg.w		d7
				subq.w		#1,d7
				move.w		d7,BILD_BREITE_
				bsr			PRINT_LINE
				move.w		BILD_BREITE,BILD_BREITE_
				subq.w		#1,BILD_BREITE_
				rts

.not_eos:		cmpi.b		#32,(a3)+
				dbne		d7,.not_eos
				beq			PRINT_LINE
				move.b		#3,-(a2)
				bra			PRINT_LINE

*-------------------------------------------------------------------------------

DEVICE_PRINTER_C:
				lea			PRINT_CHAR(pc),a0
				bra.s		DEVICE_C

*---------------

DEVICE_RS232_C:	lea			RS232_CHAR(pc),a0
				bra.s		DEVICE_C

*---------------

DEVICE_MIDI_C:	lea			MIDI_CHAR(PC),a0
				bra.s		DEVICE_C

*---------------

DEVICE_LOOP_C:	jsr			(a0)
				bne.s		DEVICE_FAIL_C
DEVICE_C:		move.b		(a3)+,d0
				bne.s		DEVICE_LOOP_C
				moveq		#13,d0					; Nullbyte ---> CR/LF senden
				jsr			(a0)
				bne.s		DEVICE_FAIL_C
				moveq		#10,d0
				jmp			(a0)
DEVICE_FAIL_C:	rts

*-------------------------------------------------------------------------------

DEVICE_PRINTER_P:
				lea			PRINT_CHAR(pc),a0
				bra.s		DEVICE_P

*---------------

DEVICE_RS232_P:	lea			RS232_CHAR(pc),a0
				bra.s		DEVICE_P

*---------------

DEVICE_MIDI_P:	lea			MIDI_CHAR(PC),a0

*---------------

DEVICE_P:		moveq		#0,d7
				move.b		(a3)+,d7
				bra.s		.entry
.loop:			move.b		(a3)+,d0
				jsr			(a0)
				bne.s		DEVICE_FAIL_P
.entry:			dbra		d7,.loop
				moveq		#13,d0					; CR/LF senden
				jsr			(a0)
				bne.s		DEVICE_FAIL_P
				moveq		#10,d0
				jmp			(a0)
DEVICE_FAIL_P:	rts

*-------------------------------------------------------------------------------

DEVICE_FILE_1_C:moveq		#-1,d7					; >Create File
				bsr.s		HANDLE_FILE
				bmi.s		DEVICE_FILE_FAIL
WRITE_FILE_C:	movea.l		a3,a2					; StringlÑnge bestimmen
				moveq		#-1,d3
.search:		addq.l		#1,d3
				tst.b		(a2)+
				bne.s		.search
				jsr			FWRITE
				bne.s		DEVICE_FILE_FAIL
				moveq		#2,d3					; 2 Zeichen
				lea			CRLF,a3					; CR/LF schreiben
				jmp			FWRITE

DEVICE_FILE_2_C:moveq		#1,d7					; >>Open File
				bsr.s		HANDLE_FILE
				bmi.s		DEVICE_FILE_FAIL
				jsr			FSEEK_END
				bne.s		DEVICE_FILE_FAIL
				bra.s		WRITE_FILE_C

*---------------

DEVICE_FILE_1_P:moveq		#-1,d7					; >Create File
				bsr.s		HANDLE_FILE
				bmi.s		DEVICE_FILE_FAIL
WRITE_FILE_P:	moveq		#0,d3
				move.b		(a3)+,d3
				jsr			FWRITE
				moveq		#2,d3					; 2 Zeichen
				lea			CRLF,a3					; CR/LF schreiben
				jmp			FWRITE

DEVICE_FILE_2_P:moveq		#1,d7					; >>Open File
				bsr.s		HANDLE_FILE
				bmi.s		DEVICE_FILE_FAIL
				jsr			FSEEK_END
				bne.s		DEVICE_FILE_FAIL
				bra.s		WRITE_FILE_P

*---------------

DEVICE_FILE_FAIL:
				moveq		#-1,d7
				rts

*---------------

* <--- flag.mi = Datei konnte nicht geîffnet werden
HANDLE_FILE:	move.l		a3,-(sp)
				tst.w		HANDLE					; File schon offen?
				bne.s		.file_offen
				lea			FILE_STRING,a2			; Filename
				tst.w		d7
				bmi.s		.create_file
				move.l		d0,-(sp)
				moveq		#1,d0
				jsr			FOPEN
				movem.l		(sp)+,d0				; movem wegen CCR
				bpl.s		.file_offen
.create_file:	jsr			FCREATE
.file_offen:	movem.l		(sp)+,a3				; movem wegen CCR
				rts

*-------------------------------------------------------------------------------
* Alle Routinen geben ein Zeichen aus, ein Timeout erzeugt eine Fehlermeldung,
* was der aufrufenden Routine durch ein Flag mitgeteilt wird, ne = Fehler
* ---> D0.b = auszugebendes Zeichen
*
* PRINT_CHAR: parallele Schnittstelle
* MIDI_CHAR:  MIDI Schnittstelle
* RS232_CHAR: serielle Schnittstelle
*-------------------------------------------------------------------------------

PRINT_CHAR:	MOVEM.L     D1/D3/A1/A3,-(SP)
		MOVE.L	    HZ200_ZAEHLER,D1
		SUB.L	    PRINTER_TIMEOUT(PC),D1
PRINTER_WAIT:	BTST	    #0,ST_GPIP.w
		BEQ.S	    PRINTER_READY
		CMP.L	    HZ200_ZAEHLER,D1
		BHI	    DEVICE_IS_BUSY
		BRA.S	    PRINTER_WAIT

PRINTER_READY:	sf	    DEVICE_BUSY
		MOVE	    SR,-(SP)
		ORI	    #$700,SR
		LEA	    GISELECT.w,A1
		MOVE.B	    #15,(A1)
		MOVE.B	    D0,2(A1)
		MOVE.B	    #14,(A1)
		MOVE.B	    (A1),D0
		BCHG	    #5,D0		  ; AND.B	#$DF,D0
		MOVE.B	    D0,2(A1)
		BCHG	    #5,D0		  ; OR.B	#$20,D0
		MOVE.B	    D0,2(A1)
		MOVE	    (SP)+,SR
		MOVEM.L     (SP)+,D1/D3/A1/A3
		TST.B	    DEVICE_BUSY
		RTS

*-------------------------------------------------------------------------------

MIDI_CHAR:	MOVEM.L     D1/D3/A1/A3,-(SP)
		MOVE.L	    HZ200_ZAEHLER,D1
		SUB.L	    MIDI_TIMEOUT(PC),D1
MIDI_WAIT:	BTST	    #1,ACIA_STATUS_MIDI.w
		BNE.S	    MIDI_READY
		CMP.L	    HZ200_ZAEHLER,D1
		BHI.S	    DEVICE_IS_BUSY
		BRA.S	    MIDI_WAIT

MIDI_READY:	sf	    DEVICE_BUSY
		MOVE.B	    D0,ACIA_DATA_MIDI.w
		MOVEM.L     (SP)+,D1/D3/A1/A3
		TST.B	    DEVICE_BUSY
		RTS

*-------------------------------------------------------------------------------

RS232_CHAR:	MOVEM.L     D1/D3/A1/A3,-(SP)
		BSET	    #0,ST_TSR.w
		MOVE.L	    HZ200_ZAEHLER,D1
		SUB.L	    RS232_TIMEOUT(PC),D1
RS232_WAIT:	BTST	    #7,ST_TSR.w
		BNE.S	    RS232_READY
		CMP.L	    HZ200_ZAEHLER,D1
		BHI.S	    DEVICE_IS_BUSY
		BRA.S	    RS232_WAIT

RS232_READY:	sf	    DEVICE_BUSY
		MOVE.B	    D0,ST_UDR.w
		MOVEM.L     (SP)+,D1/D3/A1/A3
		TST.B	    DEVICE_BUSY
		RTS

*-------------------------------------------------------------------------------

DEVICE_IS_BUSY: st	    DEVICE_BUSY
		LEA	    TIMEOUT_ERROR,A3
		BSR	    MessageRawDown_C
		MOVEM.L     (SP)+,D1/D3/A1/A3
		TST.B	    DEVICE_BUSY
		RTS

*-------------------------------------------------------------------------------
* PRINT_YLINE: Printet die aktuelle Zeile.
*
* PRINT_LINE: Printet eine Zeile, beherrscht Invers und Unterstrichen.
* ---> d3.w = Zeile die geprintet werden soll (0-...)
*
* PRINT_AT: Printet an einer bestimmten Position einen String.
*			Beherrscht Hell, Unterstrichen, Invers.
* ---> d0.w = X-Position
* ---> d1.w = Y-Position
* ---> d2.w = StringlÑnge (-1)
*
* SCROLL_UP_C: Bildschirm nach oben scrollen (von der ersten Zeile an).
*			   Die oberste Zeile wird gelîscht.
* SCROLL_UP: Bildschirm nach oben scrollen (von der ersten Zeile an).
*
* PULL_UP: Zieht den Screen nach oben.
* ---> d3.w = bis dahin wird gezogen (0-...)
*
* SCROLL_DOWN_C: Bildschirm nach unten scrollen (von der untersten Zeile an).
*				 Die unterste Zeile wird gelîscht.
* SCROLL_DOWN: Bildschirm nach unten scrollen (von der untersten Zeile an).
*
* PUSH_DOWN: Schiebt den Screen nach unten.
* ---> d3.w = ab hier wird nach unten gestossen (0-...)
*
* CLEAR_LINE: Zeile lîschen (Screen+Zeichenscreen).
* ---> d3.w = Zeile die es zu lîschen gilt
*
* POSITIONIEREN: Berechnet die Adresse des Cursors.
* ---> X_POSITION.w, Y_POSITION.w
* <--- ZEICHEN_POSITION.w, BILDSCHIRM_POSITION.l
*
* CURSOR_ON: Schaltet den Cursor an.
*
* CURSOR_OFF: Schaltet den Cursor ab.
*-------------------------------------------------------------------------------

PRINT_Y_LINE:	move.w		d3,-(sp)
				move.w		Y_POSITION,d3
				bsr.s		PRINT_LINE
				move.w		(sp)+,d3
				rts

*-------------------------------------------------------------------------------

PRINT_LINE:		bsr			HIDEM
				bsr			CURSOR_OFF

				movem.l		d0-a6,-(sp)

				move.w		BILD_BREITE_,d5		; d5 = SchleifezÑhler Zeichen
				bmi			.ende
				move.b		INVERS,d2			; Zeilenadresse invers printen?
				jsr			GET_ADRESS_1		; Zeilenadresse $xxxxxxxx>
				bne.s		.PCNotInvers
				cmp.l		SAVE_PC,d0
				bne.s		.PCNotInvers
				not.b		d2
				moveq		#8,d5				; 9 Zeichen invers printen
				move.l		d0,OLD_PC			; fÅr SET_PC (lîschen des Inversen)

.PCNotInvers:	move.w		d3,d0				; Zeichenadresse berechnen
				mulu		ZEILEN_LAENGE(pc),d0
				movea.l		ZEICHEN_ADRESSE(pc),a3
				adda.l		d0,a3				; a3 = Zeichenadresse

				mulu		BYTES_ZEILE,d3		; Bildschirmadresse berechnen
				movea.l		BILD_ADRESSE,a5
				adda.l		d3,a5				; a5 = Bildschirmadresse

				movea.l		FONT,a1				; a1 = Fontadresse

				tst.b		TRUECOLOR
				beq			.plane

*--------------- True Color, Normal/Invers/Underline
				not.b		d2
				move.w		FONT_FLAG(pc),d7	; d7 = 3 oder 4
				move.w		SCREEN_BREITE(pc),d6; d6 = Screenbreite
				moveq		#-16,d3
				add.w		BYTES_ZEILE,d3		; d3 = 16/8*Bytes-16
				lea			TC_table,a0			; a0 = Tabelle

.PRINT_1:		moveq		#0,d0
				move.b		(a3)+,d0			; Zeichen holen
				lsl.w		d7,d0
				lea			(a1,d0.w),a2		; a2 = Charadresse (Font)
				move.w		SCAN_LINES,d1		; 8 oder 16
				subq.w		#1,d1
				add.b		UNDERLINE,d1
.inner_loop:	moveq		#0,d0
				move.b		(a2)+,d0
				eor.b		d2,d0
				add.w		d0,d0
				movem.l		(a0,d0.w*8),d0/d4/a4/a6
				movem.l		d0/d4/a4/a6,(a5)
				add.w		d6,a5
				dbra		d1,.inner_loop
				tst.b		UNDERLINE
				beq.s		.not_underline
				moveq		#32,d0
				lsl.w		d7,d0
				move.l		(a1,d0.w),d0
				move.l		d0,(a5)+
				move.l		d0,(a5)+
				move.l		d0,(a5)+
				move.l		d0,(a5)+
				lea			-16(a5,d6.w),a5
.not_underline:	suba.w		d3,a5
				dbra		d5,.PRINT_1
				cmp.b		INVERS,d2
				bne			.ende
				not.b		d2
				move.w		BILD_BREITE_,d5
				subi.w		#9,d5				; d5 = SchleifezÑhler Zeichen
				bpl			.PRINT_1
.ende:			movem.l		(sp)+,d0-a6
				bsr			CURSOR_ON
				bra			SHOWM

*--------------- Planeorientiert
.plane:			moveq		#1,d3				; d3 = Summand fÅr Bildpointer
				swap		d3
				move.w		PLANES(pc),d3
				move.w		d3,d4				; d4 = SchleifenzÑhler Planes,
				subq.w		#1,d4				;	   Bitplanes-1
				add.w		d3,d3
				subq.w		#1,d3				; d3 = 2*Bitplanes-1
				tst.b		PLANE_FLAG
				beq.s		.plane_gerade
				swap		d3
.plane_gerade:	move.w		FONT_FLAG(pc),d7	; d7 = 3 oder 4
				move.w		SCAN_LINES,d6		; d6 = 8/16, Summand Bildpointer

				tst.b		d2
				bne			PRINT_INVERS
				tst.b		UNDERLINE
				bne			PRINT_UNDERLINE

*--------------- Planeorientiert, Normal
PRINT_1:		moveq		#0,d0
				move.b		(a3)+,d0
				lsl.w		d7,d0				; d7 = 3 oder 4
				lea			(a1,d0.w),a2		; a2 = Charadresse (Font)
				move.w		d4,d0				; d0 = schleifenzÑhler Planes
PRINT_2:		move.b		(a2)+,(a5)+
PATCH_OFFSET:	move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
PATCH_FONT:		move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				suba.w		d6,a2				; d6 = 8 oder 16
				addq.w		#1,a5
				dbra		d0,PRINT_2
				suba.w		d3,a5
				swap		d3
				dbra		d5,PRINT_1
				movem.l		(sp)+,d0-a6
				bsr			CURSOR_ON
				bra			SHOWM

*--------------- Planeorientiert, Invers
PRINT_INVERS:	moveq		#0,d0
				move.b		(a3)+,d0
				lsl.w		d7,d0
				lea			(a1,d0.w),a2
				move.w		d4,d0
PRINT_2_I:		move.b		(a2)+,(a5)
				not.b		(a5)+
PATCH_OFFSET_I:	move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
PATCH_FONT_I:	move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
				move.b		(a2)+,1(a5)
				not.b		1(a5)
				suba.w		d6,a2				; d6 = 8 oder 16
				addq.w		#1,a5
				dbra		d0,PRINT_2_I
				suba.w		d3,a5
				swap		d3
				dbra		d5,PRINT_INVERS
				cmp.b		INVERS,d2
				beq.s		.cont
				move.w		BILD_BREITE_,d5
				subi.w		#9,d5				; d5 = SchleifezÑhler Zeichen
				bpl			PRINT_1
.cont:			movem.l		(sp)+,d0-a6
				bsr			CURSOR_ON
				bra			SHOWM

*--------------- Planeorientiert, Underline
PRINT_UNDERLINE:subq.w		#1,d6
				moveq		#32,d2
				lsl.w		d7,d2
				move.b		(a1,d2.w),d2
				not.b		d2				; zum Unterstreichen
PRINT_1_U:		moveq		#0,d0
				move.b		(a3)+,d0
				lsl.w		d7,d0
				lea			(a1,d0.w),a2
				move.w		d4,d0
PRINT_2_U:		move.b		(a2)+,(a5)+
PATCH_OFFSET_U:	move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
PATCH_LINE:		move.b		(a2)+,1(a5)
PATCH_FONT_U:	move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		(a2)+,1(a5)
				move.b		d2,1(a5)
				suba.w		d6,a2				; d6 = 7 oder 15
				addq.w		#1,a5
				dbra		d0,PRINT_2_U
				suba.w		d3,a5
				swap		d3
				dbra		d5,PRINT_1_U
				movem.l		(sp)+,d0-a6
				bsr			CURSOR_ON
				bra			SHOWM

*-------------------------------------------------------------------------------

PRINT_AT:		bsr			HIDEM
				bsr			CURSOR_OFF
				movem.l		d0-a6,-(sp)
				move.w		d0,d3
				add.w		d2,d3
				sub.w		BILD_BREITE(pc),d3
				blt.s		.length_io
				sub.w		d3,d2
				subq.w		#1,d2
				bmi			.nicht_im_Bild
.length_io:		tst.b		TRUECOLOR
				bne			PRINT_AT_TC


*--------------- Planeorientiert
				move.w		d1,d3
				mulu		ZEILEN_LAENGE(pc),d3
				add.w		d0,d3
				movea.l		ZEICHEN_ADRESSE(pc),a0
				lea			(a0,d3.w),a0		; a0 = Stringadresse

				moveq		#0,d4
				move.w		PLANES(pc),d4
				add.w		d4,d4
				move.w		SCREEN_BREITE(pc),d5
				sub.w		d4,d5				; Byteszeile-2*Bitplanes
				subq.w		#2,d4				; 2*Bitplanes-2
				moveq		#-1,d6
				tst.b		HELL
				beq.s		.not_hell
				moveq		#%1010101,d6
.not_hell:		moveq		#1,d3
				add.w		OFFSET_X(pc),d0
				and.w		d0,d3
				beq.s		.zero
				swap		d4
.zero:			andi.b		#$fe,d0
				mulu		PLANES(pc),d0
				add.w		d3,d0
				mulu		BYTES_ZEILE,d1
				add.l		d1,d0
				movea.l		BILDSCHIRM_ADRESSE(pc),a1
				adda.l		ABSTAND_Y,a1
				lea			(a1,d0.l),a1		; A1 = Bildadresse

				movea.l		FONT,a4
				move.w		FONT_FLAG(pc),d7

.length_loop:	moveq		#0,d0
				move.b		(a0)+,d0
				lsl.w		d7,d0
				lea			(a4,d0.w),a2		; a2 = Fontadresse
				moveq		#1,d1
				lsl.w		d7,d1
				subq.w		#1,d1
				movea.l		a1,a3
.scan_loop:		move.b		(a2)+,d0
				rol.b		#1,d6
				and.b		d6,d0
				tst.b		UNDERLINE
				beq.s		.not_underline
				tst.w		d1
				bne.s		.not_underline
				moveq		#32,d0
				lsl.w		d7,d0
				move.b		(a4,d0.w),d0
				not.b		d0
.not_underline:	move.b		INVERS,d3
				eor.b		d3,d0
				move.w		PLANES(pc),d3
				subq.w		#1,d3
.plane_loop:	move.b		d0,(a1)
				addq.w		#2,a1
				dbra		d3,.plane_loop
				adda.w		d5,a1
				dbra		d1,.scan_loop
				swap		d4
				lea			1(a3,d4.w),a1
				dbra		d2,.length_loop
.nicht_im_Bild:	movem.l		(sp)+,d0-a6
				bsr			CURSOR_ON
				bra			SHOWM

*--------------- True Color
PRINT_AT_TC:	move.w		d2,d5				; d5 = SchleifezÑhler Zeichen

				move.w		d1,d2				; Zeichenadresse berechnen
				mulu		ZEILEN_LAENGE(pc),d2
				movea.l		ZEICHEN_ADRESSE(pc),a3
				adda.w		d0,a3
				adda.l		d2,a3				; a3 = Zeichenadresse

				lsl.w		#4,d0				; X-Abstand in Bytes
				mulu		BYTES_ZEILE,d1		; Y-Abstand in Bytes
				move.l		BILDSCHIRM_ADRESSE,a5
				adda.w		d0,a5
				adda.l		d1,a5
				adda.l		ABSTAND_X,a5
				adda.l		ABSTAND_Y,a5

				movea.l		FONT,a1				; a1 = Fontadresse
				move.b		INVERS,d2			; d2 = Inversflag
				not.b		d2

				move.w		FONT_FLAG(pc),d7	; d7 = 3 oder 4
				moveq		#-1,d6
				tst.b		HELL
				beq.s		.not_hell
				moveq		#%1010101,d6
.not_hell:		moveq		#-16,d3
				add.w		BYTES_ZEILE,d3		; d3 = 16/8*Bytes-16
				lea			TC_table,a0			; a0 = Tabelle

.PRINT_1:		moveq		#0,d0
				move.b		(a3)+,d0			; Zeichen holen
				lsl.w		d7,d0
				lea			(a1,d0.w),a2		; a2 = Charadresse (Font)
				move.w		SCAN_LINES,d1		; 8 oder 16
				subq.w		#1,d1
				add.b		UNDERLINE,d1
.inner_loop:	moveq		#0,d0
				move.b		(a2)+,d0
				rol.b		#1,d6
				and.b		d6,d0
				eor.b		d2,d0
				add.w		d0,d0
				movem.l		(a0,d0.w*8),d0/d4/a4/a6
				movem.l		d0/d4/a4/a6,(a5)
				adda.w		SCREEN_BREITE(pc),a5
				dbra		d1,.inner_loop
				tst.b		UNDERLINE
				beq.s		.not_underline
				moveq		#32,d0
				lsl.w		d7,d0
				move.l		(a1,d0.w),d0
				move.l		d0,(a5)+
				move.l		d0,(a5)+
				move.l		d0,(a5)+
				move.l		d0,(a5)+
				lea			-16(a5),a5
				adda.w		SCREEN_BREITE(pc),a5
.not_underline:	suba.w		d3,a5
				dbra		d5,.PRINT_1
				movem.l		(sp)+,d0-a6
				bsr			CURSOR_ON
				bra			SHOWM

*-------------------------------------------------------------------------------

SCROLL_UP_C:	move.w		d3,-(sp)
				move.w		FIRST_LINE,d3
				bsr.s		PUSH_DOWN
				bsr			CLEAR_LINE
				move.w		(sp)+,d3
				rts

*-------------------------------------------------------------------------------

SCROLL_UP:		move.w		d3,-(sp)
				move.w		FIRST_LINE,d3
				bsr.s		PUSH_DOWN
				move.w		(sp)+,d3
				rts

*-------------------------------------------------------------------------------

PUSH_DOWN:		bsr			HIDEM
				bsr			CURSOR_OFF
				movem.l		d0-a6,-(sp)
				move.w		ZEILEN_SCREEN,d0
				sub.w		d3,d0
				subq.w		#2,d0
				bmi			UNTERSTE_ZEILE

				movea.l		ZEICHEN_ADRESSE(pc),a1	; Zeichenscreen scrollen
				adda.w		ZEICHEN_SCREEN,a1
				movea.l		a1,a0
				move.w		ZEILEN_LAENGE(pc),d0
				suba.w		d0,a0
				move.w		ZEILEN_SCREEN,d1
				sub.w		d3,d1
				subq.w		#1,d1
				mulu		d0,d1
				lsr.w		#2,d1
				bcc.s		.up_l
				move.w		-(a0),-(a1)
.up_l:			lsr.w		#1,d1
				bcc.s		.up_2l
				move.l		-(a0),-(a1)
.up_2l:			lsr.w		#1,d1
				bcc.s		.up_4l
				move.l		-(a0),-(a1)
				move.l		-(a0),-(a1)
				bra.s		.up_4l
.up_loop_1:		move.l		-(a0),-(a1)
				move.l		-(a0),-(a1)
				move.l		-(a0),-(a1)
				move.l		-(a0),-(a1)
.up_4l:			dbra		d1,.up_loop_1

				move.w		ZEILEN_SCREEN,d1		; Bildschirm scrollen
				sub.w		d3,d1
				subq.w		#1,d1
				mulu		SCAN_LINES,d1
				subq.w		#1,d1					; d1 = Anzahl Rasterzeilen
				move.w		ZEILEN_SCREEN,d0
				subq.w		#1,d0
				mulu		BYTES_ZEILE,d0
				movea.l		BILD_ADRESSE,a0
				adda.l		d0,a0
				suba.w		SCREEN_BREITE(PC),a0
				movea.l		a0,a1
				adda.w		BYTES_ZEILE,a1
				tst.b		TRUECOLOR
				beq.s		.plane

*--------------- Scrollen, True Color
.TC:			move.w		BILD_BREITE(pc),d2
				lsl.w		#4,d2
				add.w		SCREEN_BREITE(pc),d2	; Summand
				bra			SCROLL_TC

*--------------- Scrollen, Planeorientiert
.plane:			movem.l		a0-a1,-(sp)
				bsr.s		COPY_Z
				movem.l		(sp)+,a0-a1
				suba.w		SCREEN_BREITE(PC),a0
				suba.w		SCREEN_BREITE(PC),a1
				dbra		d1,.plane
UNTERSTE_ZEILE:	movem.l		(sp)+,d0-a6
				bsr			CURSOR_ON
				bra			SHOWM

*-------------------------------------------------------------------------------

* kopiert eine Rasterzeile (nur den sichtbaren Bereich)
COPY_Z:			bsr.s		COPY_PLANE
				move.w		#1234,d0
				bra.s		UPS_8L
UP_SCHLEIFE_4:	movem.l		(a0)+,d2-d7/a2/a5
				movem.l		d2-d7/a2/a5,(a1)
				lea			32(a1),a1
UPS_8L:			dbra		d0,UP_SCHLEIFE_4
				move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
				bsr.s		COPY_PLANE
				rts
COPY_PLANE:		move.w		PLANES(pc),d0
				subq.w		#1,d0
.copy:			move.b		(a0),(a1)
				addq.w		#2,a0
				addq.w		#2,a1
				dbra		d0,.copy
				subq.w		#1,a0
				subq.w		#1,a1
				rts

*-------------------------------------------------------------------------------

CLEAR_LINE:		movem.l		d0-d1/a0,-(sp)
				move.w		d3,d0
				mulu		ZEILEN_LAENGE(pc),d0
				movea.l		ZEICHEN_ADRESSE(pc),a0
				adda.l		d0,a0
				moveq		#32,d0
				move.w		ZEILEN_LAENGE(pc),d1
				bra.s		.entry
.clear:			move.b		d0,(a0)+
.entry:			dbra		d1,.clear
				bsr			PRINT_LINE
				movem.l		(sp)+,d0-d1/a0
				rts

*-------------------------------------------------------------------------------

SCROLL_DOWN_C:	move.w		d3,-(sp)
				move.w		FIRST_LINE,d3
				bsr.s		PULL_UP
				move.w		ZEILEN_SCREEN,d3
				subq.w		#1,d3
				bsr.s		CLEAR_LINE
				move.w		(sp)+,d3
				rts

*-------------------------------------------------------------------------------

SCROLL_DOWN:	move.w		d3,-(sp)
				move.w		FIRST_LINE,d3
				bsr.s		PULL_UP
				move.w		(sp)+,d3
				rts

*-------------------------------------------------------------------------------

PULL_UP:		bsr			HIDEM
				bsr			CURSOR_OFF
				movem.l		d0-a6,-(sp)

				move.w		ZEILEN_SCREEN,d1
				sub.w		d3,d1
				subq.w		#2,d1
				bmi			UNTERSTE_ZEILE

				movea.l		ZEICHEN_ADRESSE(pc),a1	; Zeichenscreen scrollen
				move.w		ZEILEN_LAENGE(PC),d0
				move.w		d3,d1
				mulu		d0,d1
				adda.w		d1,a1
				lea			(a1,d0.w),a0
				move.w		ZEILEN_SCREEN,d1
				sub.w		d3,d1
				subq.w		#1,d1
				mulu		d0,d1
				lsr.w		#2,d1
				bcc.s		.down_l
				move.w		(a0)+,(a1)+
.down_l:		lsr.w		#1,d1
				bcc.s		.down_2l
				move.l		(a0)+,(a1)+
.down_2l:		lsr.w		#1,d1
				bcc.s		.down_4l
				move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
				bra.s		.down_4l
.down_loop_1:	move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
				move.l		(a0)+,(a1)+
.down_4l:		dbra		d1,.down_loop_1

				move.w		ZEILEN_SCREEN,d1		; Bildschirm scrollen
				sub.w		d3,d1
				subq.w		#1,d1
				mulu		SCAN_LINES,d1
				subq.w		#1,d1					; d1 = Anzahl Rasterzeilen
				mulu		BYTES_ZEILE,d3
				movea.l		BILD_ADRESSE,a1
				adda.l		d3,a1
				movea.l		a1,a0
				adda.w		BYTES_ZEILE,a0
				tst.b		TRUECOLOR
				bne.s		.TC

*--------------- Scrollen, Planeorientiert
.down_loop_2:	movem.l		a0-a1,-(sp)
				bsr			COPY_Z
				movem.l		(sp)+,a0-a1
				adda.w		SCREEN_BREITE(pc),a0
				adda.w		SCREEN_BREITE(pc),a1
				dbra		d1,.down_loop_2
				movem.l		(sp)+,d0-a6
				bsr			CURSOR_ON
				bra			SHOWM

*--------------- Scrollen, True Color
.TC:			move.w		BILD_BREITE(pc),d2
				lsl.w		#4,d2
				sub.w		SCREEN_BREITE(pc),d2	; Summand

SCROLL_TC:		move.w		BILD_BREITE(pc),d0
				lsr.w		#1,d0
				bcc.s		.char_2
				movem.l		(a0)+,d3-d6
				movem.l		d3-d6,(a1)
				lea			16(a1),a1
.char_2:		lsr.w		#1,d0
				bcc.s		.char_4
				movem.l		(a0)+,d3-d7/a3-a5
				movem.l		d3-d7/a3-a5,(a1)
				lea			32(a1),a1
				bra.s		.char_4
.loop:			movem.l		(a0)+,d3-d7/a3-a5
				movem.l		d3-d7/a3-a5,(a1)
				movem.l		(a0)+,d3-d7/a3-a5
				movem.l		d3-d7/a3-a5,32(a1)
				lea			64(a1),a1
.char_4:		dbra		d0,.loop
				suba.w		d2,a0
				suba.w		d2,a1
				dbra		d1,SCROLL_TC
				movem.l		(sp)+,d0-a6
				bsr			CURSOR_ON
				bra			SHOWM

*-------------------------------------------------------------------------------

POSITIONIEREN:	bsr			CURSOR_OFF
				movem.l		d0-d2/a0,-(sp)
				move.w		X_POSITION,d0
				cmp.w		BILD_BREITE(pc),d0
				blo.s		.breite_io
				move.w		BILD_BREITE(pc),d0
				subq.w		#1,d0
.breite_io:		move.w		Y_POSITION,d1
				cmp.w		ZEILEN_SCREEN,d1
				blo.s		.hoehe_io
				move.w		ZEILEN_SCREEN,d1
				subq.w		#1,d1
.hoehe_io:		move.w		d0,X_POSITION
				move.w		d1,Y_POSITION

				tst.b		TRUECOLOR
				bne.s		.TC

				moveq		#1,d2					; Planeorientiert
				add.w		OFFSET_X(pc),d0
				and.w		d0,d2
				and.b		#$fe,d0
				mulu		PLANES(pc),d0
				add.w		d2,d0					; X-Abstand in Bytes
				addq.w		#1,d1
				mulu		BYTES_ZEILE,d1			; Y-Abstand in Bytes
				move.l		BILDSCHIRM_ADRESSE,a0
				adda.w		d0,a0
				adda.l		d1,a0
				adda.l		ABSTAND_Y,a0
				suba.w		SCREEN_BREITE(pc),a0
				move.l		a0,BILDSCHIRM_POSITION	; Screen_position
				movem.l		(sp)+,d0-d2/a0
				bra.s		CURSOR_ON

.TC:			lsl.w		#4,d0					; X-Abstand in Bytes
				addq.w		#1,d1
				mulu		BYTES_ZEILE,d1			; Y-Abstand in Bytes
				move.l		BILD_ADRESSE,a0
				adda.w		d0,a0
				adda.l		d1,a0
				suba.w		SCREEN_BREITE(pc),a0
				move.l		a0,BILDSCHIRM_POSITION	; Screen_position
				movem.l		(sp)+,d0-d2/a0
* ACHTUNG: Hier folgt CURSOR_ON!

*-------------------------------------------------------------------------------

CURSOR_ON:		addq.b		#1,CURSOR_ZAEHLER
				cmpi.b		#1,CURSOR_ZAEHLER
				beq.s		CURSOR_INVERTIEREN
				rts
CURSOR_OFF:		subq.b		#1,CURSOR_ZAEHLER
				beq.s		CURSOR_INVERTIEREN
				rts

*---------------

CURSOR_INVERTIEREN:
				bsr			HIDEM
				movem.l		d0-d1/a0,-(sp)
				movea.l		BILDSCHIRM_POSITION,a0
				move.w		SCAN_LINES,d0
				tst.b		INSERT_FLAG
				bne.s		.modus_io
				lsr.w		#3,d0
.modus_io:		subq.w		#1,d0

				tst.b		TRUECOLOR
				bne.s		.TC

.loop_0:		move.w		PLANES(pc),d1
				subq.w		#1,d1					; Anzahl Planes
.loop_1:		not.b		(a0)
				addq.w		#2,a0					; Next Bitplane
				dbra		d1,.loop_1
				suba.w		PLANES(pc),a0
				suba.w		PLANES(pc),a0
				suba.w		SCREEN_BREITE(pc),a0
				dbra		d0,.loop_0
				movem.l		(sp)+,d0-d1/a0
				bra			SHOWM

.TC:			move.w		SCREEN_BREITE(pc),d1
				addi.w		#16,d1
.loop_2:		not.l		(a0)+
				not.l		(a0)+
				not.l		(a0)+
				not.l		(a0)+
				suba.w		d1,a0
				dbra		d0,.loop_2
				movem.l		(sp)+,d0-d1/a0
				bra			SHOWM

*---------------

BILDSCHIRM_POSITION:
				ds.l		1						; Cursoradresse Bildschirm, letzte Scanline

*-------------------------------------------------------------------------------
* unterstrichene Routinen werden exportiert
*
* CLEAR_SCREEN: Lîscht den Bildschirm.
* -------------
* GET_PARAMETER: Holt sich alle fÅr den Bildschirmtreiber nîtigen Parameter vom
* -------------- Linea: *Screenbreite.w, *Screenhoehe.w, *Planes.w.
*				 Offset_x.w, Offset_y.w, Bildbreite.w, Bildhoehe.w und
*				 Zeilen_lÑnge werden gesetzt.
* NEW_SCREEN:	 Holt sich alle fÅr den Bildschirmtreiber nîtigen Pointer:
* ----------	 Bildschirm_malloc.l + Bildschirm_adresse.l, Zeichen_adresse.l,
*				 Maus_puffer.l.
*				 ---> (sp).w
*				 Bit 0: Bildschirm
*				 Bit 1: Zeichenscreen
*				 Bit 2: Maus_puffer
*				 <--- (sp).w	0 = Fehler beim reservieren (Gemdos)
* KILL_SCREEN:	 Die von NEW_SCREEN reservierten Speicherbereiche werden ge-
* -----------	 lîscht und freigegeben, sie mÅssen neu gesetzt werden (mittels
*				 NEW_SCREEN oder vom aufrufenden Programm).
*				 ---> wie bei NEW_SCREEN
* NEW_FORMAT:	 Nach GET_PARAMETER oder NEW_SCREEN muss diese Routine aufge-
* ----------	 rufen werden, um die restlichen Screenvariablen zu berechnen.
* ROUTINE_A:	 Entspricht dem New_format ohne Setmouse.
* PRINT_SCREEN:	 Baut den Bildschirm neu auf, inkl. MenÅ und Register.
* ------------
* Die Routinen werden in der Regel wie folgt aufgerufen: CLEAR_SCREEN,
* GET_PARAMETER, KILL_SCREEN, NEW_SCREEN, NEW_FORMAT, PRINT_SCREEN.
*-------------------------------------------------------------------------------

CLEAR_SCREEN:	bsr			HIDEM
				move.l		d3,-(sp)
				clr.b		CURSOR_ZAEHLER
				move.w		ZEILEN_SCREEN,d3		; Zeilenscreen lîschen
				bra.s		.entry
.loop:			bsr			CLEAR_LINE
.entry:			dbra		d3,.loop
				move.l		(sp)+,d3
				bra			SHOWM

*-------------------------------------------------------------------------------

GET_PARAMETER:	movem.l		d0-a6,-(sp)
				aline		#0
				lea			OFFSET_X(pc),a1
				move.l		_OFFSET_X,(a1)+		; Offset_x, Offset_y
				move.w		2(a0),d0			; Bytes pro Bildschirmzeile
				divu		(a0),d0				; / Planes = Zeichen je Zeile
				move.w		_BILD_BREITE,(a1)	; Bild_breite
				bne.s		.default_breite
				move.w		d0,(a1)
.default_breite:addq.w		#2,a1
				addq.w		#1,d0				; ZeilenlÑnge aufrunden
				andi.w		#$fffe,d0
				cmpi.w		#80,d0				; und mindestens 80 Zeichen!
				bhs.s		.ok_laenge
				moveq		#80,d0
.ok_laenge:		move.w		d0,(a1)+			; ZeilenlÑnge
				move.w		_BILD_HOEHE,(a1)	; Bild_hoehe
				bne.s		.default_hoehe
				move.w		-4(a0),(a1)
.default_hoehe:	addq.w		#2,a1
				move.w		2(a0),(a1)+			; Bytes pro Bildschirmzeile
				move.w		-4(a0),(a1)+		; Screenhîhe in Pixel
				move.w		_PLANES,(a1)		; Anzahl Planes
				bne.s		.default_planes
				move.w		(a0),(a1)
.default_planes:cmpi.b		#3,VDO				; nur ST/STE/TT
				bhi.s		.ende
				beq.s		.f030
				move.b		SHIFTMD_ST.w,SET_SHIFTMD_ST
				cmpi.b		#2,VDO
				bne.s		.ende
				move.w		SHIFTMD_TT.w,SET_SHIFTMD_TT
				bra.s		.ende
.f030:			lea			SET_FALCON_REG,a0
				bsr			GET_FALCON
.ende:			movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

KILL_SCREEN:	movem.l		d0-a6,-(sp)
				btst		#0,65(sp)			; Bildschirm freigeben
				beq.s		.no_screen
				move.l		BILDSCHIRM_MALLOC,-(sp)
				jsr			MFREE
.no_screen:		btst		#1,65(sp)			; Zeichenscreen freigeben
				beq.s		.no_zeichen
				move.l		ZEICHEN_ADRESSE,-(sp)
				jsr			MFREE
.no_zeichen:	btst		#2,65(sp)			; Mauspuffer freigeben
				beq.s		.ende
				move.l		MAUS_PUFFER,-(sp)
				jsr			MFREE
.ende:			movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

NEW_SCREEN:		movem.l		d0-a6,-(sp)
				clr.b		CURSOR_ZAEHLER

				move.w		BILD_HOEHE(pc),d0
				lsr.w		#3,d0
				move.w		d0,ZEILEN_SCREEN_8_8	; Anzahl Zeilen 8*8 Font
				mulu		ZEILEN_LAENGE(pc),d0
				move.w		d0,ZEICHEN_SCREEN_8_8	; Anzahl Zeichen 8*8 Font

				btst		#0,65(sp)				; Bildschirm reservieren
				beq.s		.no_screen
				move.l		_BILDSCHIRM_LENGTH,d0
				bne.s		.default_screen
				move.w		SCREEN_BREITE(pc),d0
				mulu		SCREEN_HOEHE(pc),d0
				addi.l		#256,d0
.default_screen:move.l		d0,-(sp)
				jsr			MXALLOC
				beq.s		.fail
				move.l		d0,BILDSCHIRM_MALLOC
				clr.b		d0
				movea.l		d0,a0
				lea			256(a0),a0
				move.l		a0,BILDSCHIRM_ADRESSE

.no_screen:		btst		#1,65(sp)				; Zeichenscreen reservieren
				beq.s		.no_zeichen
				move.l		_ZEICHEN_LENGTH,d0
				bne.s		.default_zeichen
				moveq		#0,d0
				move.w		ZEICHEN_SCREEN_8_8,d0
.default_zeichen:move.l		d0,d1
				move.l		d0,-(sp)
				jsr			MALLOC
				beq.s		.fail
				move.l		d0,ZEICHEN_ADRESSE
				movea.l		d0,a0
				move.l		d1,d0
				subq.l		#1,d0
				jsr			ClearMemorySpace

.no_zeichen:	btst		#2,65(sp)				; Mauspuffer reservieren
				beq.s		.ende
				move.l		_MAUS_LENGTH,d0
				bne.s		.default_maus
				moveq		#64,d0
				mulu		PLANES(pc),d0
.default_maus:	move.l		d0,-(sp)
				jsr			MALLOC
				beq.s		.fail
				move.l		d0,MAUS_PUFFER

.ende:			movem.l		(sp)+,d0-a6
				move.w		#-1,4(sp)
				rts

.fail:			movem.l		(sp)+,d0-a6
				clr.w		4(sp)
				rts

*-------------------------------------------------------------------------------

NEW_FORMAT:		movem.l		d0-a6,-(sp)
				bsr.s		ROUTINE_A
				move.w		BILD_BREITE,d2		; (d2,d3) = (X,Y) zentriert
				lsr.w		#1,d2
				add.w		OFFSET_X,d2
				lsl.w		#3,d2				; Zeichen*8 = Pixel
				move.w		BILD_HOEHE,d3
				lsr.w		#1,d3
				add.w		OFFSET_Y,d3
				bsr			SET_MOUSE			; Maus neu setzen
				movem.l		(sp)+,d0-a6
				rts

*--------------

ROUTINE_A:		clr.b		CURSOR_ZAEHLER

				move.w		ZEILEN_LAENGE,d0	; ZeilenlÑnge muss mindestens
				addq.w		#1,d0				; 80 Zeichen betragen
				andi.w		#$fffe,d0
				cmpi.w		#80,d0
				bhs.s		.length_io
				moveq		#80,d0
.length_io:		move.w		d0,ZEILEN_LAENGE

				lea			POSITION_FTASTE,a0
				clr.l		(a0)+
				clr.l		(a0)+
				clr.l		(a0)+

				move.w		BILD_BREITE(PC),d2
				move.w		d2,BILD_BREITE_
				subq.w		#1,BILD_BREITE_
				clr.w		ASCII_BREITE
				clr.w		DUMP_BREITE
				subi.w		#15,d2
				bmi.s		.too_short
				move.w		d2,ASCII_BREITE		; Ascii_breite
				addq.w		#1,d2
				lsr.w		#2,d2
				move.w		d2,DUMP_BREITE		; Dump_breite

				jsr			TestTC				; True Color Auflîsung?
				sne			TRUECOLOR
				beq.s		.planes
				moveq		#0,d0
				move.w		OFFSET_X(pc),d0
				lsl.w		#4,d0				; Zeichen*8*2=Bytes
				bra.s		.cont
.planes:		move.w		OFFSET_X(pc),d0
				moveq		#1,d1
				and.w		d0,d1
				sne			PLANE_FLAG			; Plane_flag
				andi.w		#$fffe,d0
				mulu		PLANES(pc),d0
				add.l		d1,d0
.cont:			move.w		OFFSET_Y(pc),d1
				mulu		SCREEN_BREITE(pc),d1
				move.l		d0,ABSTAND_X		; Abstand_x
				move.l		d1,ABSTAND_Y		; Abstand_y
				add.l		d1,d0
				add.l		BILDSCHIRM_ADRESSE(PC),d0
				move.l		d0,BILD_ADRESSE		; Bildadresse

*--------------- Jetzt wird die Printroutine erzeugt
.too_short:		lea			PATCH_OFFSET+2(PC),a1
				lea			PATCH_OFFSET_I+2(PC),a2
				lea			PATCH_OFFSET_U+2(PC),a3
				moveq		#14,d2
				moveq		#-1,d1
				move.w		SCREEN_BREITE(PC),d0
.loop:			add.w		d0,d1
				move.w		d1,(a1)
				move.w		d1,(a2)
				move.w		d1,4(a2)
				move.w		d1,(a3)
				addq.w		#4,a1
				addq.w		#8,a2
				addq.w		#4,a3
				dbra		d2,.loop

*--------------- Jetzt wird die Scrollroutine erzeugt
		LEA			COPY_Z(PC),A0

		MOVE.W	    #$4E71,(A0)
		MOVE.W	    BILD_BREITE(PC),D0
		TST.B	    PLANE_FLAG
		BEQ.S	    GERADE
		MOVE.W	    #$6100+COPY_PLANE-COPY_Z-2,(A0)
		SUBQ.W	    #1,D0
GERADE: 	BTST	    #0,D0
		SNE	    LOCAL_FLAG
		BEQ.S	    PLANE_IO
		SUBQ.W	    #1,D0
PLANE_IO:	MULU	    PLANES(PC),D0

		MOVE.W	    D0,D1
		LSR.W	    #5,D1
		MOVE.W	    D1,4(A0)
		LEA	    UPS_8L+4(PC),A0
		MOVE.W	    D0,D1
		LSR.W	    #2,D1
		BCC.S	    NO_WORD
		MOVE.W	    #$32D8,(A0)+
NO_WORD:	AND.W	    #7,D1
		BRA.S	    LONG_ANFANG
LONG:		MOVE.W	    #$22D8,(A0)+
LONG_ANFANG:	DBRA	    D1,LONG
		MOVE.W	    #$4E71,(A0)
		TST.B	    LOCAL_FLAG
		BEQ.S	    GERADE_2
		LEA	    $6100+COPY_PLANE-2(PC),A2
		SUBA.L	    A0,A2
		MOVE.W	    A2,(A0)
GERADE_2:	MOVE.W	    #$4E75,2(A0)

*---------------
				move.w		BILD_HOEHE(pc),d0
				move.w		d0,d1
				move.w		FONT_FLAG(PC),d7
				cmpi.w		#4,d7
				beq.s		.grosser_Font
				move.l		FONT_8,FONT				; Font
				move.w		#8,SCAN_LINES			; Scan_lines
				move.w		#$601E,PATCH_FONT
				move.w		#$603E,PATCH_FONT_I
				move.w		#$601E,PATCH_FONT_U
				move.w		#$1B42,PATCH_LINE
				bra.s		.cont
.grosser_Font:	move.l		FONT_16,FONT			; Font
				move.w		#16,SCAN_LINES			; Scan_lines
				move.w		#$1B5A,PATCH_FONT
				move.w		#$1B5A,PATCH_FONT_I
				move.w		#$1B5A,PATCH_FONT_U
				move.w		#$1B5A,PATCH_LINE
.cont:			lsr.w		d7,d0
				lsr.w		#3,d1
				move.w		d0,ZEILEN_SCREEN		; Zeilen_screen
				move.w		d1,ZEILEN_SCREEN_8_8	; Zeilenscreen_8_8
				mulu		ZEILEN_LAENGE(pc),d0
				mulu		ZEILEN_LAENGE(pc),d1
				move.w		d0,ZEICHEN_SCREEN		; Zeichen_screen
				move.w		d1,ZEICHEN_SCREEN_8_8	; Zeichen_screen_8_8

				move.w		SCREEN_BREITE(PC),d0
				lsl.w		d7,d0
				move.w		d0,BYTES_ZEILE			; Bytes_zeile

				lea			TC_table,a0				; TrueColor Tabelle berechnen
				moveq		#-1,d2
				move.w		#255,d0					; 256 ASCII-Zeichen...
.loop_0:		addq.b		#1,d2
				move.b		d2,d3
				moveq		#7,d1					; 8 Bits...
.loop_1:		add.b		d3,d3
				scs			(a0)+
				scs			(a0)+
				dbra		d1,.loop_1
				dbra		d0,.loop_0
				rts

*-------------------------------------------------------------------------------

PRINT_SCREEN:	movem.l		d0-a6,-(sp)
				bsr			PRINT_MENU
				move.w		ZEILEN_SCREEN,d0
				move.w		d0,d3
				sub.w		FIRST_LINE,d0
				subq.w		#1,d0
.loop:			subq.w		#1,d3
				bsr			PRINT_LINE
				dbra		d0,.loop
				movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

INVERS_ON:		st			INVERS
				rts
INVERS_OFF:		sf			INVERS
				rts
HELL_ON:		st			HELL
				rts
HELL_OFF:		sf			HELL
				rts
UNDERLINE_ON:	st			UNDERLINE
				rts
UNDERLINE_OFF:	sf			UNDERLINE
				rts

**********************	Eingaben, GerÑte-Treiber  ******************************

*-------------------------------------------------------------------------------
* RECEIVE_DATA: holt sich die Daten, prÅft auf Packete, setzt Key, Ascii_key und
*		die Kbshifttastenflags entsprechend
* ---> A0.l = Adresse des Hardwareregisters
* ---> A1.l = Pointer auf die IOREC Struktur
* ---> A6.l = Pointer auf die Key_ignore Struktur (5 Bytes lang)
* <--- D0.w = Scancode
* <--- D1.w = Scancode and $7F
* <--- D2.l = Flag
* KEY = 0 bei Umschalttasten sonst Scancode
* ASCII_KEY = 0 bei F-tasten, Steuertasten und Umschalttasten sonst Asciicode
*
* KBSHIFT_CODIEREN: wertet die Flags der Umschaltasten aus und erzeugt einen
*		    RÅckgabewert wie er auch von KBSHIFT zurÅckgegeben wird
* <--- D1.l = KBSHIFT
*
* UMSCHALT_TASTEN: setzt die Flags der Kbshifttasten
* ---> D0.w = Scancode
* ---> D1.w = Scancode and $7f
* <--- SHIFTRECHTS_FLAG, SHIFTLINKS_FLAG, CAPSLOCK_FLAG, CONTROL_FLAG und
*      ALTERNATE_FLAG
*
* SET_KEYIN: prÅft ob eine Tastenkombination zum Einspringen gedrÅckt wurde
* ---> D0.w = Scancode
* flag.mi = einspringen, flag.eq = nicht einspringen
*
* FLUSH_KEYS: KEY, LAST_KEY, ASCII_KEY lîschen
*-------------------------------------------------------------------------------

				XBRA		OLD_KEYBOARD
KEYBOARD:		tst.b		ACIA_STATUS_IKBD.w
				bpl.s		.dont_fetch
				tst.b		DEBUGGER_FLAG			; Debugger aktiv?
				bne.s		.fetch
				tst.b		KB_FLAG+1				; weder zeigen noch
				beq.s		.fetch					; korrigieren

.dont_fetch:	ErrorHandler	OLD_KEYBOARD,KB_MESSAGE,KB_FLAG

*---------------

.fetch:			movem.l		d0-a6,-(sp)
 				sf			CHANGE_SR

				jsr			CREATE_FRAME			; Call old routine first
				pea			.return(pc)
				move.w		sr,-(sp)

				move.l		OLD_KEYBOARD(pc),a0
				tst.b		DEBUGGER_FLAG			; nur innerhalb des Debuggers
				beq.s		.no_debugger			; anderen Peacebug suchen
.search: 		cmpi.l		#'XBRA',-12(a0)			; suche letztes Programm in
				bne.s		.no_debugger			; der XBRA-Liste oder PBUG
				cmpi.l		#KENNUNG,-8(a0)
				beq.s		.no_debugger
				movea.l		-4(a0),a0
				bra.s		.search
.no_debugger:	move.l		a0,-(sp)
				rts

*-------------------------------------------------------------------------------

.return:		lea			ACIA_STATUS_IKBD.w,a0	; IKBD Receive
				movea.l		IOREC_IKBD,a1
				lea			KEY_IGNORE_IKBD,a6
				bsr			RECEIVE_DATA

				bsr			TEST_BREAK				; nur innerhalb
				bsr			TEST_CHEATMODE			; nur innerhalb
				bsr			TEST_SLOWMOTION			; nur ausserhalb
				bsr			SET_KEYIN				; nur ausserhalb
				beq.s		.ende

				move.b		#$bf,ST_ISRB.w
				clr.b		KEY						; einspringen...
				movem.l		(sp)+,d0-a6
				bsr			GOTO_DEBUGGER
				move.l		SAVE_PC,FEHLER_ADRESSEN
				PrintError	.KEY_EINSPRUNG
				bra			EDITOR

*---------------

.ende:			tst.b		CHANGE_SR
				beq.s		.no_change
				andi.w		#$f0ff,60(sp)
				move.w		STATUS,d0
				or.w		d0,60(sp)
.no_change:		move.b		#$bf,ST_ISRB.w
				movem.l		(sp)+,d0-a6
				rte

				MessageC	.KEY_EINSPRUNG,'Called by keyboard at $'

*-------------------------------------------------------------------------------

RECEIVE_DATA:	moveq		#0,d0
				move.b		2(a0),d0

				tst.b		(a6)					; wird ein Paket gesendet?
				beq.s		.no_packet
				subq.b		#1,(a6)					; ein Zeichen weniger
				tst.b		1(a6)
				beq.s		.ignore					; kein interessantes Paket
				bmi.s		.maus

				moveq		#0,d1					; Uhrpaket
				move.b		(a6),d1
				subq.w		#2,d1
				bgt.s		.ignore					; Datum interessiert nicht
				neg.w		d1						; 0 -> 2, 1 -> 1, 2 -> 0
				lea			IKBD_ZEIT,a3
				move.b		d0,(a3,d1.w)
				rts

.maus:			move.b		d0,4(a6)				; Mauspaket
				tst.b		(a6)
				bne.s		.continue				; alles da?, dann neuzeichnen
				tst.b		DEBUGGER_FLAG
				bne			MAUS_ACCELERATE
				bsr			GET_MAUSKEY
.continue:		move.b		d0,3(a6)
.ignore:		rts

.no_packet:		cmp.w		#$f6,d0					; kein Paket unterwegs
				blo.s		.get_char
				sub.w		#$f6,d0
				move.b		.table(pc,d0.w),(a6)	; Anzahl Zeichen
				subq.w		#2,d0
				cmp.w		#3,d0
				sls			1(a6)					; Mauspaketflag
				cmp.w		#4,d0
				bne.s		.no_clock
				move.b		#1,1(a6)				; Uhrpaketflag
				rts
.no_clock:		move.b		d0,2(a6)				; Maustastenstatus
				rts

*---------------

.table:			dc.b		7,5,2,2,2,2,6,2,1,1

*---------------

.get_char:		move.b		d0,KEY					; und Key speichern
				clr.b		ASCII_KEY
				moveq		#%1111111,d1
				and.w		d0,d1
				movea.l		(a1),a2
				lea			KeyTable_1-1,a3
				move.b		(a3,d1.w),d2
				beq			UMSCHALTTASTEN			; Umschalttasten prÅfen
				cmpi.b		#-1,d2
				beq.s		CLEAR_INPUT
				adda.w		8(a1),a2
				moveq		#0,d2
				move.b		3(a2),ASCII_KEY
				bne.s		CLEAR_INPUT
				st			ASCII_KEY

*---------------

CLEAR_INPUT:	tst.b		DEBUGGER_FLAG
				beq.s		.dont_clear
				movea.l		$118.w,a0
.search:		cmpa.l		#KEYBOARD,a0
				beq.s		.clear_it
				cmpi.l		#'XBRA',-12(a0)
				bne.s		.clear_it
				cmpi.l		#KENNUNG,-8(a0)
				beq.s		.dont_clear
				movea.l		-4(a0),a0
				bra.s		.search
.clear_it:		clr.l		6(a1)
.dont_clear:	rts

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

CHEAT_KEYBOARD: movem.l		d0-a6,-(sp)
				lea			ACIA_STATUS_IKBD.w,a0
				movea.l		IOREC_IKBD,a1
				lea			KEY_IGNORE_IKBD,a6
				btst		#0,(a0)
				beq.s		_KEIN_IKBD
				bsr.s		_RECEIVE_DATA
_KEIN_IKBD:		bsr			TEST_BREAK
				bsr			TEST_CHEATMODE
				tst.b		CHANGE_SR
				beq.s		.no_change
				move.w		sr,d0
				andi.w		#$f0ff,d0
				or.w		STATUS,d0

				move.w		d0,sr
.no_change:		move.b		#$bf,ST_ISRB.w
				movem.l		(sp)+,d0-a6
				rts

*---------------

_RECEIVE_DATA:	moveq		#0,d0
				move.b		2(a0),d0

				tst.b		(a6)					; wird ein Paket gesendet?
				beq.s		.no_packet
				subq.b		#1,(a6)					; ein Zeichen weniger
				tst.b		1(a6)
				beq.s		.ignore					; kein interessantes Paket
				bmi.s		.maus

				moveq		#0,d1					; Uhrpaket
				move.b		(a6),d1
				subq.w		#2,d1
				bgt.s		.ignore					; Datum interessiert nicht
				neg.w		d1						; 0 -> 2, 1 -> 1, 2 -> 0
				lea			IKBD_ZEIT,a3
				move.b		d0,(a3,d1.w)
				rts

.maus:			move.b		d0,4(a6)				; Mauspaket
				tst.b		(a6)
				bne.s		.continue				; alles da?, dann neuzeichnen
				tst.b		DEBUGGER_FLAG
				bne			MAUS_ACCELERATE
				bsr			GET_MAUSKEY
.continue:		move.b		d0,3(a6)
.ignore:		rts

.no_packet:		cmp.w		#$f6,d0					; kein Paket unterwegs
				blo.s		.get_char
				sub.w		#$f6,d0
				move.b		.table(pc,d0.w),(a6)	; Anzahl Zeichen
				subq.w		#2,d0
				cmp.w		#3,d0
				sls			1(a6)					; Mauspaketflag
				cmp.w		#4,d0
				bne.s		.no_clock
				move.b		#1,1(a6)				; Uhrpaketflag
				rts
.no_clock:		move.b		d0,2(a6)				; Maustastenstatus
				rts

*---------------

.table:			dc.b		7,5,2,2,2,2,6,2,1,1

*---------------

.get_char:	MOVE.B	    D0,KEY		  ; und Key speichern
		CLR.B	    ASCII_KEY
		MOVEQ	    #%1111111,D1
		AND.W	    D0,D1
		MOVEA.L     (A1),A2
		LEA	    KeyTable_1-1,A3
		MOVE.B	    (A3,D1.w),D2
		BEQ	    UMSCHALTTASTEN	  ; Umschalttasten prÅfen
		CMP.B	    #-1,D2
		BEQ.S	    _ENDE_RECEIVE
		TST.B	    CONTROL_FLAG
		BEQ.S	    _NO_CONTROL
		SUB.B	    #96,D2
		BRA.S	    _NO_SHIFT
_NO_CONTROL:	MOVE.B	    SHIFTRECHTS_FLAG,D4
		ADD.B	    SHIFTLINKS_FLAG,D4
		ADD.B	    CAPSLOCK_FLAG,D4
		BEQ.S	    _NO_SHIFT

		LEA	    KeyTable_2-1,A3
		MOVE.B	    (A3,D1.w),D2
_NO_SHIFT:	MOVE.B	    D2,ASCII_KEY
_ENDE_RECEIVE:	RTS

*-------------------------------------------------------------------------------

KBSHIFT_CODIEREN:MOVEQ	    #0,D1
		TST.B	    MAUS_LEFT
		SNE	    D2
		ADD.B	    D2,D2
		ADDX.b	    D1,D1
		TST.B	    MAUS_RIGHT
		SNE	    D2
		ADD.B	    D2,D2
		ADDX.b	    D1,D1
		MOVE.B	    CAPSLOCK_FLAG,D2
		ADD.B	    D2,D2
		ADDX.b	    D1,D1
		MOVE.B	    ALTERNATE_FLAG,D2
		ADD.B	    D2,D2
		ADDX.b	    D1,D1
		MOVE.B	    CONTROL_FLAG,D2
		ADD.B	    D2,D2
		ADDX.b	    D1,D1
		MOVE.B	    SHIFTLINKS_FLAG,D2
		ADD.B	    D2,D2
		ADDX.b	    D1,D1
		MOVE.B	    SHIFTRECHTS_FLAG,D2
		ADD.B	    D2,D2
		ADDX.b	    D1,D1
		RTS

*-------------------------------------------------------------------------------

* ---> D0.w = Scancode
* ---> D1.w = Scancode && $7F

UMSCHALTTASTEN: CLR.B	    KEY
		CMP.W	    #54,D1
		BNE.S	    NOSHIFTRECHTS
		CMP.W	    D1,D0
		SEQ	    SHIFTRECHTS_FLAG
NOSHIFTRECHTS:	CMP.W	    #42,D1
		BNE.S	    NOSHIFTLINKS
		CMP.W	    D1,D0
		SEQ	    SHIFTLINKS_FLAG
NOSHIFTLINKS:	CMP.W	    #58,D1
		BNE.S	    NOCAPSLOCK
		CMP.W	    D1,D0
		BEQ.S	    NOCAPSLOCK
		NOT.B	    CAPSLOCK_FLAG
NOCAPSLOCK:	CMP.W	    #29,D1
		BNE.S	    NOCONTROL
		CMP.W	    D1,D0
		SEQ	    CONTROL_FLAG
NOCONTROL:	CMP.W	    #56,D1
		BNE.S	    NOALTERNATE
		CMP.W	    D1,D0
		SEQ	    ALTERNATE_FLAG
NOALTERNATE:	RTS

*-------------------------------------------------------------------------------

* ---> D0.w = Scancode
SET_KEYIN:	TST.B	    DEBUGGER_FLAG
		BNE.S	    ENDE_SETIN

		TST.B	    KEY_CODE_1
		SEQ	    KEY_1
		BEQ.S	    KEY_1_SET
		CMP.B	    KEY_CODE_1,D0
		SEQ	    KEY_1
KEY_1_SET:	TST.B	    KEY_CODE_2
		SEQ	    KEY_2
		BEQ.S	    KEY_2_SET
		CMP.B	    KEY_CODE_2,D0
		SEQ	    KEY_2

KEY_2_SET:	BSR	    KBSHIFT_CODIEREN
		BCLR	    #4,D1
		CMP.B	    SWITCH_CODE_1,D1  ; jetzt testen
		BNE.S	    NOT_FIRST_KEY
		TST.B	    KEY_1
		BEQ.S	    NOT_FIRST_KEY
		TST.W	    FLOCK.w
		BNE.S	    ENDE_SETIN
		BRA.S	    JUMP_IN
NOT_FIRST_KEY:	CMP.B	    SWITCH_CODE_2,D1
		BNE.S	    ENDE_SETIN
		TST.B	    KEY_2
		BEQ.S	    ENDE_SETIN
JUMP_IN:	MOVEQ	    #-1,D0
		RTS
ENDE_SETIN:	MOVEQ	    #0,D0
		RTS

*-------------------------------------------------------------------------------

* ---> D0.w = Scancode
TEST_SLOWMOTION:TST.B	    DEBUGGER_FLAG
		BNE.S	    NO_SLOW_KEY
		TST.B	    SLOW_MODE
		BEQ.S	    NO_SLOW_KEY

		CMP.B	    #202,D0		  ; Minus losgelassen?
		BEQ.S	    ADD_OFF
		CMP.B	    #206,D0		  ; Plus losgelassen?
		BEQ.S	    ADD_OFF
		CMPI.B	    #102,D0		  ; Mal gedrÅckt?
		BEQ.S	    SLOW_OFF
		CMPI.B	    #74,D0		  ; Minus gedrÅckt?
		BNE.S	    NO_MINUS
		MOVEQ	    #-1,D7
		BRA.S	    ENDE_TEST
NO_MINUS:	CMPI.B	    #78,D0		  ; Plus gedrÅckt?
		BNE.S	    NO_SLOW_KEY
		MOVEQ	    #1,D7
		BRA.S	    ENDE_TEST
SLOW_OFF:	CLR.L	    SLOW_COUNTER
ADD_OFF:	MOVEQ	    #0,D7
ENDE_TEST:	MOVEQ	    #0,D6
		MOVE.B	    CPU,D6
		ADDQ.B	    #1,D6
		MULS	    D6,D7
		TST.W	    UMSCHALT_TASTEN
		BNE.S	    ITS_SLOW
		ASL.L	    #3,D7
ITS_SLOW:	MOVE.L	    D7,SLOW_ADD
		BSR	    CLEAR_KEYBOARD
NO_SLOW_KEY:	RTS

*-------------------------------------------------------------------------------

* ---> D0.w = Scancode
TEST_BREAK:		tst.b		DEBUGGER_FLAG
				beq.s		.no_break
				tst.b		BreakFlag
				beq.s		.no_break
				cmpi.b		#%1,KEY				; Escape gedrÅckt?
				bne.s		.no_break
				bsr			CLEAN_UP
				jsr			CREATE_FRAME
				move.l		SAVE_PC,-(sp)
				move.w		SAVE_STATUS,-(sp)
				bsr			GOTO_DEBUGGER_2
				bsr			PRINT_SCREEN
				pea			.return(pc)
				move.l		BreakRoutine,-(sp)	; normalerweise rts
				rts
.return:		bsr			PARSER_RETURN
				pea			EDITOR(pc)
.no_break:		rts

BreakRoutine:									; Diese Routine wird nach einem
				ds.l		1					; Break angesprungen

*-------------------------------------------------------------------------------

* ---> D0.w = Scancode
TEST_CHEATMODE: TST.B	    DEBUGGER_FLAG
		BEQ	    NO_CHEAT_1

		TST.B	    TOGGLE_CHEAT
		BEQ.S	    CONT_PEACE
		CMP.B	    #%10000001,D0
		BNE	    NO_CHEAT_1
		sf	    TOGGLE_CHEAT

CONT_PEACE:	MOVE.B	    D0,D7
		AND.B	    SHIFTRECHTS_FLAG,D7
		AND.B	    SHIFTLINKS_FLAG,D7
		AND.B	    CONTROL_FLAG,D7
		AND.B	    ALTERNATE_FLAG,D7
		SUBQ.B	    #1,D7
		BNE.S	    NO_CHEAT_1
		st	    CHANGE_SR
		st	    TOGGLE_CHEAT
		CLR.B	    KEY
		CLR.B	    ASCII_KEY

				bsr			CLEAR_KEYBOARD
				tst.b		CHEAT_MODE
				beq.s		.cheat_on

				bsr			CHEAT_OFF
				lea			CHEAT_OFF_MESSAGE,a3
				bsr			MessageRawDown_C
				subq.w		#1,Y_POSITION
				bra			POSITIONIEREN

.cheat_on:		bsr			CHEAT_ON
				lea			CHEAT_ON_MESSAGE,a3
				bsr			MessageRawDown_C
				subq.w		#1,Y_POSITION
				bsr			POSITIONIEREN
NO_CHEAT_1:		rts

*-------------------------------------------------------------------------------

FLUSH_KEY:	CLR.B	    ASCII_KEY
		CLR.B	    KEY
		CLR.B	    LAST_KEY
		RTS

*-------------------------------------------------------------------------------
* SET_MOUSE: Setzt die Maus auf eine absolute Position. Sie wird neu gezeichnet.
* ---> d2.w = X-Position             ^^^^^^^^
* ---> d3.w = Y-Position
* GET_MAUSKEY: Maustastenhandling, wird vom Tastaturtreiber aufgerufen.
* MAUS_ACCELERATE: Mausbeschleuniger, Ñndert die Werte des Mauspaketes, ruft
*				   MAUS_POSITION auf.
* MAUS_POSITION: Mauspaket ausgewerten, Maus_x und Maus_y werden gesetzt. ruft
*				 HIDE_MOUSE + SHOW_MOUSE auf.
* SHOW_MOUSE: Darf nur vom Maustreiber benutzt werden!
* SHOWM: Schaltet die Maus an, wenn Zaehler=1.
* -----
* HIDE_MOUSE: Darf nur vom Maustreiber benutzt werden!
* HIDEM: Schaltet die Maus ab, wenn Zaehler=0.
* -----
* KILL_MOUSE: Schaltet die Maus in jedem Fall ab, Zaehler bleibt.
* ----------
*-------------------------------------------------------------------------------

SET_MOUSE:		movem.l		d0-a6,-(sp)
				lea			KEY_IGNORE_IKBD,a6
				clr.b		3(a6)
				clr.b		4(a6)
				move.w		d2,MAUS_X
				move.w		d3,MAUS_Y
				bsr			MAUS_POSITION
				movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

GET_MAUSKEY:	movem.l		d0/a0,-(sp)
				moveq		#1,d0
				and.b		2(a6),d0
				lea			MAUS_RIGHT,a0
				bsr.s		.HANDLE_KEY
				moveq		#2,d0
				and.b		2(a6),d0
				lea			MAUS_LEFT,a0
				bsr.s		.HANDLE_KEY
				movem.l		(sp)+,d0/a0
				rts

*---------------

.HANDLE_KEY:	tst.b		d0
				beq.s		.off
				move.l		ZAEHLER_7,d0
				sub.l		HZ200_ZAEHLER,d0
				blt.s		.on
				move.b		#1,(a0)
				move.l		HZ200_ZAEHLER,d0		; Timer neu starten
				sub.l		DOPPEL_KLICK,d0
				move.l		d0,ZAEHLER_7
				rts
.on:			move.b		1(a0),(a0)
				addq.b		#1,(a0)
				rts
.off:			move.b		(a0),1(a0)
				clr.b		(a0)
				rts

*-------------------------------------------------------------------------------

MAUS_ACCELERATE:MOVEM.L     D0-D3/A0-A1,-(SP)
		BSR.S	    GET_MAUSKEY
		MOVE.B	    3(A6),D2
		EXT.W	    D2
		SLT	    D3
		BPL.S	    X_POSITIV_1
		NEG.W	    D2
X_POSITIV_1:	LEA	    MAUS_PARAMETER(PC),A1
		MOVEQ	    #0,D1
		MOVEQ	    #5,D0
SCHLEIFE_X:	ADD.W	    (A1)+,D1
		MULS	    D2,D1
		DBRA	    D0,SCHLEIFE_X
		TST.B	    D3
		BEQ.S	    X_POSITIV_2
		NEG.W	    D1
X_POSITIV_2:	ADD.W	    UEBERTRAG_X,D1
		MOVE.W	    D1,D2
		AND.W	    #%111111,D2
		ASR.W	    #7,D1
		MOVE.W	    D2,UEBERTRAG_X
		MOVE.B	    D1,D2
		EXT.W	    D2
		CMP.W	    D1,D2
		BEQ.S	    MAUS_X_OK
		TST.W	    D1
		BGT.S	    X_POSITIV_3
		MOVE.B	    #-128,D1
		BRA.S	    MAUS_X_OK
X_POSITIV_3:	MOVE.B	    #127,D1
MAUS_X_OK:	MOVE.B	    D1,3(A6)
		MOVE.B	    4(A6),D2
		EXT.W	    D2
		SLT	    D3
		BPL.S	    Y_POSITIV_1
		NEG.W	    D2
Y_POSITIV_1:	LEA	    MAUS_PARAMETER(PC),A1
		MOVEQ	    #0,D1
		MOVEQ	    #5,D0
SCHLEIFE_Y:	ADD.W	    (A1)+,D1
		MULS	    D2,D1
		DBRA	    D0,SCHLEIFE_Y
		TST.B	    D3
		BEQ.S	    Y_POSITIV_2
		NEG.W	    D1
Y_POSITIV_2:	ADD.W	    UEBERTRAG_Y,D1
		MOVE.W	    D1,D2
		AND.W	    #%111111,D2
		ASR.W	    #7,D1
		MOVE.W	    D2,UEBERTRAG_Y
		MOVE.B	    D1,D2
		EXT.W	    D2
		CMP.W	    D1,D2
		BEQ.S	    MAUS_Y_OK
		TST.W	    D1
		BGT.S	    Y_POSITIV_3
		MOVE.B	    #-128,D1
		BRA.S	    MAUS_Y_OK
Y_POSITIV_3:	MOVE.B	    #127,D1
MAUS_Y_OK:	MOVE.B	    D1,4(A6)
		MOVEM.L     (SP)+,D0-D3/A0-A1

*-------------------------------------------------------------------------------

MAUS_POSITION:	MOVEM.L     D0-D2/A0,-(SP)
		MOVE.B	    3(A6),D0
		EXT.W	    D0
		MOVE.W	    MAUS_X,D1
		ADD.W	    D0,D1
		MOVE.W	    OFFSET_X(PC),D2
		LSL.W	    #3,D2
		CMP.W	    D2,D1
		BGE.S	    X_IS_OK_1
		MOVE.W	    D2,D1
X_IS_OK_1:
		MOVE.W	    BILD_BREITE(PC),D0
		LSL.W	    #3,D0
		ADD.W	    D2,D0
		SUB.W	    #11,D0
		CMP.W	    D0,D1
		BLE.S	    X_IS_OK_2
		MOVE.W	    D0,D1
X_IS_OK_2:	MOVE.W	    D1,MAUS_X
		MOVE.B	    4(A6),D0
		EXT.W	    D0
		MOVE.W	    MAUS_Y,D1
		ADD.W	    D0,D1
		MOVE.W	    OFFSET_Y(PC),D2
		CMP.W	    D2,D1
		BGE.S	    Y_IS_OK_1
		MOVE.W	    D2,D1
Y_IS_OK_1:	MOVE.W	    BILD_HOEHE(PC),D0
		ADD.W	    D2,D0
		CMP.W	    D0,D1
		BLT.S	    Y_IS_OK_2
		MOVE.W	    D0,D1
		SUBQ.W	    #1,D1
Y_IS_OK_2:	MOVE.W	    D1,MAUS_Y
		MOVEM.L     (SP)+,D0-D2/A0
		BSR	    HIDE_MOUSE
*		 BSR	     SHOW_MOUSE

*-------------------------------------------------------------------------------

SHOW_MOUSE:		tst.b		MAUS_ZAEHLER
				bgt.s		DANN_MAL_AN
				rts
SHOWM:			addq.b		#1,MAUS_ZAEHLER
				cmpi.b		#1,MAUS_ZAEHLER
				bne.s		MOUSE_ON
				tst.b		KILLED_MOUSE
				bne.s		MOUSE_ON
DANN_MAL_AN:	tst.b		MAUS_GESPERRT
				bne.s		MOUSE_ON
				st			MAUS_GESPERRT
				tst.b		MAUS_ON
				seq			MAUS_GESPERRT
				bne.s		MOUSE_ON

				movem.l		d0-a6,-(sp)			; Planeorientiert
				tst.b		TRUECOLOR
				bne.s		.TC
				bsr.s		ZEICHNEN
				bra.s		.cont
.TC:			bsr			ZEICHNEN_TC
.cont:			st			MAUS_ON
				sf			MAUS_GESPERRT
				movem.l		(sp)+,d0-a6

MOUSE_ON:		rts

*-------------- zeichnet die Maus, Plane Oriented
ZEICHNEN:		move.w		MAUS_X,d0
				move.w		d0,d1
				andi.w		#$fff0,d1			; abrunden auf 16
				sub.w		d1,d0				; Anzahl Shifts nach rechts
				moveq		#16,d6
				sub.w		d0,d6				; Anzahl Shifts nach rechts
				lsr.w		#3,d1				; auf Zeichen abrunden
				mulu		PLANES(pc),d1
				move.w		MAUS_Y,d3
				move.w		d3,d5
				sub.w		BILD_HOEHE(pc),d5
				sub.w		OFFSET_Y(pc),d5
				neg.w		d5
				subq.w		#1,d5
				mulu		SCREEN_BREITE(pc),d3
				add.l		d1,d3
				movea.l		BILDSCHIRM_ADRESSE(pc),a0
				lea			(a0,d3.l),a0
				move.w		PLANES(pc),d1
				add.w		d1,d1
				lea			(a0,d1.w),a2
				lea			MouseData,a1
				lea			MouseMask,a3
				movea.l		MAUS_PUFFER(pc),a5
				moveq		#15,d3				; LoopzÑhler, Anzahl Scanlines
				cmp.w		d3,d5
				bhi.s		.y_io
				move.w		d5,d3
.y_io:			movem.l		d3/a0/a2,SAVE_MAUSPOS
				move.w		PLANES(pc),d4
				add.w		d4,d4
				sub.w		SCREEN_BREITE(pc),d4
				move.w		d4,-(sp)
.loop_0:		move.w		(a1)+,d4
				move.w		d4,d5
				lsr.w		d0,d4
				lsl.w		d6,d5
				move.w		(a3)+,d1
				move.w		d1,d2
				lsr.w		d0,d1
				lsl.w		d6,d2
				not.w		d1
				not.w		d2
				move.w		PLANES(pc),d7
				subq.w		#1,d7
.loop_1:		move.w		(a0),(a5)+
				move.w		(a2),(a5)+
				and.w		d1,(a0)			; This is the mask
				and.w		d2,(a2)
				or.w		d4,(a0)+		; Now the actual mouse
				or.w		d5,(a2)+
				dbra		d7,.loop_1		; Anzahl Planes
				suba.w		(sp),a0
				suba.w		(sp),a2
				dbra		d3,.loop_0		; Anzahl Scanlines
				addq.w		#2,sp
				rts

*-------------- zeichnet die Maus, TRUE COLOR
ZEICHNEN_TC:	move.w		MAUS_X,d0
				add.w		d0,d0
				move.w		MAUS_Y,d1
				mulu		SCREEN_BREITE(pc),d1
				movea.l		BILDSCHIRM_ADRESSE(pc),a0
				adda.w		d0,a0
				adda.l		d1,a0				; a0 = Bildschirmadresse
				lea			MouseMask2,a1		; a1 = Mausmaske
				lea			MouseData2,a2		; a2 = Mausdaten
				movea.l		MAUS_PUFFER(pc),a3	; a3 = Hintergrundspuffer

				move.w		MAUS_Y,d0
				sub.w		BILD_HOEHE(pc),d0
				sub.w		OFFSET_Y(pc),d0
				neg.w		d0
				subq.w		#1,d0
				moveq		#15,d7				; LoopzÑhler, Anzahl Scanlines
				cmp.w		d7,d0
				bhi.s		.y_io
				move.w		d0,d7
.y_io:			movem.l		d7/a0/a3,SAVE_MAUSPOS

				move.w		d7,-(sp)
.loop:			movem.l		(a0),d0-d7			; Hintergrund retten
				movem.l		d0-d7,(a3)
				lea			32(a3),a3
				movem.l		(a1)+,d0-d7			; Maske
				or.l		d0,(a0)+
				or.l		d1,(a0)+
				or.l		d2,(a0)+
				or.l		d3,(a0)+
				or.l		d4,(a0)+
				or.l		d5,(a0)+
				or.l		d6,(a0)+
				or.l		d7,(a0)+
				movem.l		(a2)+,d0-d7			; Maus
				and.l		d7,-(a0)
				and.l		d6,-(a0)
				and.l		d5,-(a0)
				and.l		d4,-(a0)
				and.l		d3,-(a0)
				and.l		d2,-(a0)
				and.l		d1,-(a0)
				and.l		d0,-(a0)
				adda.w		SCREEN_BREITE(pc),a0
				subq.w		#1,(sp)
				bpl.s		.loop
				addq.w		#2,sp
				rts

*-------------------------------------------------------------------------------

KILL_MOUSE:		st			KILLED_MOUSE
				bra.s		DANN_MAL_AB
HIDEM:			subq.b		#1,MAUS_ZAEHLER
				bne			MOUSE_OFF
				tst.b		KILLED_MOUSE
				beq.s		DANN_MAL_AB
				rts
HIDE_MOUSE:		sf			KILLED_MOUSE
				tst.b		MAUS_ZAEHLER
				ble			MOUSE_OFF
DANN_MAL_AB:	tst.b		MAUS_GESPERRT
				bne.s		MOUSE_OFF
				st			MAUS_GESPERRT
				tst.b		MAUS_ON
				sne			MAUS_GESPERRT
				beq.s		MOUSE_OFF

				movem.l		d0-a6,-(sp)				; Maushintergrund restaurieren
				tst.b		TRUECOLOR
				bne.s		.TC

				movem.l		SAVE_MAUSPOS,d3/a0/a2	; Planeorientiert
				move.w		PLANES(pc),d0
				move.w		d0,d7
				subq.w		#1,d7
				add.w		d0,d0
				sub.w		SCREEN_BREITE(pc),d0
				movea.l		MAUS_PUFFER(pc),a5
.next_line:		move.w		d7,d6
.loop:			move.w		(a5)+,(a0)+
				move.w		(a5)+,(a2)+
				dbra		d6,.loop				; Anzahl Planes
				suba.w		d0,a0
				suba.w		d0,a2
				dbra		d3,.next_line			; Anzahl Scanlines
				bra.s		.cont

.TC:			movem.l		SAVE_MAUSPOS,d7/a0/a3	; True Color
				move.w		SCREEN_BREITE(pc),d6
.restore:		movem.l		(a3)+,d0-d5/a1/a5
				movem.l		d0-d5/a1/a5,(a0)
				adda.w		d6,a0
				dbra		d7,.restore

.cont:			sf			MAUS_ON
				sf			MAUS_GESPERRT
				movem.l		(sp)+,d0-a6

MOUSE_OFF:		rts

**********************	Lowlevelroutinen  **************************************

*-------------------------------------------------------------------------------
* GOTO_DEBUGGER:   USER_ENTER Routine
*				   Register, SR, PC, Stackframe, SFC, DFC, VBR, CACR, CAAR, USP,
*				   ISP, MSP, Switch Screen, Get Hardware, Vektor, SR setzen
*				   Breakpoints entfernen, Cacheeintrag erzeugen
* GOTO_DEBUGGER_2: wie GOTO_DEBUGGER, es wird allerdings NICHTS! gerettet
* GOTO_PROGRAM:    Keyboardpuffer leeren, BPT setzen, Switch, Set Register
*				   Frame erzeugen, USER_QUIT Routine, TRACE Routine
*-------------------------------------------------------------------------------

GOTO_DEBUGGER:	st			STOP_TRACE
				sf			STOP_TRACE
				pea			USER_1(pc)
				move.l		USERENTER(pc),-(sp)
				rts

USER_1: 		ori.w		#$700,sr
				st			DEBUGGER_FLAG
		MOVEM.L     d0-a6,SAVE_REGISTER ; Save Register

		sf	    TRACE_MODUS_1
		sf	    TRACE_MODUS_2
		sf	    TRACE_MODUS_3
		sf	    TRACE_MODUS_4
		sf	    TRACE_MODUS_5
		CLR.W	    CACHE_ZAEHLER_1
		CLR.W	    CACHE_ZAEHLER_2

		LEA	    SAVE_REGISTER,A0
		MOVEA.L     (SP)+,A1		  ; RÅcksprungadresse
		MOVE.W	    (SP)+,-(A0) 	  ; Save Status
		MOVE.L	    (SP)+,-(A0) 	  ; Save PC

		MOVEQ	    #0,D0
		MOVE.B	    (SP),D0		  ; Stackframe entfernen
		LSR.W	    #4,D0
		JSR	    FRAME_LENGTH
		ADD.W	    D0,D0
		LEA	    -6(SP,D0.w),SP	  ; SP-6(pc&sr)+framelength*2

		MOVE	    #$2700,SR
		MOVE.L	    SP,-(A0)		  ; ISP
		MOVE	    USP,A2
		MOVE.L	    A2,-(A0)		  ; USP

		BSR	    FETCH_REGISTER
		BSR	    GET_SP

		LEA	    _STACK_ISP,SP	  ; Interruptstackpointer setzen
		MOVE	    #$3700,SR		  ; auf Masterstack wechseln
		LEA	    _STACK_MSP,SP	  ; Masterstackpointer setzen
		LEA	    _STACK_USP,A0
		MOVE	    A0,USP		  ; Userstackpointer setzen

		MOVE.L	    A1,-(SP)		  ; RÅcksprungadresse auf Stack

		MOVE.L	    #2,TRACE_ZAEHLER
		TST.B	    KEEP_SCREEN
		BNE.S	    NO_CHANGE_1
		JSR	    SHOW_DEBUGGER

NO_CHANGE_1:	BSR	    GET_HARDWARE
				jsr			TrapVektor			; Routine Vektor...

		LEA	    ACIA_STATUS_IKBD.w,A0
		MOVE.B	    #3,(A0)		  ; KBD-Acia Reset
		MOVE.B	    #$96,(A0)
		MOVE.B	    #$80,2(A0)
		MOVE.B	    #1,2(A0)		  ; IKBD reseten
		MOVE.B	    #8,2(A0)		  ; relativer Mousemode

		MOVE.W	    STATUS,D0
		AND.W	    #$7FF,D0
		ORI.W	    #$3000,D0
		MOVE	    D0,SR

		BSR	    BPT_LOESCHEN
		jsr		TestSYMB
		move.l	d0,RES_SYMDRIVER
		jsr			CACHE_PUT

				bsr			Calc_FIRST_LINE
				bra			SET_PC

*-------------------------------------------------------------------------------

GOTO_DEBUGGER_2:	st	    STOP_TRACE
		sf	    STOP_TRACE
		PEA	    USER_2(PC)
		MOVE.L	    USERENTER(PC),-(SP)
		RTS

USER_2: 	ORI	    #$700,SR
		st	    DEBUGGER_FLAG

		sf	    TRACE_MODUS_1
		sf	    TRACE_MODUS_2
		sf	    TRACE_MODUS_3
		sf	    TRACE_MODUS_4
		sf	    TRACE_MODUS_5
		CLR.W	    CACHE_ZAEHLER_1
		CLR.W	    CACHE_ZAEHLER_2

		MOVEA.L     (SP),A1		  ; RÅcksprungadresse

		LEA	    _STACK_ISP,SP	  ; Interruptstackpointer setzen
		MOVE	    #$3700,SR		  ; auf Masterstack wechseln
		LEA	    _STACK_MSP,SP	  ; Masterstackpointer setzen
		LEA	    _STACK_USP,A0
		MOVE	    A0,USP		  ; Userstackpointer setzen

		MOVE.L	    A1,-(SP)		  ; RÅcksprungadresse auf Stack

		MOVE.L	    #2,TRACE_ZAEHLER
		TST.B	    KEEP_SCREEN
		BNE.S	    NO_CHANGE_2
		JSR	    SHOW_DEBUGGER

NO_CHANGE_2:	jsr			TrapVektor			; Routine Vektor...

		LEA	    ACIA_STATUS_IKBD.w,A0
		MOVE.B	    #3,(A0)		  ; KBD-Acia Reset
		MOVE.B	    #$96,(A0)
		MOVE.B	    #$80,2(A0)
		MOVE.B	    #1,2(A0)		  ; IKBD reseten
		MOVE.B	    #8,2(A0)		  ; relativer Mousemode

		MOVE.W	    STATUS,D0
		AND.W	    #$7FF,D0
		ORI.W	    #$3000,D0
		MOVE	    D0,SR

		BSR	    BPT_LOESCHEN
		jsr	    TestSYMB
		move.l	d0,RES_SYMDRIVER

				bsr			Calc_FIRST_LINE
				bra			SET_PC

*-------------------------------------------------------------------------------

GOTO_PROGRAM:	MOVE	    #$2700,SR

		BSR	    CLEAR_KEYBOARD
		TST.B	    CHEAT_MODE
		BNE.S	    ITS_CHEAT_7
		BSR	    KBSHIFT_CODIEREN
		MOVEA.L     KBSHIFT,A0
		AND.B	    #%11111,D1
		MOVE.B	    D1,(A0)

ITS_CHEAT_7:	BSR	    BPT_SETZEN
		sf	    KILLED_MOUSE
		MOVE.B	    #1,MAUS_ZAEHLER
		BSR	    HIDEM
		JSR	    SHOW_PROGRAMM

		LEA	    SAVE_PC,A0
		MOVEA.L     -(A0),SP		  ; ISP
		MOVEA.L     -(A0),A1		  ; USP
		MOVE	    A1,USP
		BSR	    SET_REGISTER

		JSR	    CREATE_FRAME
		MOVE.L	    SAVE_PC,-(SP)
		MOVE.W	    SAVE_STATUS,-(SP)
		sf	    DEBUGGER_FLAG
		MOVEM.L     SAVE_REGISTER,D0-A6 ; Restore Register
		PEA	    TRACE(PC)
		MOVE.L	    USERQUIT(PC),-(SP)
		RTS

*-------------------------------------------------------------------------------

				XBRA		.no_label
USER_QUIT:		rts

				XBRA		.no_label
USER_ENTER:		rts

				XBRA		.no_label
USER_SWITCH_1:	rts

				XBRA		.no_label
USER_SWITCH_2:	rts

				XBRA		.no_label
USER_RESET:		rts

*-------------------------------------------------------------------------------

* Supervisormodus muss aktiv sein!
* benutzt werden die Register D0 und A0
FETCH_REGISTER: TST.B	    CPU
		BEQ	    GETFPU

			dc.w $4E7A,$00		  ; MOVEC SFC,D0
		MOVE.L	    D0,-(A0)
			dc.w $4E7A,$01		  ; MOVEC DFC,D0
		MOVE.L	    D0,-(A0)
			dc.w $4E7A,$0801	  ; MOVEC VBR,D0
		MOVE.L	    D0,-(A0)

		CMPI.B	    #1,CPU
		BLS	    GETFPU

		SUBQ.W	    #4,A0
		CMPI.B	    #4,CPU
		BEQ.S	    NO_CAAR
			dc.w $4E7A,$0802	  ; MOVEC CAAR,D0
		MOVE.L	    D0,(A0)

NO_CAAR:		dc.w $4E7A,$02		  ; MOVEC CACR,D0
		MOVE.L	    D0,-(A0)
			dc.w $4E7A,$0803	  ; MOVEC MSP,D0
		MOVE.L	    D0,-(A0)

		CMPI.B	    #2,CPU
		BLS.S	    GETFPU

		CMPI.B	    #3,CPU
		BEQ.S	    M68030

			dc.w $4E7A,$0807	  ; MOVEC SRP,D0
		MOVE.L	    D0,-(A0)
		SUBQ.W	    #4,A0
			dc.w $4E7A,$0805	  ; MOVEC MMUSR,D0
		MOVE.W	    D0,-(A0)
		LEA	    -20(A0),A0
			dc.w $4E7A,$04		  ; MOVEC ITT0,D0
		MOVE.L	    D0,-(A0)
			dc.w $4E7A,$05		  ; MOVEC ITT1,D0
		MOVE.L	    D0,-(A0)
			dc.w $4E7A,$06		  ; MOVEC DTT0,D0
		MOVE.L	    D0,-(A0)
			dc.w $4E7A,$07		  ; MOVEC DTT1,D0
		MOVE.L	    D0,-(A0)
			dc.w $4E7A,$0806	  ; MOVEC URP,D0
		MOVE.L	    D0,-(A0)
			dc.w $4E7A,$03		  ; MOVEC TC,D0
		MOVE.W	    D0,-(A0)
		BRA.S	    GETFPU

*---------------

M68030: 	SUBQ.W	    #8,A0
			dc.w $F010,$4A00	  ; PMOVE SRP,(A0)
		SUBQ.W	    #2,A0
			dc.w $F010,$6200	  ; PMOVE MMUSR,(A0)
		SUBQ.W	    #8,A0
			dc.w $F010,$4E00	  ; PMOVE CRP,(A0)
		SUBQ.W	    #4,A0
			dc.w $F010,$0A00	  ; PMOVE TT0,(A0)
		SUBQ.W	    #4,A0
			dc.w $F010,$0E00	  ; PMOVE TT1,(A0)
		SUBQ.W	    #4,A0
			dc.w $F010,$4200	  ; PMOVE TC,(A0)

*---------------

GETFPU: 		tst.b		FPU
				beq.s		.no_FPU
				lea			SAVE_FPU,a0
				fmove.l		fpcr,-(a0)
				fmove.l		fpiar,-(a0)
				fmove.l		fpsr,-(a0)
				fmovem.x	fp0-fp7,-(a0)
.no_FPU:		rts

*-------------------------------------------------------------------------------

* Supervisormodus muss aktiv sein!
* benutzt werden die Register D0 und A0
SET_REGISTER:
		ORI	    #$0700,SR
		TST.B	    CPU
		BEQ	    PUTFPU

		MOVE.L	    -(A0),D0
			dc.w $4E7B,$00		  ; MOVEC D0,SFC
		MOVE.L	    -(A0),D0
			dc.w $4E7B,$01		  ; MOVEC D0,DFC
		MOVE.L	    -(A0),D0
			dc.w $4E7B,$0801	  ; MOVEC D0,VBR

		CMPI.B	    #1,CPU
		BLS	    PUTFPU

		SUBQ.W	    #4,A0
		CMPI.B	    #4,CPU
		BEQ.S	    NO_CAAR_2
		MOVE.L	    (A0),D0
			dc.w $4E7B,$0802	  ; MOVEC D0,CAAR

NO_CAAR_2:	MOVE.L	    -(A0),D0
			dc.w $4E7B,$02		  ; MOVEC D0,CACR
		MOVE.L	    -(A0),D0
			dc.w $4E7B,$0803	  ; MOVEC D0,MSP

		CMPI.B	    #2,CPU
		BLS	    PUTFPU

		MOVE.L	    $E0.w,-(SP)
		MOVE.L	    #PMMU_EXCEPTION,$E0.w

		CMPI.B	    #3,CPU
		BEQ.S	    M68030_2

*---------------

		MOVEQ	    #0,D0
			dc.w $4E7B,$03		  ; MOVEC D0,TC
			dc.w $F518		  ; PFLUSHA
		MOVE.L	    -(A0),D0
			dc.w $4E7B,$0807	  ; MOVEC D0,SRP
		SUBQ.W	    #4,A0
		MOVE.W	    -(A0),D0
			dc.w $4E7B,$0805	  ; MOVEC D0,MMUSR
		LEA	    -20(A0),A0
		MOVE.L	    -(A0),D0
			dc.w $4E7B,$04		  ; MOVEC D0,ITT0
		MOVE.L	    -(A0),D0
			dc.w $4E7B,$05		  ; MOVEC D0,ITT1
		MOVE.L	    -(A0),D0
			dc.w $4E7B,$06		  ; MOVEC D0,DTT0
		MOVE.L	    -(A0),D0
			dc.w $4E7B,$07		  ; MOVEC D0,DTT1
		MOVE.L	    -(A0),D0
			dc.w $4E7B,$0806	  ; MOVEC D0,URP
		MOVE.W	    -(A0),D0
			dc.w $4E7B,$03		  ; MOVEC D0,TC
		MOVE.L	    (SP)+,$E0.w
		BRA.S	    PUTFPU

*---------------

M68030_2:
			dc.w $F000,$2400		; PFLUSHA
		SUBQ.W	    #8,A0
			dc.w $F010,$4900		; PMOVEFD (A0),SRP
		SUBQ.W	    #2,A0
			dc.w $F010,$6000		; PMOVE (A0),MMUSR
		SUBQ.W	    #8,A0
			dc.w $F010,$4D00		; PMOVEFD (A0),CRP
		SUBQ.W	    #4,A0
			dc.w $F010,$0800		; PMOVE (A0),TT0
		SUBQ.W	    #4,A0
			dc.w $F010,$0C00		; PMOVE (A0),TT1
		SUBQ.W	    #4,A0
			dc.w $F010,$4000		; PMOVE (A0),TC
		MOVE.L	    (SP)+,$E0.w

*---------------

PUTFPU: 		tst.b		FPU
				beq.s		.no_FPU
				lea			SAVE_FPU,a0
				fmove.l		-(a0),fpcr
				fmove.l		-(a0),fpiar
				fmove.l		-(a0),fpsr
				lea			FP_REGISTER,a0
				fmovem.x	(a0),fp0-fp7
.no_FPU:		rts

*---------------

PMMU_EXCEPTION: RTE

*-------------------------------------------------------------------------------

VEKTOR_ADRESSEN:dc.w	$08,$0C,$10,$14,$18,$1C,$20,$24
				dc.w	$28,$2C,$34,$38,$3C,$60,$70,$7C
				dc.w	$80,$84,$88,$88,$8C,$90,$94,$98
				dc.w	$9C,$A0,$A4,$A8,$AC,$B0,$B4,$B8
				dc.w	$BC,$C0,$C4,$C8,$CC,$D0,$D4,$D8
				dc.w	$E0,$E4,$E8,$0114,$0118,$0138,$0404,$042A

ROUTINEN_ADRESSEN:
				dc.w	BUS_ERROR-ROUTINEN_ADRESSEN,ADRESS_ERROR-ROUTINEN_ADRESSEN,ILLEGAL-ROUTINEN_ADRESSEN,DIVISION-ROUTINEN_ADRESSEN,CHK-ROUTINEN_ADRESSEN,TRAPV-ROUTINEN_ADRESSEN
				dc.w	PRIVILEG-ROUTINEN_ADRESSEN,TRACE-ROUTINEN_ADRESSEN,LINEA-ROUTINEN_ADRESSEN,LINEF-ROUTINEN_ADRESSEN,CP_PROTOCOL-ROUTINEN_ADRESSEN,FORMAT-ROUTINEN_ADRESSEN
				dc.w	INTERRUPT-ROUTINEN_ADRESSEN,SPURIOUS-ROUTINEN_ADRESSEN,VBL-ROUTINEN_ADRESSEN,NMI-ROUTINEN_ADRESSEN,TRAP_0-ROUTINEN_ADRESSEN,GEMDOS-ROUTINEN_ADRESSEN
				dc.w	VDI-ROUTINEN_ADRESSEN,AES-ROUTINEN_ADRESSEN,TRAP_3-ROUTINEN_ADRESSEN,TRAP_4-ROUTINEN_ADRESSEN,TRAP_5-ROUTINEN_ADRESSEN,TRAP_6-ROUTINEN_ADRESSEN,TRAP_7-ROUTINEN_ADRESSEN,TRAP_8-ROUTINEN_ADRESSEN
				dc.w	TRAP_9-ROUTINEN_ADRESSEN,TRAP_A-ROUTINEN_ADRESSEN,TRAP_B-ROUTINEN_ADRESSEN,TRAP_C-ROUTINEN_ADRESSEN,BIOS-ROUTINEN_ADRESSEN,XBIOS-ROUTINEN_ADRESSEN,TRAP_F-ROUTINEN_ADRESSEN
				dc.w	FPCP_1-ROUTINEN_ADRESSEN,FPCP_2-ROUTINEN_ADRESSEN,FPCP_3-ROUTINEN_ADRESSEN,FPCP_4-ROUTINEN_ADRESSEN,FPCP_5-ROUTINEN_ADRESSEN,FPCP_6-ROUTINEN_ADRESSEN,FPCP_7-ROUTINEN_ADRESSEN
				dc.w	PMMU_CONFIG-ROUTINEN_ADRESSEN,PMMU_ILLEGAL-ROUTINEN_ADRESSEN,PMMU_ACCESS-ROUTINEN_ADRESSEN
				dc.w	HZ_200-ROUTINEN_ADRESSEN,KEYBOARD-ROUTINEN_ADRESSEN,RING_INDICATOR-ROUTINEN_ADRESSEN,ETV_CRITIC-ROUTINEN_ADRESSEN,RESET-ROUTINEN_ADRESSEN

*-------------------------------------------------------------------------------
* BUS_ERROR			$8
* ADRESS_ERROR		$C
* ILLEGAL			$10
* TRACE				$24
* RESET				$42A
* TEST_BUS
* TestBusOn
* TestBusOff
*-------------------------------------------------------------------------------

				XBRA		OLD_BUSFEHLER
BUS_ERROR:	MOVE.L	    #BU_MESSAGE_1,BUS_MESSAGE_1
		MOVE.L	    #BU_MESSAGE_2,BUS_MESSAGE_2

		TST.B	    DEBUGGER_FLAG
		BNE	    INTERNER_BUSFEHLER
		TST.B	    SHOW_ACTIV
		BNE.S	    INTERNER_BUSFEHLER

		BTST	    #0,BU_FLAG+1
		BNE	    SHOW_BUS
		BTST	    #1,BU_FLAG+1
		BNE	    FIX_ERROR
		MOVE.L	    OLD_BUSFEHLER(PC),-(SP)
		RTS

*-------------------------------------------------------------------------------

				XBRA		OLD_ADRESSFEHLER
ADRESS_ERROR:	MOVE.L	    #AD_MESSAGE_1,BUS_MESSAGE_1
		MOVE.L	    #AD_MESSAGE_2,BUS_MESSAGE_2

		TST.B	    DEBUGGER_FLAG
		BNE.S	    INTERNER_ADRESSFEHLER
		TST.B	    SHOW_ACTIV
		BNE.S	    INTERNER_ADRESSFEHLER

		BTST	    #0,AD_FLAG+1
		BNE	    SHOW_BUS
		BTST	    #1,AD_FLAG+1
		BNE	    FIX_ERROR
		MOVE.L	    OLD_ADRESSFEHLER(PC),-(SP)
		RTS

*-------------------------------------------------------------------------------

INTERNER_ADRESSFEHLER:
		MOVE.L	    #UNGERADE_ADRESSE,INTERNER_ERROR
		BRA.S	    INTERNER_FEHLER
INTERNER_BUSFEHLER:
		MOVE.L	    #SPEICHER_BEREICH,INTERNER_ERROR
INTERNER_FEHLER:MOVE.L	    SAVE_ISP,INTERN_ISP
		MOVE.L	    SAVE_PC,INTERN_PC
		MOVE.W	    SAVE_STATUS,INTERN_STATUS
		MOVE.L	    #_STACK_ISP,SAVE_ISP
		MOVE.L	    #INTERN_RETURN,SAVE_PC
		MOVE.W	    #$2700,SAVE_STATUS
		BRA	    GOTO_PROGRAM
INTERN_RETURN:	JSR	    CREATE_FRAME
		MOVE.L	    INTERN_PC,-(SP)
		MOVE.W	    INTERN_STATUS,-(SP)
		BSR	    GOTO_DEBUGGER
		MOVE.L	    INTERN_ISP,SAVE_ISP
		jsr			CACHE_PUT
		BSR	    CLEAN_UP
		TST.B	    SHOW_ACTIV
		BEQ.S	    NO_SHOW_ACTIV

		sf	    SHOW_ACTIV
		LEA	    SHOW_RECORD,A0
		MOVE.W	    SHOW_NUMBER,D0
		MULU	    #42,D0
		LEA	    (A0,D0.l),A0
		CLR.B	    (A0)
		SUBQ.W	    #1,SHOW_ANZAHL
		bsr			Calc_FIRST_LINE
		BSR	    SCROLL_DOWN_C
		BRA	    EDITOR

NO_SHOW_ACTIV:	movea.l		INTERNER_ERROR,a3
				bsr			MessageRawDown_C

				lea			.return,a2			; neue Zeile printen
				movea.l		FIRST_ADRESS,a3
				bsr			PRINT_ADRESSE
				move.w		#10,X_POSITION
				lea			.return,a3
				bsr			RawMessageDown_C
				bra			EDITOR

				MessageC	.return,'$12345678>'

*-------------------------------------------------------------------------------

SHOW_BUS:
		TST.B	    CPU
		BEQ	    MC68000_FRAME
		CMPI.B	    #1,CPU
		BEQ.S	    MC68010_FRAME
		CMPI.B	    #4,CPU
		BEQ.S	    MC68040_FRAME

MC68020_FRAME:	MOVE.W	    (SP),BUS_SR	  ; Statusregister
		MOVE.L	    2(SP),BUS_PC	  ; Program Counter
		MOVE.W	    10(SP),BUS_SSW	  ; Special Status Word
		MOVE.L	    16(SP),BUS_AA	  ; Access Adress
		ANDI.W	    #$F000,6(SP)
		CMPI.W	    #$A000,6(SP)
		BEQ.S	    FRAME_SHORT
		LEA	    60(SP),SP
FRAME_SHORT:	LEA	    32(SP),SP
		BRA.S	    CONT_BUS

MC68040_FRAME:	MOVE.W	    (SP),BUS_SR	  ; Statusregister
		MOVE.L	    2(SP),BUS_PC	  ; Program Counter
		MOVE.W	    $C(SP),BUS_SSW   ; Special Status Word
		MOVE.L	    $14(SP),BUS_AA	  ; Access Adress
		LEA	    60(SP),SP
		BRA.S	    CONT_BUS

MC68010_FRAME:	MOVE.W	    (SP),BUS_SR	  ; Statusregister
		MOVE.L	    2(SP),BUS_PC	  ; Program Counter
		MOVE.W	    8(SP),BUS_SSW	  ; Special Status Word
		MOVE.L	    10(SP),BUS_AA	  ; Access Adress
		LEA	    58(SP),SP
		BRA.S	    CONT_BUS

MC68000_FRAME:	MOVE.W	    (SP)+,BUS_SSW	  ; Special Status Word
		MOVE.L	    (SP)+,BUS_AA	  ; Access Adress
		MOVE.W	    (SP)+,BUS_OPCODE  ; Opcode
		MOVE.W	    (SP)+,BUS_SR	  ; Statusregister
		MOVE.L	    (SP)+,BUS_PC	  ; Program Counter

CONT_BUS:
		JSR	    CREATE_FRAME
		PEA	    RETURN_BUS(PC)
		MOVE.W	    BUS_SR,-(SP)
		BSR	    GOTO_DEBUGGER

*---------------

RETURN_BUS:	TST.B	    CPU
		BEQ.S	    SEARCH_OPCODE


*		 BTST	     #7,SAVE_STATUS    ; Search Opcode MC68010-40
*		 BNE.S	     ADRESS_IO
*		 MOVEA.L     BUS_PC,A3
*		 BSR	     SearchUp
*		 BEQ.S	     ADRESS_IO
*		 MOVE.L      A3,BUS_PC
ADRESS_IO:	MOVE.L	    BUS_PC,SAVE_PC
		MOVE.W	    BUS_SSW,D0
		MOVEA.L     BUS_MESSAGE_2,A3
		BTST	    #6,D0
		BEQ.S	    NOW_MESSAGE
		MOVEA.L     BUS_MESSAGE_1,A3
		BRA.S	    NOW_MESSAGE

*---------------

SEARCH_OPCODE:	MOVE.W	    BUS_OPCODE,D3	  ; Search Opcode MC68000
		MOVEA.L     BUS_PC,A3
		MOVEA.L     A3,A2
		MOVEQ	    #10,D1
		sf	    D2
SEARCHING:	SUBQ.W	    #1,D1
		BMI.S	    DA_HABEN_WIRS
		CMP.W	    -(A3),D3
		BNE.S	    SEARCHING
		TST.B	    D2
		BNE.S	    NOT_FIRST_ONE
		st	    D2
		MOVEA.L     A3,A2
NOT_FIRST_ONE:	JSR	    DisassemLength
		LEA	    (A3,D0.w),A0
		CMPA.L	    BUS_PC,A0
		BHI.S	    SEARCHING
		MOVEA.L     A3,A2

DA_HABEN_WIRS:	MOVE.L	    A2,SAVE_PC
		MOVE.W	    BUS_SSW,D0
		MOVEA.L     BUS_MESSAGE_1,A3
		BTST	    #4,D0
		BNE.S	    NOW_MESSAGE
		MOVEA.L     BUS_MESSAGE_2,A3

*---------------

NOW_MESSAGE:	BSR	    CLEAN_UP
		LEA	    FEHLER_ADRESSEN,A0
		MOVE.L	    SAVE_PC,(A0)+
		MOVE.L	    BUS_AA,(A0)+
		AND.L	    #7,D0
		MOVE.L	    D0,(A0)+
		BSR	    PRINT_ERROR
		BSR	    SET_PC
		jsr			CACHE_PUT
		BRA	    EDITOR

*-------------------------------------------------------------------------------

FIX_ERROR:	TST.B	    CPU
		BEQ.S	    MC68000_BUS
		CMPI.B	    #1,CPU
		BEQ.S	    MC68010_BUS
		CMPI.B	    #4,CPU
		BEQ.S	    MC68040_BUS

		ANDI.W	    #$F000,6(SP)
		CMPI.W	    #$A000,6(SP)
		BEQ.S	    MC68020_SHORT

		LEA	    92(SP),SP
		CLR.W	    -(SP)
		MOVE.L	    -88(SP),-(SP)
		MOVE.W	    -86(SP),-(SP)
		RTE

MC68020_SHORT:	LEA	    32(SP),SP
		CLR.W	    -(SP)
		MOVE.L	    -28(SP),-(SP)
		MOVE.W	    -26(SP),-(SP)
		RTE

MC68040_BUS:	LEA	    60(SP),SP
		CLR.W	    -(SP)
		MOVE.L	    -56(SP),-(SP)
		MOVE.W	    -54(SP),-(SP)
		RTE

MC68010_BUS:	LEA	    58(SP),SP
		CLR.W	    -(SP)
		MOVE.L	    -54(SP),-(SP)
		MOVE.W	    -52(SP),-(SP)
		RTE

MC68000_BUS:	ADDQ.W	    #8,SP
		RTE

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

				XBRA		OLD_ILLEGAL
ILLEGAL:	TST.B	    SUPERVISOR
		BEQ.S	    NO_SUPERVISOR	  ; Umschalten Supervisormodus

		sf	    SUPERVISOR
		MOVE.W	    (SP),ILLEGAL_SR
		BCLR	    #4,(SP)
		BSET	    #5,(SP)		  ; in Supervisormodus schalten
		ADDQ.L	    #2,2(SP)
		RTE

NO_SUPERVISOR:	MOVEM.L     D0-D1/D6-A2,-(SP)
		LEA	    BREAK_POINT,A0
		MOVEA.L     30(SP),A1
		MOVEQ	    #0,D6
		MOVEQ	    #-1,D7
		sf	    TRACE_MODUS_3
		BCLR	    #7,28(SP)
		MOVEQ	    #ANZAHL_BREAKPOINTS+5,D1
SUCH_BPT_2:	TST.L	    (A0)
		BEQ.S	    KEIN_TRACEN
		MOVEA.L     4(A0),A2
		CMPA.L	    (A0),A1
		BNE.S	    KEIN_TRACEN
		st	    D6			  ; kein illegaler Breakpoint
		JSR	    (A2)
		BNE.S	    KEIN_ABBRUCH
		MOVE.W	    D1,D7		  ; Abbruch bei Breakpoint D7
		BRA.S	    KEIN_TRACEN
KEIN_ABBRUCH:	BGT.S	    KEIN_TRACEN
		st	    TRACE_MODUS_3
		BSET	    #7,28(SP)
KEIN_TRACEN:	LEA	    16(A0),A0
		DBRA	    D1,SUCH_BPT_2

		TST.W	    D7
		BPL.S	    ABBRUCH_ILLEGAL
		TST.B	    D6
		BEQ	    NO_BREAKPT
		MOVEM.L     (SP)+,D0-D1/D6-A2
		RTE

ABBRUCH_ILLEGAL:SUB.W	    #ANZAHL_BREAKPOINTS-1,D7
		BHI.S	    NO_MESSAGE
		NEG.W	    D7
		ext.l		d7
		MOVE.l	    D7,FEHLER_ADRESSEN
		MOVEM.L     (SP)+,D0-D1/D6-A2
		BSR	    GOTO_DEBUGGER
		MOVE.L	    SAVE_PC,FEHLER_ADRESSEN+4
		MOVE.W	    FEHLER_ADRESSEN+2,D0
		LSL.W	    #4,D0
		LEA	    BREAKPOINTS,A0
		LEA	    12(A0,D0.w),A0
		LEA	    PERMANENT_MESSAGE,A3
		TST.W	    (A0)
		BEQ.S	    BLEIBT_DABEI
		LEA	    ANZAHL_MESSAGE,A3
BLEIBT_DABEI:	BSR	    PRINT_ERROR
		BRA	    EDITOR
NO_MESSAGE:	SUBQ.W	    #3,D7
		BMI.S	    GO_OR_DO
		MOVEM.L     (SP)+,D0-D1/D6-A2
		MOVE.L	    #TOS_STOP,2(SP)
		RTE
GO_OR_DO:	MOVEM.L     (SP)+,D0-D1/D6-A2	  ; Go oder Do
		BSR	    GOTO_DEBUGGER
		TST.B	    ONLY_LEXE
		BEQ.S	    NO_LEXE
		sf	    ONLY_LEXE			; Lexecute
		MOVEA.L     FILE_TEXT,A3
				bsr			LIST_16
				move.w		Y_POSITION,D3
				addq.w		#1,D3
		CMP.W	    ZEILEN_SCREEN,D3
		BLO.S	    NO_SCROLL
		BSR	    SCROLL_DOWN_C
		MOVE.W	    ZEILEN_SCREEN,D3
		SUBQ.W	    #1,D3
NO_SCROLL:	MOVE.W	    D3,Y_POSITION
		MOVE.W	    #10,X_POSITION
		BSR	    CLEAR_LINE
				JSR			GET_Y_ADRESS
		MOVEA.L     A0,A2
		MOVEA.L     FIRST_ADRESS,A3
		BSR	    PRINT_ADRESSE
		BSR	    PRINT_Y_LINE
		BSR	    POSITIONIEREN
		JMP	    EDITOR
NO_LEXE:	BSR	    ListPC
		JMP	    EDITOR

NO_BREAKPT:	CMPI.W	    #ILLEGAL_OPCODE,(A1)
		BNE.S	    NORMAL_HANDLER
		BTST	    #0,IL_FLAG+1
		BEQ.S	    NORMAL_HANDLER

		MOVEM.L     (SP)+,D0-D1/D6-A2
		BSR	    GOTO_DEBUGGER
		MOVE.L	    SAVE_PC,FEHLER_ADRESSEN
		PrintError	IL_MESSAGE
		BSR	    ListPC
		ADDQ.L	    #2,SAVE_PC
		BSR	    SET_PC
		ADDQ.W	    #1,Y_POSITION
		BSR	    POSITIONIEREN
		JMP	    EDITOR

NORMAL_HANDLER: MOVEM.L     (SP)+,D0-D1/D6-A2
				ErrorHandler	OLD_ILLEGAL,IL_MESSAGE,IL_FLAG

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

				XBRA		OLD_TRACE
TRACE:			andi.w		#$3fff,(sp)			; Trace mal aus
				tst.b		STOP_TRACE
				beq.s		trace_BPT
				rte

*-------------- TRACE BPT
trace_BPT:		tst.b		TRACE_MODUS_3
				beq.s		.no_BPT
				movem.l		d0-d1/a0-a2,-(sp)
				lea			BREAK_POINT,a0		; a0=BREAK_POINT
				movea.l		4*5+2(sp),a1		; a1=PC
				sf			TRACE_MODUS_3		; Trace mal aus
				moveq		#ANZAHL_BREAKPOINTS+5,d1
.search_BPT:	tst.l		(a0)				; BPT gesetzt
				beq.s		.dont_trace
				movea.l		4(a0),a2			; a2=Traceroutine
				cmpa.l		(a0),a1				; PC erreicht?
				jsr			(a2)				; Traceroutine
				blt.s		.do_trace
				bgt.s		.dont_trace
				move.l		#ABBRECHEN,4(a0)	; Abbruch durch getracten
				movem.l		(sp)+,d0-d1/a0-a2	; Breakpoint
				bra			ILLEGAL
.do_trace:		st			TRACE_MODUS_3		; Trace wieder an
				bset		#7,20(sp)
.dont_trace:	lea			16(a0),a0
				dbra		d1,.search_BPT
				movem.l		(sp)+,d0-d1/a0-a2

*-------------- TRACE no JSR/BSR
.no_BPT:		btst		#TRACE_ONE,TRACE_MODUS_1
				beq.s		.no_single
				tst.l		OLD_TRACERTS		; wird nur als ZÑhler benutzt!
				beq.s		.trace_first
				move.l		2(sp),OLD_TRACERTS	; RÅcksprungadresse
				move.l		#.change_PC,2(SP)	; neue RÅcksprungadresse
				bclr		#TRACE_ONE,TRACE_MODUS_1
				rte								; Trace zuerst verlassen
.change_PC:		move.l		OLD_TRACERTS(PC),-(sp)
				move.l		4(sp),OLD_TRACERTS	; dann ein TRACERTS ausfÅhren
				move.l		#TRACERTS,4(sp)
				bset		#TRACE_RTS,TRACE_MODUS_2
				rts
.trace_first:	subq.l		#1,OLD_TRACERTS		; auf -1 setzen damit im nÑchsten
				bset		#7,(sp)				; Trace abgebrochen wird
				rte

*-------------- TRACE +/-
.no_single:		btst		#TRACE_PLUS,TRACE_MODUS_1
				bne.s		.tracen
				btst		#TRACE_MINUS,TRACE_MODUS_1
				beq.s		.no_plus
.tracen:		pea			.return(pc)				; Usertraceroutine aufrufen
				move.l		USERTRACE(pc),-(sp)
				rts
.return:		bgt.s		.weiter_OHNE			; ---> nicht weitertracen
				bmi.s		.check_TRACE			; ---> weitertracen
				bsr			GOTO_DEBUGGER			; ---> Debugger aufrufen
				movea.l		USERTRACE,a3
				movea.l		-16(a3),a3
				bsr			PRINT_ERROR
				jmp			EDITOR
.check_TRACE:	btst		#TRACE_ALL,TRACE_MODUS_1
				bne.s		.weiter_MIT
				tst.w		FLOCK.w
				bne.s		.weiter_OHNE
				move.w		(sp),-(sp)
				andi.w		#$700,(sp)
				cmpi.w		#$600,(sp)+
				bhs.s		.weiter_OHNE
.weiter_MIT:	bset		#7,(sp)
.weiter_OHNE:	btst		#TRACE_MINUS,TRACE_MODUS_1
				bne.s		.go
				bsr			CACHE_FUELLEN
.go:			st			TRACE_MODUS_5
				rte

*---------------

.no_plus:		btst		#TRACE_NOT,TRACE_MODUS_2
				beq.s		.trace_Anzahl
				rte

*-------------- TRACE Anzahl
.trace_Anzahl:	btst		#TRACE_ANZAHL,TRACE_MODUS_1
				beq.s		.kein_Anzahl
				subq.l		#1,TRACE_ZAEHLER
				bne			.TraceOver
				bsr			GOTO_DEBUGGER
				bsr			ListPC
				jmp			EDITOR

*-------------- TRACE Exception
.kein_Anzahl:	btst		#TRACE_EXCEPT,TRACE_MODUS_2
				beq.s		.no_except
				bset		#TRACE_NOT,TRACE_MODUS_2
				bsr			CACHE_FUELLEN
				tst.b		OPCODE_PC				; Wird vor dem Auslîsen der
				bne.s		.its_not_PC				; Exception der PC um zwei
				addq.l		#2,2(sp)				; Bytes erhîht?
.its_not_PC:	jsr			CREATE_FRAME			; Einsprungsframe
				move.l		JUMPTO_EXCEPT(pc),-(sp)
				move.w		6(sp),-(sp)
				bset		#5,(sp)					; Supervisorbit setzen
				bsr			GOTO_DEBUGGER
				bsr			ListPC
				jmp			EDITOR

*-------------- TRACE_68020
.no_except:		btst		#TRACE_68020,TRACE_MODUS_1
				bne.s		.cont
				rte
.cont:			tst.b		TRACE_MODUS_4			; Tr68020 ab zweitem Befehl
				st			TRACE_MODUS_4
				beq			.TraceOver
				movem.l		d0-d1/a0,-(sp)
				movea.l		3*4+2(sp),a0			; PC
				move.w		(a0),d0					; Opcode
				move.w		d0,d1
				clr.b		d1
				cmpi.w		#$4e00,d1
				bne.s		.no_4e
				cmpi.b		#$73,d0					; $4e73=RTE?
				beq.s		.break68020
				cmpi.b		#$75,d0					; $4e75=RTS?
				beq.s		.break68020
				cmpi.b		#$77,d0					; $4e77=RTR?
				beq.s		.break68020
				moveq		#$fffffff0,d1
				and.b		d0,d1
				cmpi.b		#$40,d1					; $4e40-$4e4f=TRAP?
				beq.s		.break68020
				moveq		#$ffffffc0,d1
				and.b		d0,d1
				cmpi.b		#$c0,d1					; JMP?
				beq.s		.check_addressierung
				cmpi.b		#$80,d1					; JSR?
				beq.s		.check_addressierung
				bra.s		.TraceOver68020
.no_4e:			andi.w		#$f000,d1
				cmpi.w		#$6000,d1				; Bcc
				beq.s		.break68020
				andi.w		#$f0f8,d0
				cmpi.w		#$50c8,d0				; DBcc
				beq.s		.break68020
				bra.s		.TraceOver68020
.check_addressierung:
				moveq		#$38,d1
				and.w		d0,d1
				lsr.w		#3,d1
				cmpi.w		#7,d1
				beq.s		.ohne_reg
				move.b		.check_1_T(pc,d1.w),d1
				btst		d1,#$27e
				bne.s		.break68020
				bra.s		.TraceOver68020
.ohne_reg:		moveq		#7,d1
				and.w		d0,d1
				move.b		.check_2_T(pc,d1.w),d1
				btst		d1,#$27e
				bne.s		.break68020
				bra.s		.TraceOver68020

.break68020:	movem.l		(sp)+,d0-d1/a0
				bsr			GOTO_DEBUGGER
				bsr			ListPC
				jmp			EDITOR

.check_1_T:		dc.b		11,10,9,8,7,6,5
.check_2_T:		dc.b		4,3,2,1,0,15,15,15
		.EVEN

*-------------- TRACE Over ---> Trapv, Trap 0-15, Linea als ein Befehl tracen
.TraceOver:		movem.l		d0-d1/a0,-(sp)
.TraceOver68020:movea.l		3*4+2(sp),a0			; PC
				move.w		(a0),d0					; Opcode
				move.w		d0,OPCODE_OVER
				cmpi.w		#$4e76,d0				; TRAPV?
				bne.s		.no_TRAPV
				move.w		#$1c,VEKTOR_OFFSET
				btst		#1,13(sp)
				bne.s		dont_TRACE				; wenn V Flag gesetzt dann Overtrace
				bra			do_TRACE				; sonst tracen
.no_TRAPV:		moveq		#$f,D1
				and.b		d0,d1
				add.w		d1,d1
				add.w		d1,d1
				add.w		#$80,d1
				move.w		d1,VEKTOR_OFFSET
				andi.w		#$fff0,d0
				cmpi.w		#$4e40,d0				; TRAP 0-15?
				beq.s		dont_TRACE
				move.w		#$28,VEKTOR_OFFSET
				andi.w		#$f000,d0
				cmpi.w		#$a000,d0				; LINEA?
				bne.s		do_TRACE

dont_TRACE:		movem.l		(sp)+,d0-d1/a0
				bset		#TRACE_NOT,TRACE_MODUS_2
				bsr			CACHE_FUELLEN
				move.w		(sp),SAVE_OVER_SR		; fÅr SYSMON ---> Schnittstelle
				move.l		2(sp),SAVE_OVER_PC		; fÅr SYSMON ---> Schnittstelle
				move.l		#OPCODE_OVER,2(sp)
				rte
BACK_OVER:		st			SUPERVISOR
				illegal
				jsr			CREATE_FRAME
				move.l		SAVE_OVER_PC(pc),-(sp)
				addq.l		#2,(sp)
				move.w		ILLEGAL_SR,-(sp)		; Trap ---> SR verÑndert
				st			STOP_TRACE
				sf			STOP_TRACE
				bclr		#TRACE_NOT,TRACE_MODUS_2
				clr.l		SAVE_OVER_PC			; wegen SYSMON
				clr.w		SAVE_OVER_SR			; wegen SYSMON
				bra			TRACE

do_TRACE:		movem.l		(sp)+,d0-d1/a0
*				tst.w		FLOCK.w
*				bne.s		.weiter_OHNE
*				move.w		(sp),-(sp)
*				andi.w		#$700,(sp)
*				cmpi.w		#$600,(sp)+
*				bhs.s		.weiter_OHNE
				bsr.s		CACHE_FUELLEN
				bset		#7,(sp)
				rte
*.weiter_OHNE:	bsr.s		CACHE_FUELLEN
*				st			TRACE_MODUS_5
*				rte

*-------------- Cache fÅllen
CACHE_FUELLEN:	MOVE.L      (SP)+,CACHE_RETURN
				MOVEM.L     D0/A0-A1,-(SP)
		LEA	    CACHE_POINTER_1(PC),A1
		TST.B	    CACHE_FLAG
		BEQ.S	    CACHE_1
		LEA	    CACHE_POINTER_2(PC),A1
CACHE_1:	MOVEA.L     (A1),A0
		MOVE.L	    (A0),(A1)
		SUBQ.W	    #4,A0		  ; A7 auslassen
		MOVEA.L     SP,A1
		MOVEM.L     D0-A6,-(A0) 	  ; D0-A6
		MOVE.L	    (A1)+,(A0)		  ; D0
		MOVE.L	    (A1)+,32(A0)	  ; A0
		MOVE.L	    (A1)+,36(A0)	  ; A1
		MOVE.W	    (A1)+,-(A0) 	  ; SR
		MOVE.L	    (A1)+,-(A0) 	  ; PC
		MOVEQ	    #0,D0
		MOVE.B	    (A1),D0		  ; Stackframe entfernen
		LSR.W	    #4,D0
		JSR	    FRAME_LENGTH
		ADD.W	    D0,D0
		LEA	    -6(A1,D0.w),A1	  ; SP-6(pc&sr)+framelength*2
		MOVE	    SR,D0
		BTST	    #12,D0
		BEQ.S	    ITS_SUPERVISOR
		EXG	    A1,SP
		ANDI	    #$EFFF,SR		  ; auf Supervisorstack schalten
		MOVE.L	    SP,-(A0)		  ; ISP
		MOVE.L	    A1,-(SP)
		MOVE	    USP,A1
		MOVE.L	    A1,-(A0)		  ; USP
		MOVEA.L     (SP)+,A1
		BSR	    FETCH_REGISTER
		ORI	    #$3000,SR		  ; und wieder auf Masterstack
		MOVEA.L     A1,SP
		MOVEM.L     (SP)+,D0/A0-A1
		MOVE.L	    CACHE_RETURN,-(SP)
		RTS

ITS_SUPERVISOR: MOVE.L	    A1,-(A0)		  ; ISP
		MOVE	    USP,A1
		MOVE.L	    A1,-(A0)		  ; USP
		BSR	    FETCH_REGISTER
		MOVEM.L     (SP)+,D0/A0-A1
		MOVE.L	    CACHE_RETURN,-(SP)
		RTS

*-------------------------------------------------------------------------------

				MessageC	USERTRACE_MESSAGE,'Called by usertrace routine'
				dc.l		USERTRACE_MESSAGE
				XBRA		.no_label
USER_TRACE:	st	    -(SP)
		TST.B	    (SP)+
		RTS

*--------------
PERMANENT_RAM:	BEQ.S	    ABBRECHEN
		MOVEQ	    #1,D0		  ; ohne Trace weiter
		RTS
PERMANENT_ROM:	BEQ.S	    ABBRECHEN
		MOVEQ	    #-1,D0		  ; mit Trace weiter
		RTS
ABBRECHEN:	MOVEQ	    #0,D0
		RTS				  ; Abbruch immer wenn PC

*--------------
ZAEHLER_RAM_1:	 BNE.S	     CONT_ZAEHLER
		MOVE.W	    14(A0),(A1) 	  ; Illegal ZÑhler Ram
		MOVE.L	    A1,TRACE_PC_1
		MOVE.L	    #ZAEHLER_RAM_2,4(A0)
		ADDQ.L	    #1,8(A0)
		MOVEQ	    #-1,D0
		RTS

*--------------
ZAEHLER_RAM_2:	 BNE.S	     NICHT_ERHOEHEN_2	    ; Trace ZÑhler Ram
		MOVEQ	    #-1,D0
		RTS
NICHT_ERHOEHEN_2:EXG	     A1,D0
		MOVEA.L     TRACE_PC_1,A1
		MOVE.W	    #ILLEGAL_OPCODE,(A1)
		EXG	    A1,D0
		MOVE.L	    #ZAEHLER_RAM_1,4(A0)
CONT_ZAEHLER:	 MOVEQ	     #1,D0
		RTS

*--------------
ZAEHLER_ROM:	 BNE.S	     WEITER_TRACEN	   ; Trace ZÑhler Rom
		ADDQ.L	    #1,8(A0)
WEITER_TRACEN:	MOVEQ	    #-1,D0
		RTS

*--------------
ANZAHL_RAM_1:	BNE.S	    CONT_ZAEHLER
		SUBQ.L	    #1,8(A0)		  ; Illegal Anzahl Ram
		BEQ.S	    ZAEHLER_NULL
		MOVE.W	    14(A0),(A1)
		MOVE.L	    A1,TRACE_PC_2
		MOVE.L	    #ANZAHL_RAM_2,4(A0)
		MOVEQ	    #-1,D0
ZAEHLER_NULL:	 RTS

*--------------
ANZAHL_RAM_2:	BNE.S	    WIEDER_ILLEGAL	  ; Trace Anzahl Ram
		TST.L	    8(A0)
		BEQ.S	    ANZAHL_NULL
		MOVEQ	    #-1,D0
		RTS
WIEDER_ILLEGAL: EXG	    A1,D0
		MOVEA.L     TRACE_PC_2,A1
		MOVE.W	    #ILLEGAL_OPCODE,(A1)
		EXG	    A1,D0
		MOVE.L	    #ANZAHL_RAM_1,4(A0)
		MOVEQ	    #1,D0
ANZAHL_NULL:	RTS

*--------------
ANZAHL_ROM:	BNE.S	    WEITER_TRACEN	  ; Trace Anzahl Rom
		SUBQ.L	    #1,8(A0)
		BNE.S	    WEITER_TRACEN
		RTS

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

				XBRA		OLD_RESET
RESET:			MOVE	    SR,SAVE_SR_RESET
				MOVE	    #$2700,SR
		MOVEM.L     D0-A7,SAVE_FOR_RESET
		LEA	    _STACK_RESET,SP
		PEA	    RESET_RETURN(PC)	  ; USER_RESET aufrufen
		MOVE.L	    USERRESET,-(SP)
		RTS
RESET_RETURN:	tst.b		DO_A_RESET
				bne.s		TEST_RESET
				TST.B	    CHEAT_MODE
				BNE	    UFF_GESCHAFFT
		TST.B	    DEBUGGER_FLAG
		BEQ.S	    OUTSIDE
		BTST	    #4,RE_FLAG+1
		BNE	    	UFF_GESCHAFFT
		BTST	    #5,RE_FLAG+1
		BEQ	    	MACH_RESET
		TST.L	    RESET_ZAEHLER
		BEQ.S	    START_ZAEHLER
		MOVE.L	    HZ200_ZAEHLER,D0
		SUB.L	    RESET_ZAEHLER,D0
		BPL	    MACH_RESET
START_ZAEHLER:	 MOVE.L      HZ200_ZAEHLER,D0
		SUB.L	    #200,D0
		MOVE.L	    D0,RESET_ZAEHLER
		BRA	    UFF_GESCHAFFT
OUTSIDE:	BTST	    #0,RE_FLAG+1
		BNE	    UFF_GESCHAFFT
		BTST	    #1,RE_FLAG+1
		BNE.S	    MACH_RESET

*---------------

TEST_RESET:MOVE.L	    $8.w,SAVE_BUS_RESET
		MOVE.L	    $C.w,SAVE_ADRESS_RESET
		MOVE.L	    #_RESET,$8.w
		MOVE.L	    #_RESET,$C.w
		MOVE.L	    #$31415926,RESVALID.w
		MOVEA.L     OLD_RESET(PC),A0
		MOVE.L	    A0,RESVECTOR.w
		CMPI.L	    #'XBRA',-12(A0)
		BEQ.S	    ANOTHER_ONE
_RESET: 	CLR.L	    RESVALID.w
ANOTHER_ONE:	MOVE.L	    SAVE_BUS_RESET,$8.w
		MOVE.L	    SAVE_ADRESS_RESET,$C.w
		MOVEM.L     SAVE_FOR_RESET,D0-A7
		MOVE	    SAVE_SR_RESET,SR
		CMPI.W	    #$9BCD,(A6)
		BNE.S	    A6_IO_1
		JMP	    $24(A6)
A6_IO_1:	JMP	    (A6)

*---------------

MACH_RESET:		sf			DO_A_RESET
				clr.l		_P_COOKIES.w	  ; Reseten
				clr.l		_SHELL_P.w
				clr.l		PUN_PTR.w
				clr.l		RESVALID.w
				clr.l		RESVECTOR.w
		MOVEM.L     SAVE_FOR_RESET,D0-A7
		MOVE	    SAVE_SR_RESET,SR
		CMPI.W	    #$9BCD,(A6)
		BNE.S	    A6_IO_2
		JMP	    $24(A6)
A6_IO_2:	JMP	    (A6)

*---------------

UFF_GESCHAFFT:	MOVE.L	    SAVE_SCREEN,SAVE_SCREEN_RESET
		MOVE.W	    SAVE_SHIFTMODE,SAVE_SHIFTMODE_RESET
		MOVE.B	    SAVE_SYNCMODE,SAVE_SYNCMODE_RESET
		MOVE.B	    SAVE_LINEWID,SAVE_LINEWID_RESET
		MOVE.B	    SAVE_HSCROLL,SAVE_HSCROLL_RESET
		LEA	    SAVE_FALCON_REG,A0
		LEA	    SAVE_FALCON_REG_RESET,A1
		MOVEQ	    #FALCONREGLENGTH-1,D0
COPY_FALCON:	MOVE.B	    (A0)+,(A1)+
		DBRA	    D0,COPY_FALCON
		BSR	    INIT_HARDWARE	  ; Einspringen
		BSR	    REALLY_CLEAN_UP
		BSR	    CLEAR_KEYBOARD
		MOVE.L	    SAVE_SCREEN_RESET,SAVE_SCREEN
		MOVE.W	    SAVE_SHIFTMODE_RESET,SAVE_SHIFTMODE
		MOVE.B	    SAVE_SYNCMODE_RESET,SAVE_SYNCMODE
		MOVE.B	    SAVE_LINEWID_RESET,SAVE_LINEWID
		MOVE.B	    SAVE_HSCROLL_RESET,SAVE_HSCROLL
		LEA	    SAVE_FALCON_REG,A0
		LEA	    SAVE_FALCON_REG_RESET,A1
		MOVEQ	    #FALCONREGLENGTH-1,D0
COPY_FALCON_BACK:MOVE.B     (A1)+,(A0)+
		DBRA	    D0,COPY_FALCON_BACK
		TST.B	    DEBUGGER_FLAG
		BNE.S	    IST_INNERHALB

*---------------

		MOVEM.L     SAVE_FOR_RESET,D0-A7  ; Reset ausserhalb
		JSR	    CREATE_FRAME
		PEA	    (A6)
		CMPI.W	    #$9BCD,(A6)
		BNE.S	    A6_IO_3
		ADDI.L	    #$24,(SP)
A6_IO_3:	MOVE.W	    SAVE_SR_RESET,-(SP)
		BSR	    GOTO_DEBUGGER
		MOVE.L	    SAVE_SCREEN_RESET,D0
		BEQ.S	    FIRST_JUMP_IN
		MOVE.L	    D0,SAVE_SCREEN
FIRST_JUMP_IN:
		PrintError	RE_MESSAGE_1
		JMP	    EDITOR

*---------------

IST_INNERHALB:	JSR	    CREATE_FRAME
		MOVE.L	    SAVE_PC,-(SP)	  ; Reset innerhalb
		MOVE.W	    SAVE_STATUS,-(SP)
		BSR	    GOTO_DEBUGGER_2
		CMPI.B	    #3,CPU
		BNE.S	    NO_MC68030
		MOVE.L	    #$1111,D0
			dc.w $4E7B,$2		  ; Movec D0,CACR
NO_MC68030:
		LEA	    RESET_WITHIN,A3
		BSR	    MessageRawDown_C
		JMP	    EDITOR

*---------------

REALLY_CLEAN_UP:st			STOP_TRACE
				sf			STOP_TRACE
				sf			SLOW_MODE
				sf			CHANGE_SR
				sf			SHIFTRECHTS_FLAG
				sf			SHIFTLINKS_FLAG
				sf			CAPSLOCK_FLAG
				sf			CONTROL_FLAG
				sf			ALTERNATE_FLAG
				sf			KEY_IGNORE_IKBD
				sf			MAUS_PAKET_IKBD
				sf			MAUSLEFT_FIRST
				sf			MAUSRIGHT_FIRST
				sf			OBSERVE_FLAG
				MOVE.B		#-1,LIST_FLAG
				CLR.W		UEBERTRAG_X
				CLR.W		UEBERTRAG_Y
				CLR.W		MAUS_LEFT
				CLR.W		MAUS_RIGHT
				BSR			CLEAN_UP
				BSR			INVERS_ON
				MOVEQ		#0,D3
				BSR			PRINT_LINE
				MOVEQ		#1,D3
				BSR			PRINT_LINE
				BSR			INVERS_OFF
				BRA			PRINT_Y_LINE

*-------------------------------------------------------------------------------

				XBRA		OLD_TEST_BUS
TEST_BUS:		BRA.S	    TEST_ADRESS

				XBRA		OLD_TEST_ADRESS
TEST_ADRESS:	BSR	    TestBusOff
		LEA	    14(SP),SP		  ; MC68000, MC68008
		TST.B	    CPU
		BEQ.S	    _CPU_IO
		LEA	    29*2-14(SP),SP	  ; MC68010, MC68012
		CMPI.B	    #1,CPU
		BEQ.S	    _CPU_IO
		ADDQ.W	    #2,SP		  ; MC68040
		CMPI.B	    #4,CPU
		BEQ.S	    _CPU_IO
		LEA	    -60(SP),SP		  ; MC68020, MC68030
		ANDI.W	    #$F000,6(SP)
		CMPI.W	    #$A000,6(SP)
		BEQ.S	    _SHORT_BUS
		LEA	    60(SP),SP
_SHORT_BUS:	LEA	    32(SP),SP
_CPU_IO:	RTS

*-------------------------------------------------------------------------------

TestBusOn:		MOVE		SR,-(SP)
				ORI			#$700,SR
				CMPI.L		#TEST_BUS,$8.w
				BEQ.S		NO_BUS_1
				MOVE.L		$8.w,OLD_TEST_BUS
				MOVE.L		#TEST_BUS,$8.w
NO_BUS_1:		CMPI.L		#TEST_ADRESS,$C.w
				BEQ.S		NO_ADRESS_1
				MOVE.L		$C.w,OLD_TEST_ADRESS
				MOVE.L		#TEST_ADRESS,$C.w
NO_ADRESS_1:	MOVE		(SP)+,SR
				RTS

*-------------------------------------------------------------------------------

TestBusOff:		MOVE		SR,-(SP)
				ORI			#$700,SR
				CMPI.L		#TEST_BUS,$8.w
				BNE.S		NO_BUS_2
				MOVE.L		OLD_TEST_BUS(PC),$8.w
NO_BUS_2:		CMPI.L		#TEST_ADRESS,$C.w
				BNE.S		NO_ADRESS_2
				MOVE.L		OLD_TEST_ADRESS(PC),$C.w
NO_ADRESS_2:	MOVE		(SP)+,SR
				RTS

*-------------------------------------------------------------------------------
* DIVISION			$14
* CHK				$18
* TRAPV				$1C
* PRIVILEG			$20
* LINEA				$28
* LINEF				$2C
* CP_PROTOCOL		$34
* FORMAT			$38
* INTERRUPT			$3C
* SPURIOUS			$60
* VBL				$70
* NMI				$7C
* TRAP 0-15			$80-BC
* GEMDOS			$84
* VDI				$88
* AES				$88
* BIOS				$B4
* XBIOS				$B8
* FPCP_1			$C0
* FPCP_2			$C4
* FPCP_3			$C8
* FPCP_4			$CC
* FPCP_5			$D0
* FPCP_6			$D4
* FPCP_7			$D8
* PMMU_CONFIG		$E0
* PMMU_ILLEGAL		$E4
* PMMU_ACCESS		$E8
* HZ_200			$114
* KEYBOARD			$118
* RING_INDICATOR	$138
* ETV_CRITIC		$404
* EXEC_OS			$4FE
*-------------------------------------------------------------------------------

OLD_TRACERTS:	dc.l 0
TRACERTS:		bra.s		.warn_trap
				addq.l		#2,OLD_TRACERTS
.warn_trap:		st			SUPERVISOR
				illegal
				jsr			CREATE_FRAME
				move.l		OLD_TRACERTS(PC),-(sp)
				move.w		ILLEGAL_SR,-(sp)
				bsr			GOTO_DEBUGGER
				bsr			ListPC
				jmp			EDITOR

*-------------------------------------------------------------------------------

				XBRA			OLD_TRAPV
TRAPV:			ErrorHandler	OLD_TRAPV,TV_MESSAGE,TV_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_LINEA
LINEA:			bsr				SLOWMOTION
				ErrorHandler	OLD_LINEA,LA_MESSAGE,LA_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_LINEF
LINEF:			ErrorHandler	OLD_LINEF,LF_MESSAGE,LF_FLAG

*-------------------------------------------------------------------------------

				XBRA		OLD_VBL
VBL:			tst.b		ProgramRuns			; Shift-Shift?
				beq.s		.no_break
				tst.b		DEBUGGER_FLAG
				bne.s		.no_break
				cmpi.w		#-1,UMSCHALT_TASTEN
				bne.s		.no_break
				movem.l		d0/a0,-(sp)
				move.l		8+2(sp),d0
				move.l		FILE_ANFANG,a0
				cmp.l		a0,d0
				blo.s		.not_within
				adda.l		FILE_LAENGE,a0
				cmp.l		a0,d0
				bhs.s		.not_within
				movem.l		(sp)+,d0/a0
				bsr			GOTO_DEBUGGER
				move.l		SAVE_PC,FEHLER_ADRESSEN
				PrintError	.KEY_EINSPRUNG
				bra			EDITOR
.not_within:	movem.l		(sp)+,d0/a0
.no_break:		cmpi.b		#1,VDO				; STE?
				bne.s		.kein_STE
				move.b		HSCROLL.w,HSCROLL.w
.kein_STE:		bsr			SLOWMOTION			; Slowmotion
				tst.b		TRACE_MODUS_5
				beq.s		.no_trace
				tst.w		FLOCK.w
				bne.s		.no_trace
				bset		#7,(sp)
.no_trace:		ErrorHandler	OLD_VBL,VB_MESSAGE,VB_FLAG

*---------------

				MessageC	.KEY_EINSPRUNG,'Break with Shift-Shift at $'

*-------------------------------------------------------------------------------

				XBRA		OLD_HZ_200
HZ_200: 		SUBQ.L	    #1,HZ200_ZAEHLER	; RESVALID
				MOVE.B	    #$DF,ST_ISRB.w
				CMPI.L	    #RESET,$42A.w
				BNE.S	    .not_my_routine
				MOVE.L	    #$31415926,RESVALID.w

*---------------

.not_my_routine:tst.b		OBSERVE_FLAG		; Observe?
				beq			.no_observe
				movem.l		d0/a0-a1,-(sp)
				pea			.ende_observe
				bsr			TestBusOn
				movea.l		OBSERVE_ADDRESS,a0
				lea			OBSERVE_SAVE,a1
				move.w		OBSERVE_COUNT,d0
.check:			cmpm.b		(a1)+,(a0)+
				dbne		d0,.check
				beq.s		.still_equal
				move.l		a0,OBSERVE_ADDRESS_CHANGED	; gefunden
				subq.l		#1,OBSERVE_ADDRESS_CHANGED
				move.l		18(sp),OBSERVE_ADDRESS_WHERE
				tst.b		DEBUGGER_FLAG
				bne.s		.inside
				bsr			TestBusOff
				addq.w		#4,sp
				sf			OBSERVE_FLAG
				movem.l		(sp)+,d0/a0-a1
				bsr			GOTO_DEBUGGER
				move.l		OBSERVE_ADDRESS_CHANGED,FEHLER_ADRESSEN
				move.l		OBSERVE_ADDRESS_WHERE,FEHLER_ADRESSEN+4
				PrintError	OBSERVE_MESSAGE
				jmp			EDITOR
.inside: 		sf			OBSERVE_FLAG
				st			OBSERVE_FOUND
.still_equal:	bsr			TestBusOff
				addq.w		#4,sp
.ende_observe:	movem.l		(sp)+,d0/a0-a1

*---------------

.no_observe:	tst.b		DEBUGGER_FLAG
				beq.s		.no_clock
				subq.l		#1,HZ_200_SPEICHER
				bpl.s		.no_clock
				move.l		#200,HZ_200_SPEICHER
				st			CLOCK_PRINT
.no_clock:		ErrorHandler	OLD_HZ_200,HZ_MESSAGE,HZ_FLAG

*-------------------------------------------------------------------------------

				XBRA		OLD_GEMDOS
GEMDOS: 	BSR	    SLOWMOTION
		MOVEM.L     A0-A1,-(SP)
		MOVE	    USP,A0
		BTST	    #5,8(SP)
		BEQ.S	    USER_MODUS
		LEA	    14(SP),A0
		TST.B	    CPU
		BEQ.S	    USER_MODUS
		ADDQ.W	    #2,A0
USER_MODUS:	LEA	    PTERM_MESSAGE_1,A1
		TST.W	    (A0)
		BEQ.S	    PROGRAMM_TERM
		LEA	    PTERM_MESSAGE_2,A1
		CMPI.W	    #76,(A0)
		BEQ.S	    PROGRAMM_TERM
		LEA	    PTERM_MESSAGE_3,A1
		CMPI.W	    #49,(A0)
		BNE.S	    NO_PTERM
PROGRAMM_TERM:	MOVE.L	    A1,PTERM_MESSAGE
		MOVE.L	    10(SP),PTERM_ADRESSE
		SUBQ.L	    #2,PTERM_ADRESSE
		BTST	    #TRACE_NOT,TRACE_MODUS_2
		BEQ.S	    NO_TRACE
		MOVE.L	    SAVE_OVER_PC(PC),PTERM_ADRESSE
NO_TRACE:	TST.B	    ProgramRuns
		BNE.S	    NO_PTERM
		TST.B	    RESIDENT_FLAG
		BNE.S	    NO_PTERM

		MOVEM.L     (SP)+,A0-A1
		JSR	    CREATE_FRAME
		MOVE.L	    PTERM_ADRESSE,-(SP)
		MOVE	    SR,-(SP)
		BSR	    GOTO_DEBUGGER
		BSR	    ListPC
		MOVE.L	    SAVE_PC,FEHLER_ADRESSEN
		MOVEA.L     PTERM_MESSAGE,A3
		BSR	    MessageRawDown_C
		JMP	    EDITOR

NO_PTERM:	MOVEM.L     (SP)+,A0-A1
		BTST	    #TRACE_TO_TOS,TRACE_MODUS_2
		BNE	    TOS_STOP
				ErrorHandler	OLD_GEMDOS,GE_MESSAGE,GE_FLAG

*-------------------------------------------------------------------------------

				XBRA		OLD_AES
AES:		BSR	    SLOWMOTION
		BSR.S	    GET_VERSION
		BTST	    #TRACE_TO_TOS,TRACE_MODUS_2
		BNE	    TOS_STOP
				ErrorHandler	OLD_AES,AE_MESSAGE,AE_FLAG

*--------------------------------------------------------------------------------

				XBRA		OLD_VDI
VDI:		BSR	    SLOWMOTION
		BSR.S	    GET_VERSION
		BTST	    #TRACE_TO_TOS,TRACE_MODUS_2
		BNE	    TOS_STOP
				ErrorHandler	OLD_VDI,VD_MESSAGE,VD_FLAG

GET_VERSION:	MOVE.L	    A0,-(SP)
		CMP.W	    #$C8,D0		  ; AES Version bestimmen
		BNE.S	    DONT_TAKE
		MOVEA.L     D1,A0
		PEA	    DONT_TAKE(PC)
		BSR	    TestBusOn
		MOVEA.L     4(A0),A0
		TST.W	    (A0)
		BEQ.S	    NO_VERSION
		MOVE.W	    (A0),GLOBAL
NO_VERSION:	BSR	    TestBusOff
		ADDQ.W	    #4,SP
DONT_TAKE:	CMP.W	    #-1,D0
		BNE.S	    NO_GDOS
		st	    GDOS_INSTALLED
NO_GDOS:	MOVEA.L     (SP)+,A0
		RTS

*-------------------------------------------------------------------------------

				XBRA		OLD_BIOS
BIOS:		BSR	    SLOWMOTION
		BTST	    #5,(SP)
		BEQ.S	    CONT_BIOS
		TST.B	    CPU
		BEQ.S	    NORMAL_FRAME
		CMPI.L	    #$50101,8(SP)
		BNE.S	    CONT_BIOS
SETEXC: 	MOVEM.L     d0-a6,-(SP)
		st	    AES_INSTALLED
		TST.B	    AE_FLAG
		BEQ.S	    NO_AES
		LEA	    $88.w,A3
		LEA	    AES,A5
		JSR	    TestVektor
		BEQ.S	    NO_AES
		MOVE.L	    $88.w,OLD_AES
		MOVE.L	    A5,$88.w
NO_AES: 	TST.B	    LF_FLAG
		BEQ.S	    NO_LINEF
		LEA	    $2C.w,A3
		LEA	    LINEF,A5
		JSR	    TestVektor
		BEQ.S	    NO_LINEF
		MOVE.L	    $2C.w,OLD_LINEF
		MOVE.L	    A5,$2C.w
NO_LINEF:	MOVEM.L     (SP)+,d0-a6
		MOVE.L	    OLD_BIOS(PC),-(SP)
		RTS
NORMAL_FRAME:	CMPI.L	    #$50101,6(SP)
		BEQ.S	    SETEXC

CONT_BIOS:	BTST	    #TRACE_TO_TOS,TRACE_MODUS_2
		BNE	    TOS_STOP
				ErrorHandler	OLD_BIOS,BI_MESSAGE,BI_FLAG

*-------------------------------------------------------------------------------

				XBRA		OLD_XBIOS
XBIOS:		BSR	    SLOWMOTION
		BTST	    #TRACE_TO_TOS,TRACE_MODUS_2
		BNE	    TOS_STOP
				ErrorHandler	OLD_XBIOS,XB_MESSAGE,XB_FLAG

*-------------------------------------------------------------------------------

				XBRA		OLD_ETV_CRITIC
ETV_CRITIC:		tst.b		DEBUGGER_FLAG
				bne.s		.OWN_ETVCRITIC
				lea			16(sp),sp			; undokumentiert...
				ErrorHandler	OLD_ETV_CRITIC,ET_MESSAGE,ET_FLAG

.OWN_ETVCRITIC:	move.w		4(sp),d0			; Fehlernummer
				move.w		d0,d3
				movem.l		d1-d2/a0-a2,-(sp)
				bsr			CURSOR_OFF
				neg.w		d3
				add.w		d3,d3
				lea			.table(pc),a3
				move.w		-2(a3,d3.w),d3
				lea			(a3,d3.w),a2
				lea			.ERR_MESSAGE,a3
.copy_1:		move.b		(a2)+,(a3)+
				bne.s		.copy_1
				subq.w		#1,a3
				lea			.MESSAGE,a2
.copy_2:		move.b		(a2)+,(a3)+
				bne.s		.copy_2
				clr.b		(a3)
				move.b		#32,-(a3)
				movea.l		a3,a2
				lea			.ERR_MESSAGE,a3
				bsr			MessageRawDown_C
				move.w		Y_POSITION,d3

.wait_for_key:	bsr			CHEAT_KEY			; auf Tastendruck warten
				cmpi.b		#30,KEY
				beq.s		.abort
				cmpi.b		#19,KEY
				beq.s		.retry
				cmpi.b		#23,KEY
				beq.s		.ignore
				bra.s		.wait_for_key

.abort:			move.b		#'A',(a2)
				bsr			MessageRaw_C
				ext.l		d0
				bra.s		.ende

.retry:			move.b		#'R',(a2)
				bsr			MessageRaw_C
				moveq		#1,d0
				swap		d0
				bra.s		.ende

.ignore: 		move.b		#'I',(a2)
				bsr			MessageRaw_C
				moveq		#0,d0

.ende:			clr.b		KEY
				movem.l		(sp)+,d1-d2/a0-a2
				bra			CURSOR_ON

*---------------

				MessageC	.ERR_MESSAGE,'Write on write-protected media: (A)bort, (R)etry, (I)gnore? -'
				MessageC	.MESSAGE,': (A)bort, (R)etry, (I)gnore? '

.table:			dc.w		.m_1-.table,.m_2-.table,.m_3-.table,.m_4-.table,.m_5-.table,.m_6-.table
				dc.w		.m_7-.table,.m_8-.table,.m_9-.table,.m_a-.table,.m_b-.table,.m_c-.table
				dc.w		.m_d-.table,.m_e-.table,.m_f-.table,.m_10-.table,.m_b-.table,.m_11-.table
				dc.w		.m_12-.table,.m_13-.table

.m_1:			dc.b		'Error',0
.m_2:			dc.b		'Drive not ready',0
.m_3:			dc.b		'Unknown Command',0
.m_4:			dc.b		'CRC Error',0
.m_5:			dc.b		'Bad request',0
.m_6:			dc.b		'Seek Error',0
.m_7:			dc.b		'Unknown Media',0
.m_8:			dc.b		'Sector not found',0
.m_9:			dc.b		'Out of Paper',0
.m_a:			dc.b		'Write fault',0
.m_b:			dc.b		'Read fault',0
.m_c:			dc.b		'General Error',0
.m_d:			dc.b		'Write on write-protected media',0
.m_e:			dc.b		'Media change detected',0
.m_f:			dc.b		'Unknown device',0
.m_10:			dc.b		'Bad sectors on format',0
.m_11:			dc.b		'Insert other disc request',0
.m_12:			dc.b		'Insert Disc',0
.m_13:			dc.b		'Device not responding',0
		.EVEN

*-------------------------------------------------------------------------------

				XBRA			OLD_RING
RING_INDICATOR:	ErrorHandler	OLD_RING,RI_MESSAGE,RI_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_DIVISION
DIVISION:		ErrorHandler	OLD_DIVISION,DI_MESSAGE,DI_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_CHK
CHK:			ErrorHandler	OLD_CHK,CH_MESSAGE,CH_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_NMI
NMI:			ErrorHandler	OLD_NMI,NM_MESSAGE,NM_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_PMMUCONFIG
PMMU_CONFIG:	ErrorHandler	OLD_PMMUCONFIG,PC_MESSAGE,PC_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_PMMUILLEGAL
PMMU_ILLEGAL:	ErrorHandler	OLD_PMMUILLEGAL,PI_MESSAGE,PI_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_PMMUACCESS
PMMU_ACCESS:	ErrorHandler	OLD_PMMUACCESS,PA_MESSAGE,PA_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_FORMAT
FORMAT: 		ErrorHandler	OLD_FORMAT,FO_MESSAGE,FO_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_INTERRUPT
INTERRUPT:		ErrorHandler	OLD_INTERRUPT,IN_MESSAGE,IN_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_SPURIOUS
SPURIOUS:		ErrorHandler	OLD_SPURIOUS,SI_MESSAGE,SI_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_CPPROTOCOL
CP_PROTOCOL:	ErrorHandler	OLD_CPPROTOCOL,CP_MESSAGE,CP_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_PRIVILEG
PRIVILEG:ORI	    #$700,SR
		BTST	    #4,PR_FLAG+1
		BEQ.S	    KEIN_DISASS

*---------------

		MOVEM.L     D0-D1/A0/A3,-(SP)  ; den MOVE SR,<ea>
		MOVEA.L     18(SP),A3
		MOVE.W	    (A3),D1
		MOVE.W	    #$FFC0,D0
		AND.W	    D1,D0
		CMP.W	    #$40C0,D0
		BNE.S	    KEIN_MOVE_SR
		JSR	    DisassemLength
		ADD.L	    D0,18(SP)

		MOVE.W	   16(SP),PRIVILEG_SR ; SR mal retten
		LEA	    SR_ROUTINE(PC),A0
		AND.W	    #%111111,D1 	  ; Register/Mode vertauschen
		ROR.W	    #7,D1
		MOVE.W	    D1,-(SP)
		ANDI.W	    #%111000000000,(SP)
		LSR.W	    #6,D1
		AND.W	    #%111000000,D1
		OR.W	    (SP)+,D1
		OR.W	    #$303A,D1
		MOVE.W	    D1,(A0)+		  ; MOVE SAVE_SR(PC),<ea>
		LEA	    PRIVILEG_SR,A1
		SUBA.L	    A0,A1
		MOVE.W	    A1,(A0)+		  ; Base Displacement schreiben
		SUBQ.W	    #3,D0
		BMI.S	    ONLY_TWO
		ADDQ.W	    #2,A3
COPY_SR:	MOVE.B	    (A3)+,(A0)+
		DBRA	    D0,COPY_SR
ONLY_TWO:	MOVE.W	    #$4EF9,(A0)+	  ; JMP
		MOVE.L	    18(SP),(A0) 	  ; Sprung nach ...
		MOVEM.L     (SP)+,D0-D1/A0/A3
				jsr			FlushCache
		MOVE.L	    #SR_ROUTINE,2(SP)
		RTE				  ; Routine ausfÅhren

*---------------

KEIN_MOVE_SR:	MOVEM.L     (SP)+,D0-D1/A0/A3
		BRA.S	    KEINE_KORREKTUR

*---------------

KEIN_DISASS:	BTST	    #5,PR_FLAG+1
		BEQ.S	    KEINE_KORREKTUR
		MOVEM.L     D0/A0,-(SP) 	  ; den MOVE SR,<ea> in ein
		MOVEA.L     10(SP),A0		  ; MOVE CCR,<ea> wandeln
		MOVE.W	    #$FFC0,D0
		AND.W	    (A0),D0
		CMP.W	    #$40C0,D0
		BNE.S	    KEIN_BSET
		BSET	    #1,(A0)
				jsr			FlushCache
		MOVEM.L     (SP)+,D0/A0
		RTE
KEIN_BSET:	MOVEM.L     (SP)+,D0/A0

KEINE_KORREKTUR:ErrorHandler	OLD_PRIVILEG,PR_MESSAGE,PR_FLAG

*-------------------------------------------------------------------------------

				XBRA			OLD_FPCP_1
FPCP_1: 		ErrorHandler	OLD_FPCP_1,C1_MESSAGE,C1_FLAG

				XBRA			OLD_FPCP_2
FPCP_2: 		ErrorHandler	OLD_FPCP_2,C2_MESSAGE,C2_FLAG

				XBRA			OLD_FPCP_3
FPCP_3: 		ErrorHandler	OLD_FPCP_3,C3_MESSAGE,C3_FLAG

				XBRA			OLD_FPCP_4
FPCP_4: 		ErrorHandler	OLD_FPCP_4,C4_MESSAGE,C4_FLAG

				XBRA			OLD_FPCP_5
FPCP_5: 		ErrorHandler	OLD_FPCP_5,C5_MESSAGE,C5_FLAG

				XBRA			OLD_FPCP_6
FPCP_6: 		ErrorHandler	OLD_FPCP_6,C6_MESSAGE,C6_FLAG

				XBRA			OLD_FPCP_7
FPCP_7: 		ErrorHandler	OLD_FPCP_7,C7_MESSAGE,C7_FLAG

*-------------------------------------------------------------------------------

				XBRA		OLD_TRAP0
TRAP_0: 		TrapHandler	OLD_TRAP0,T0_FLAG

				XBRA		OLD_TRAP3
TRAP_3: 		TrapHandler	OLD_TRAP3,T3_FLAG

				XBRA		OLD_TRAP4
TRAP_4: 		TrapHandler	OLD_TRAP4,T4_FLAG

				XBRA		OLD_TRAP5
TRAP_5: 		TrapHandler	OLD_TRAP5,T5_FLAG

				XBRA		OLD_TRAP6
TRAP_6: 		TrapHandler	OLD_TRAP6,T6_FLAG

				XBRA		OLD_TRAP7
TRAP_7: 		TrapHandler	OLD_TRAP7,T7_FLAG

				XBRA		OLD_TRAP8
TRAP_8: 		TrapHandler	OLD_TRAP8,T8_FLAG

				XBRA		OLD_TRAP9
TRAP_9: 		TrapHandler	OLD_TRAP9,T9_FLAG

				XBRA		OLD_TRAPA
TRAP_A: 		TrapHandler	OLD_TRAPA,TA_FLAG

				XBRA		OLD_TRAPB
TRAP_B: 		TrapHandler	OLD_TRAPB,TB_FLAG

				XBRA		OLD_TRAPC
TRAP_C: 		TrapHandler	OLD_TRAPC,TC_FLAG

				XBRA		OLD_TRAPF
TRAP_F: 		TrapHandler	OLD_TRAPF,TF_FLAG

*---------------

TRAP_HANDLER:	btst		#0,(sp)+
				bne.s		.zeigen
				btst		#1,-2(sp)
				bne.s		.korrigieren
				rts
.korrigieren:	addq.w		#4,sp
				btst		#7,(sp)
				bne			TRACE
				rte
.zeigen:		addq.w		#4,sp
TOS_STOP:		subq.l		#2,2(sp)
				bsr			GOTO_DEBUGGER
				movea.l		SAVE_PC,a0
				moveq		#$f,d0
				and.w		(a0),d0
				move.l		d0,FEHLER_ADRESSEN
				move.l		a0,FEHLER_ADRESSEN+4
				PrintError	TP_MESSAGE
				jmp			EDITOR

*-------------------------------------------------------------------------------

ERROR_HANDLER:	btst		#0,(sp)
				bne.s		.zeigen
				btst		#1,(sp)+
				bne.s		.korrigieren
				addq.w		#4,sp
				rts

.korrigieren:	movem.l		d0/a3,-(sp)
				movea.l		12(sp),a3
				tst.b		-1(a3)
				beq.s		.pc_ok_1
				movea.l		22(sp),a3
				jsr			DisassemLength
				add.l		d0,22(sp)
.pc_ok_1:		movem.l		(sp)+,d0/a3
				addq.w		#8,sp
				btst		#7,(sp)
				bne			TRACE
				rte
.zeigen: 		addq.w		#2,sp
				move.l		(sp)+,ERROR_MESSAGE
				addq.w		#4,sp
				bsr			GOTO_DEBUGGER
				movea.l		ERROR_MESSAGE,a3
				tst.b		-1(a3)
				bne.s		.pc_ok_2
				movea.l		SAVE_PC,a3
				bsr			SearchUp
				beq.s		.pc_ok_2
				move.l		a3,SAVE_PC
.pc_ok_2:		movea.l		ERROR_MESSAGE,a3
				move.l		SAVE_PC,FEHLER_ADRESSEN
				bsr			PRINT_ERROR
				bsr			ListPC
				jmp			EDITOR

*-------------------------------------------------------------------------------

SLOWMOTION:	TST.B	    SLOW_MODE
		BEQ.S	    NO_SLOWMOTION
		MOVE.L	    D0,-(SP)
		MOVE.L	    SLOW_ADD,D0
		ADD.L	    D0,SLOW_COUNTER
		MOVE.L	    SLOW_COUNTER,-(SP)
		BEQ.S	    COUNTER_ZERO
SLOW_LOOP:	CMP.L	    SLOW_ADD,D0
		BNE.S	    COUNTER_ZERO
		SUBQ.L	    #1,(SP)
		BPL.S	    SLOW_LOOP
COUNTER_ZERO:	ADDQ.W	    #4,SP
		MOVE.L	    (SP)+,D0
NO_SLOWMOTION:	RTS

*-------------------------------------------------------------------------------
* INTERFACE
* r = read
* w = write
* p = patch
* n = new screen
* l = lock screen
* * = reserved
*-------------------------------------------------------------------------------

					dc.l	CHEAT_ON			; -24
					dc.l	CHEAT_OFF			; -20
					dc.l	CHEAT_TEST			; -16
SAVE_OVER_PC:		dc.l	0					; -12
SAVE_OVER_SR:		dc.w	0					; -8
					dc.l	CALL_SYSMON			; -6
RESIDENT:			dc.b	0					; -2
					dc.b	0					; -1

COOKIE_RECORD:		dc.l	CLEAR_SCREEN		; r/l
					dc.l	GET_PARAMETER		; r/l
					dc.l	KILL_SCREEN			; r/l
					dc.l	NEW_SCREEN			; r/l
					dc.l	NEW_FORMAT			; r/l
					dc.l	PRINT_SCREEN		; r/l
					dc.l	SCREEN_PARAMETER	; r
					dc.l	CALL_DEBUGGER_1		; r
					dc.l	VERSION				; r
					dc.l	PARAMETER			; r
USERTRACE:			dc.l	USER_TRACE			; r/w
USERENTER:			dc.l	USER_ENTER			; r/w
USERQUIT:			dc.l	USER_QUIT			; r/w
USERSWITCH_1:		dc.l	USER_SWITCH_1		; r/w
USERSWITCH_2:		dc.l	USER_SWITCH_2		; r/w
USERRESET:			dc.l	USER_RESET			; r/w
					dc.l	FLAGS				; r
					dc.l	TrapVektor			; r
					dc.l	CALL_DEBUGGER_2		; r
					dc.l	TRACE_WITHOUT
					dc.l	TRACE_WITH
					dc.l	TRACE_ALWAYS

*-------------------------------------------------------------------------------

SCREEN_PARAMETER:

BILDSCHIRM_MALLOC:	dc.l	0					; r/w/n/l Bildspeicher
BILDSCHIRM_ADRESSE:	dc.l	0					; r/w/n/l Bildschirmadresse
ZEICHEN_ADRESSE:	dc.l	0					; r/w/n/l Zeichenscreen
MAUS_PUFFER:		dc.l	0					; r/w/n/l Maushintergrund
					dc.l	0,0,0,0				*
FONT_16:			dc.l	FONT_16_8			; r/w/n/l Zeiger auf 8*16 Font
FONT_8: 			dc.l	FONT_8_8			; r/w/n/l Zeiger auf 8*8 Font
FONT_FLAG:			dc.w	4					; r/w/p/n/l 3=8*8, 4=16*8

* nach diesen Variablen werden alle Bildparameter berechnet r/w/n/l
OFFSET_X:			dc.w	0					; Abstand in Zeichen
OFFSET_Y:			dc.w	0					; Abstand in Pixel
BILD_BREITE:		dc.w	0					; Bildbreite in Zeichen
ZEILEN_LAENGE:		dc.w	0					; tatsÑchliche ZeilenlÑnge
BILD_HOEHE:		 	dc.w	0					; Bildhîhe in Pixel
SCREEN_BREITE:		dc.w	0					; Screenbreite in Bytes
SCREEN_HOEHE:		dc.w	0					; Screenhîhe in Pixel
PLANES: 			dc.w	0					; Anzahl Bitplanes

* LÑngenvorgaben fÅr die diversen Puffer r/w/p/n/l
_BILDSCHIRM_LENGTH:	dc.l	0					; LÑnge Bildschirm
_ZEICHEN_LENGTH:	dc.l	0					; LÑnge Zeichenscreens
_MAUS_LENGTH:		dc.l	0					; LÑnge Mauspuffer
					dc.l	0,0,0,0				*

* Vorgaben fÅr die Bildschirmdarstellung r/w/p/n/l
_OFFSET_X:			dc.w	0					; Abstand in Zeichen
_OFFSET_Y:			dc.w	0					; Abstand in Pixel
_BILD_BREITE:		dc.w	0					; Bildbreite in Zeichen
_BILD_HOEHE:		dc.w	0					; Bildhîhe in Pixel
_PLANES:			dc.w	0					; Anzahl Bitplanes
					dc.w	0,0,0				*

SCREEN_LOCK:		dc.b	0					; r/w/l

SWITCH_PALETTE: 	dc.b	-1					; r/w/p/l

* und hier noch die Farbpalette
OWN_PALETTE:	.REPT 128
					dc.w	$0FFF,$0000			; r/w/p/l
				.ENDM

SWITCH_REGISTER: 	dc.b	-1					; r/w/p/l
		.EVEN

*-------------------------------------------------------------------------------

PARAMETER:

KEY_CODE_1:			dc.b	68					; r/w/p
SWITCH_CODE_1:		dc.b	8					; r/w/p
KEY_CODE_2:			dc.b	68					; r/w/p
SWITCH_CODE_2:		dc.b	12					; r/w/p
					dc.b	0,0,0,0,0,0,0,0		*

MAUS_PARAMETER: 	dc.w	0					; r/w/p
					dc.w	2					; r/w/p
					dc.w	4					; r/w/p
					dc.w	8					; r/w/p
					dc.w	64					; r/w/p
					dc.w	256					; r/w/p

ZAHLEN_BASIS:		dc.w	16					; r/w/p

PRIORITAETEN:									; r/w/p
					dc.w	10					; +  Addition 0
					dc.w	10					; -  Subtraktion 2
					dc.w	15					; *  Mulu 4
					dc.w	15					; /  Divu 6
					dc.w	10					; |  Odern 8
					dc.w	15					; &  Anden 10
					dc.w	15					; ^  Eoren 12
					dc.w	15					; <> Shiften 14
					dc.w	20					; ~  1er Komplement 16
					dc.w	20					; -  2er Komplement 18
					dc.w	15					; %  Modulo
					dc.w	20					; p  Pointer 22
					dc.w	0					; (  Klammer 24
					dc.w	0,0,0,0,0			*

KEY_REPEAT:			dc.l	3					; r/w/p
KEY_DELAY:			dc.l	60					; r/w/p
MOUSE_REPEAT:		dc.l	5					; r/w/p
MOUSE_DELAY:		dc.l	100					; r/w/p
DOPPEL_KLICK:		dc.l	50					; r/w/p

PRINTER_TIMEOUT:	dc.l	400					; r/w/p
RS232_TIMEOUT:		dc.l	400					; r/w/p
MIDI_TIMEOUT:		dc.l	400					; r/w/p
					dc.l	0,0,0,0,0,0			*

					dc.l	NEW_HISTORY			; r
HISTORY_POINTER:	dc.l	0					; r
HISTORY_LENGTH: 	dc.l	2080				; r/p
HISTORY_READ:		dc.l	0					*
HISTORY_WRITE:		dc.l	0					*

					dc.l	CACHE_INIT			; r
CACHE_LENGTH:		dc.w	CACHE_LAENGE		; r
CACHE_POINTER_1:	dc.l	0					*
CACHE_LAENGE_1: 	dc.w	20					; r/p
CACHE_POINTER_2:	dc.l	0					*
CACHE_LAENGE_2: 	dc.w	5					; r/p

INSERT_FLAG:		dc.b	-1					; r/w/p
					ds.b	1					; reserved
SYMBOL_FLAG:		dc.b	-1					; r/w/p

*-------------------------------------------------------------------------------

CHEAT_MODE:			dc.b	0

FLAGS:						  					; r/w/p

BU_FLAG:			dc.b	-1,	%1				; Buserror
AD_FLAG:			dc.b	-1,	%1				; Adress_error
IL_FLAG:			dc.b	!debug,%1			; Illegal
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

*-------------------------------------------------------------------------------

PRG_FLAGS:			dc.l	-1

*------------------------------------------------------------------------------

RW_TRACK:			dc.w	0
RW_SECTOR:			dc.w	1
RW_SIDE:			dc.w	0
RW_ADRESSE:			dc.l	SEKTOR_PUFFER
RW_DEVICE:			dc.w	0

*------------------------------------------------------------------------------

FIRST_LINE:			dc.w	5

*-------------------------------------------------------------------------------

OPCODE_OVER:	dc.w		0
				bra			BACK_OVER

SAVE_EXCEPT_PC: 	dc.l 0			  ; Trace Exception
SAVE_EXCEPT_SR: 	dc.w 0			  ; Trace Exception
JUMPTO_EXCEPT:		dc.l 0			  ; Trace Exception

*-------------------------------------------------------------------------------

SR_ROUTINE:		ds.b		20
				jmp			12345678
PRIVILEG_SR:	ds.w		1

*-------------------------------------------------------------------------------

AES_PB: 		dc.l		CONTROL,GLOBAL,GINTIN,GINTOUT,ADDRIN,ADDROUT

DEVICE: 		dc.w		2				; aktuelles Device

ANZAHL_ZEILEN:	dc.l		LINES_NUMBER	; fÅr List, Load, Lexecute

LIST_FLAG:		dc.b		-1
;-1 = List
; 0 = Disassemble
; 1 = Dump
; 2 = Ascii
		.EVEN

STATUS:			dc.w $500

TRACE_ZAEHLER:		dc.l 1

CLEAR_ZERO:         ds.w 8			  ; einfach leer!
CLEAR_SPACE:		dc.l $20202020,$20202020,$20202020,$20202020	  ; einfach leer!
					dc.l $20202020,$20202020,$20202020,$20202020

* erlaubte Devices bei der Ausgabenumlenkung, wird vom Parser benutzt
DEVICE_KENNUNG: dc.b		'PRN:',0,'AUX:',0,'CON:',0,'MIDI:',0

* fÅr Printerausgabe
CRLF:			dc.b		13,10

* erlaubte Zeichen beim Kopieren mit der Maus
CHARS_1:		dc.b		'ABCDEFO0123456789$%.',0
CHARS_2:		dc.b		'GHIJKLMNPQRSTUVWXYZ,-()[]*#/{}_:'
CHARS_3:		dc.b		'ABCDEFGHIJKLMNOPQRSTUVWXYZo0123456789$%.?_~@',0
		.EVEN

*-------------------------------------------------------------------------------

* Commandline, wird beim Installieren gefÅllt und dann gleich ausgewertet

COMMAND_LINE:		dc.b 'lex '
COMMAND_DATA:		ds.b 127
COMMAND_LENGTH: 	dc.b 0
			EVEN

*-------------------------------------------------------------------------------

* fÅr Uhr
TIME_PRINT:		dc.b '00:00:00'
			EVEN

*-------------------------------------------------------------------------------

RELOC_TABELLE:		ds.b 4*1024

*-------------------------------------------------------------------------------

* Programmstart-, Basepageinformationen, muss im Datensegment liegen

ProgrammStart:		ds.l	1						; Programmstart=Basepage
ProgrammLength:		ds.l	1
ProgrammEnde:		ds.l	1						; erstes unbenutztes Byte
TextSegStart:		ds.l	1						; Textsegment
TextSegLength:		ds.l	1
DataSegStart:		ds.l	1						; Datasegment
DataSegLength:		ds.l	1
BssSegStart:		ds.l	1						; BssSegment
BssSegLength:		ds.l	1
_app:				ds.b	1						; 0=Accessory, -1=Programm
		.EVEN

*-------------------------------------------------------------------------------

FONT_16_8:		dc.l		395531,218695264,-1867460464,1610612736,24,1013367681,-417061852,1006632960
				dc.l		60,606348519,-2117900740,402653184,12344,753304451,-433309648,0
				dc.l		3100,879215041,1731468300,0,31800,-1164781882,-695027144,2080374784
				dc.l		65278,-16974600,-84740378,-301989888,61126,-695027144,-1164781882,-301989888
				dc.l		257,50529798,-1936926632,1882202112,60,1724092817,-1652440218,1006632960
				dc.l		0,406600764,1010597631,272109568,2062,252250120,2029547520,0
				dc.l		30784,1883258880,504372240,268435456,14400,1077950464,470948884,301989888
				dc.l		328965,84741405,964260209,1631649792,10526880,-1599033160,-1667330418,-2038300672
				dc.l		8174278,-960069120,-2100902202,-1166278656,518,101057024,33949190,33554432
				dc.l		8141318,101071484,-1195327296,-1199833088,8141318,101071484,973473286,981204992
				dc.l		33478,-960054660,973473286,33554432,8173760,-1061111684,973473286,981204992
				dc.l		8173760,-1061111684,-1161378106,-1166278656,8174278,-960069120,33949190,33554432
				dc.l		8174278,-960054660,-1161378106,-1166278656,8174278,-960054660,973473286,981204992
				dc.l		0,8158726,108947046,2117861376,30784,1883273216,235932674,469762048
				dc.l		0,0,118431512,403709463,0,0,-252122108,67386452
				dc.l		285936902,120469816,0,0,64764,-50339359,-505339615,1056964608
				dc.l		0,0,0,0,0,406600764,404226072,402653184
				dc.l		102,1717969920,0,0,0,1819082348,1819082348,1811939328
				dc.l		6168,2093400768,2080802502,2081953792,0,49862,202911846,-973078528
				dc.l		0,946629688,1994181836,1979711488,48,808476672,0,0
				dc.l		0,202911792,808464408,201326592,0,806882316,202116120,805306368
				dc.l		0,26172,-12818944,0,0,6168,2115508224,0
				dc.l		0,0,6168,405798912,0,0,2113929216,0
				dc.l		0,0,24,402653184,0,33950744,811647104,0
				dc.l		0,2093403870,-152647994,2080374784,0,812707888,808464432,-67108864
				dc.l		0,2093352460,405823686,-33554432,0,2093352454,1007027910,2080374784
				dc.l		0,203177068,-855766004,503316480,0,-20922176,-66713914,2080374784
				dc.l		0,945864896,-54081850,2080374784,0,-20543988,404232216,402653184
				dc.l		0,2093401798,2093401798,2080374784,0,2093401798,2114323980,2013265920
				dc.l		0,1579008,6168,0,0,1579008,6168,805306368
				dc.l		0,101455920,1613764620,100663296,0,32256,32256,0
				dc.l		0,1613764620,101455920,1610612736,0,2093401612,404226072,402653184
				dc.l		14460,-423437610,-690175774,2117861376,0,272133318,-956381498,-973078528
				dc.l		0,-60397978,2087085670,-67108864,0,1013367488,-1061109146,1006632960
				dc.l		0,-127113626,1717986924,-134217728,0,-26844568,2020106854,-33554432
				dc.l		0,-26844568,2020106336,-268435456,0,1013367488,-1059142042,973078528
				dc.l		0,-960051514,-20527418,-973078528,0,1008211992,404232216,1006632960
				dc.l		0,504105996,202165452,2013265920,0,-429495188,2020371558,-436207616
				dc.l		0,-262119328,1616929382,-33554432,0,-957415682,-691616058,-973078528
				dc.l		0,-957942050,-825833786,-973078528,0,946652870,-960051604,939524096
				dc.l		0,-60397978,2086690912,-268435456,0,946652870,-958996868,202244096
				dc.l		0,-60397978,2087478886,-436207616,0,2093401696,940361414,2080374784
				dc.l		0,2122209816,404232216,1006632960,0,-960051514,-960051514,2080374784
				dc.l		0,-960051514,-960074696,268435456,0,-960051514,-690553220,1811939328
				dc.l		0,-960074696,943221958,-973078528,0,1717986918,1008211992,1006632960
				dc.l		0,-20542440,811647686,-33554432,0,1010577456,808464444,1006632960
				dc.l		0,-2134843280,941362694,33554432,0,1010568204,202116156,1006632960
				dc.l		4152,1824915456,0,0,0,0,0,65024
				dc.l		48,806879232,0,0,0,120,209505484,1979711488
				dc.l		0,-530554756,1717986918,2080374784,0,124,-960446266,2080374784
				dc.l		0,470551676,-858993460,1979711488,0,124,-956383034,2080374784
				dc.l		0,473313840,2083532848,2013265920,0,118,-858993540,214726656
				dc.l		0,-530554772,1986422374,-436207616,0,404226104,404232216,1006632960
				dc.l		0,789504,202116108,-859015168,0,-530554778,1819831398,-436207616
				dc.l		0,941103128,404232216,1006632960,0,236,-19474730,-704643072
				dc.l		0,220,1717986918,1711276032,0,124,-960051514,2080374784
				dc.l		0,220,1717986940,1616965632,0,118,-858993540,202120704
				dc.l		0,220,1986420832,-268435456,0,124,-965735226,2080374784
				dc.l		0,271593724,808464438,469762048,0,204,-858993460,1979711488
				dc.l		0,102,1717986876,402653184,0,198,-958998786,1811939328
				dc.l		0,198,1815623788,-973078528,0,198,-960051586,101480448
				dc.l		0,254,-870829978,-33554432,0,236460056,1880627224,234881024
				dc.l		0,404232216,1579032,402653184,0,1880627224,236460056,1879048192
				dc.l		0,1994129408,0,0,0,1579068,610681539,-16777216
				dc.l		0,1013367488,-1061001668,404238336,0,-859045684,-858993460,1979711488
				dc.l		12,405799036,-956383034,2080374784,16,946602104,209505484,1979711488
				dc.l		0,-859045768,209505484,1979711488,96,806879352,209505484,1979711488
				dc.l		56,1815609464,209505484,1979711488,0,15462,1617312780,104595456
				dc.l		16,946602108,-956383034,2080374784,0,-859045764,-956383034,2080374784
				dc.l		96,806879356,-956383034,2080374784,0,1717960760,404232216,1006632960
				dc.l		24,1013317688,404232216,1006632960,96,806879288,404232216,1006632960
				dc.l		198,-972015508,-960037178,-973078528,14444,939538540,-960037178,-973078528
				dc.l		3096,805371494,1618763878,-33554432,0,31926,914151640,1845493760
				dc.l		0,1048107224,-19343144,-570425344,16,946602108,-960051514,2080374784
				dc.l		0,-960102276,-960051514,2080374784,96,806879356,-960051514,2080374784
				dc.l		48,2026635468,-858993460,1979711488,96,806879436,-858993460,1979711488
				dc.l		0,-960102202,-960051586,101480448,198,-969380666,-960051604,939524096
				dc.l		198,-973027642,-960051514,2080374784,24,406611552,1617312792,402653184
				dc.l		56,1818517744,1616928998,-67108864,0,1717976088,410916888,402653184
				dc.l		0,8177350,-54081796,-1061142528,14,454563864,2115508248,416837632
				dc.l		24,811597944,209505484,1979711488,12,405798968,404232216,1006632960
				dc.l		24,811597948,-960051514,2080374784,24,811598028,-858993460,1979711488
				dc.l		25852,-1744830244,1717986918,1711276032,30428,13035254,-18952506,-973078528
				dc.l		16,946602104,209505484,1979776512,0,124,-960051514,2080439808
				dc.l		0,808452144,811648710,2080374784,0,0,2120245344,0
				dc.l		0,0,2114323974,0,192,-1060713256,811654278,202915328
				dc.l		192,-1060713256,812043930,1040582144,0,404226072,406600764,402653184
				dc.l		0,13932,-663996928,0,0,55404,913102848,0
				dc.l		25852,-1744830344,209505484,1979711488,25852,-1744830340,-960051514,2080374784
				dc.l		81278,1179011658,1381130850,2126282752,0,20792902,1314550370,1656520704
				dc.l		0,8322963,-1818324848,-8454144,31996,-1869570916,-1869574000,-58982400
				dc.l		1613764608,1063020,-960037178,-960102400,6616216,1063020,-960037178,-960102400
				dc.l		6616216,3697862,-960051514,1815609344,6710784,0,0,0
				dc.l		396312,0,0,0,1080336,269488144,0,0
				dc.l		31434,-892679478,2047478282,168427520,31942,-2101697886,-1564835130,2080374784
				dc.l		31942,-2101695822,-1163230522,2080374784,-245670059,1358954496,0,0
				dc.l		6710784,-429496730,1717986918,-166839240,-151624090,1717986918,1717987062,-166822792
				dc.l		26230,1983790140,1852728930,0,31868,202116108,202145406,0
				dc.l		7710,101060126,909522486,0,32382,202116108,202116108,0
				dc.l		32382,107374182,1717986918,0,14392,404232216,404232216,0
				dc.l		7710,67898380,202116100,0,32382,1717986918,1717986918,0
				dc.l		28270,1717986918,1717993086,0,15420,202113024,0,0
				dc.l		15422,101058054,101072444,0,1616936574,101058062,472920112,0
				dc.l		27758,1043752550,1718513262,0,7196,202116108,202144892,0
				dc.l		65278,-20527418,-960037252,0,13878,909522486,909540990,0
				dc.l		32382,1717991030,108953214,0,28270,1714830872,470711934,0
				dc.l		15934,1040582198,909522486,808464384,31870,101058054,101058054,0
				dc.l		54998,-690555146,-960037122,0,32382,1717986918,1718019814,0
				dc.l		14392,404232216,404232216,404226048,32382,101058054,101058054,101056512
				dc.l		32318,909522486,909524542,0,32382,1717991030,101058054,101056512
				dc.l		28270,1719025166,101058054,101056512,7222,840449126,1715214412,1815609344
				dc.l		0,1052728,946629830,-973078528,0,1727502745,-278528000,0
				dc.l		0,118,-589768484,1979711488,0,31942,-54081796,-1061142528
				dc.l		0,-20527424,-1061109568,-1073741824,0,7273596,1819044972,1811939328
				dc.l		0,-20553680,405823686,-33554432,0,32472,-656877352,1879048192
				dc.l		0,26214,1717992544,1623195648,0,30428,404232216,402653184
				dc.l		0,2115517542,1717986876,410910720,0,946652870,-20527508,939524096
				dc.l		0,946652870,-965972884,-301989888,0,506468364,1046898278,1006632960
				dc.l		0,126,-606372352,0,0,50757339,-604799392,-1073741824
				dc.l		0,472932448,2086690864,469762048,0,8177350,-960051514,-973078528
				dc.l		0,8257536,2113929342,0,0,1579134,404226048,-16777216
				dc.l		0,806882310,202911744,2113929216,0,202911840,806882304,2113929216
				dc.l		0,236657432,404232216,404232216,404232216,404232216,404281560,1879048192
				dc.l		0,1579008,2113935384,0,0,30428,7789568,0
				dc.l		14444,1147942912,0,0,14460,2088515584,0,0
				dc.l		0,0,404226048,0,15,202116108,-328451044,0
				dc.l		216,1819044972,1811939328,0,112,-667918136,-134217728,0
				dc.l		0,8158332,2088532992,0,-16908288,0,0,0

*-------------------------------------------------------------------------------

FONT_8_8:		dc.l		101255430,1620086880,405029505,-417061828,1009001703,-2126371816,404025985,-2114841576
				dc.l		405294977,-2125518824,1016710119,-1013367808,-260,-101456128,-406611652,-1715214592
				dc.l		66052,-2008014848,2088931986,-1702722948,405021732,2114988048,403968528,275837024
				dc.l		-259981680,-1676668928,1887476882,2081690112,84215053,219773297,-1600085840,-1332175218
				dc.l		1010975232,1111636992,33686016,33686016,1006764604,1077951488,1006764604,33700864
				dc.l		1111638588,33686016,1010843708,33700864,1010843708,1111636992,1006764544,33686016
				dc.l		1010975292,1111636992,1010975292,33700864,15362,2118269952,2017488960,2114981376
				dc.l		117970712,403709463,-266802172,67386452,285936902,120469816,69785640,-804200448
				dc.l		0,0,269488144,268439552,1145324544,0,4783176,1224493056
				dc.l		138297404,41682944,4326408,270549504,810045472,1414018048,269488128,0
				dc.l		67635208,134743040,268961800,134746112,2365566,405012480,1052796,269484032
				dc.l		0,1052704,124,0,0,1052672,132104,270548992
				dc.l		944000084,1682192384,271585296,269515776,943981576,270564352,2080903176,71579648
				dc.l		135800904,2080901120,2084599812,71579648,943734904,1145321472,2080638992,538976256
				dc.l		943998008,1145321472,943998012,67645440,1052672,269484032,1052672,269492224
				dc.l		67637280,268960768,31744,8126464,537921540,135274496,943981576,268439552
				dc.l		944004180,1547713536,271074372,2084848640,2017739896,1145337856,943996992,1078212608
				dc.l		1883784260,1145597952,2084585592,1077967872,2084585592,1077952512,1010843724,1145322496
				dc.l		1145324668,1145324544,940576784,269498368,67372036,71579648,1145589856,1346913280
				dc.l		1077952576,1077967872,1145334892,1414808576,1145332820,1279542272,943998020,1145321472
				dc.l		2017739896,1077952512,943998020,1414018048,2017739896,1346913280,943996984,71579648
				dc.l		2081427472,269488128,1145324612,1145322496,1145324612,1143476224,1145324612,1416381440
				dc.l		1145317392,675562496,1145324584,269488128,2080638992,541096960,470814736,269491200
				dc.l		1075843080,67239936,940050440,134756352,271074434,0,0,65024
				dc.l		4202512,0,14340,1011104768,1077966916,1145337856,14400,1077950464
				dc.l		67386436,1145322496,14404,2084584448,202390544,269488144,15428,1144783992
				dc.l		1077966916,1145324544,268447760,269498368,268439568,269488224,1077953608,1883784192
				dc.l		806359056,269498368,26708,1414812672,30788,1145324544,14404,1145321472
				dc.l		30788,1145337920,15428,1145322500,30788,1077952512,15424,939816960
				dc.l		1080336,269487104,17476,1145322496,17476,1143476224,17476,1416381440
				dc.l		17448,271074304,17476,1144783992,31752,270564352,202379296,269487104
				dc.l		269488144,269488144,805832708,134754304,6328844,0,1052712,675576832
				dc.l		943996992,1144522800,1140850756,1145322496,135266360,2084584448,271056952,75250688
				dc.l		1140865028,1011104768,268959800,75250688,404226104,75250688,7200,538707984
				dc.l		271056952,2084584448,1140865092,2084584448,537919544,2084584448,1140850736,269498368
				dc.l		271056944,269498368,537919536,269498368,1140854824,1148994560,271061032,1148994560
				dc.l		135298112,2017491968,31762,2127592960,1045467292,-258957824,271056952,1145321472
				dc.l		1140850744,1145321472,537919544,1145321472,271056964,1145322496,537919556,1145322496
				dc.l		1140868164,1144783992,1140865092,1145321472,1140868164,1145322496,134749216,538707976
				dc.l		405020792,538999808,1145317392,2081427456,943998040,1145329728,235944976,269492224
				dc.l		135266360,75250688,135266352,269498368,135266360,1145321472,135266372,1145322496
				dc.l		609747064,1145324544,609747044,1414284288,3671100,1144782972,3687492,1144520828
				dc.l		1048592,541082680,62,538976256,124,67372032,1111771156,709134350
				dc.l		1111771156,743742980,1048592,269488144,304367760,1210323456,-1874320366,608735232
				dc.l		609747000,75250688,609747000,1145321472,977554516,1415854144,276556,1415854144
				dc.l		27794,-1634701824,2123403420,-1869578752,537919504,675576900,609746960,675576900
				dc.l		609761348,1145324600,1140850688,0,135274496,0,1062928,269484032
				dc.l		2055899786,2047478282,1010998689,-1583529412,1011005861,-1180351940,-245672623,0
				dc.l		570450466,577896972,1914839586,577896972,6427196,1212547072,7866376,142344192
				dc.l		3933196,337903616,8128520,134742016,7865412,1145307136,1574920,134742016
				dc.l		1837060,67371008,8135716,606339072,1078740036,1148977152,3672064,0
				dc.l		3933188,71041024,540804100,67633152,4731972,1145831424,1574920,137887744
				dc.l		4071970,572260352,2368548,612106240,8143988,75235328,4989980,142344192
				dc.l		3933220,606347264,7342088,134742016,5526644,1148977152,3941412,610533376
				dc.l		1574920,134744064,3933188,67372032,8135716,607911936,3941428,67372032
				dc.l		2892820,201589760,405016616,336077848,1058884,-2113929216,6723993,1711276032
				dc.l		25236,-2003541504,405029976,1145337920,8266272,538976368,146516,336860200
				dc.l		-29220848,541261312,1976388,1145321472,18504,1212708480,146504,134744080
				dc.l		940587076,1144524856,3687548,1145321472,3687492,1143489536,471863336,1145321472
				dc.l		202389588,1412960352,1062996,1414805520,1044398206,1077952000,1010975298,1111638528
				dc.l		8126588,8126464,269515792,268467712,268960776,268467712,135274512,134249984
				dc.l		791058,269488144,269488144,-1869586432,1048700,1048576,3296256,843841536
				dc.l		810037248,0,813182976,0,0,404226048,3848,-1873797120
				dc.l		943998020,1140850688,405014544,1006632960,939792388,939524096,-33554432,0

*-------------------------------------------------------------------------------

ALL_FILES:		dc.b '*.*'
NULL_BYTE:		dc.b 0
		.EVEN

**********************	B S S  -  S E G M E N T  *******************************

		.BSS
SAVE_IT:
* FPU Register
FP_REGISTER:	ds.b		96			; Register FP0-FP7
SAVE_FPSR:		ds.l		1			; Status Register
SAVE_FPIAR:		ds.l		1			; Instruction Address Register
SAVE_FPCR:		ds.l		1			; Control Register
SAVE_FPU:

* ab hier nur 68040
SAVE_TC_40:		ds.w		1			; Translation Control Register
SAVE_URP:		ds.l		1			; User Root Pointer Register
SAVE_DTT1:		ds.l		1			; Data Transparent
SAVE_DTT0:		ds.l		1			; Translation Register 0/1
SAVE_ITT1:		ds.l		1			; Instruction Transparent
SAVE_ITT0:		ds.l		1			; Translation Register 0/1

* ab hier nur 68030
SAVE_TC_30:		ds.l		1			; Translation Control Register
SAVE_TT1:		ds.l		1			; Transparent Translation
SAVE_TT0:		ds.l		1			; Register 0/1
SAVE_CRP:		ds.l		2			; CPU Root Pointer Register

* ab hier 68030-68040
SAVE_MMUSR:		ds.w		1			; MMU Status Register
SAVE_SRP:		ds.l		2			; Supervisor Root Pointer
										; Register (40er nur 32 Bit)

* ab hier 68020-68040
SAVE_MSP:		ds.l		1			; Master Stack Pointer
SAVE_CACR:		ds.l		1			; Cache Control Register

* ab hier 68020-68030
SAVE_CAAR:		ds.l		1			; Cache Adress Register

* ab hier 68010-68040
SAVE_VBR:		ds.l		1			; Vektor Base Register
SAVE_DFC:		ds.l		1			; Destination Function Code
SAVE_SFC:		ds.l		1			; Source Function Code

* ab hier 68000-68040
SAVE_USP:		ds.l		1			; User Stack Pointer
SAVE_ISP:		ds.l		1			; Supervisor Stackpointer

SAVE_PC:		ds.l		1			; Program Counter
SAVE_STATUS:	ds.w		1			; Status Register

SAVE_REGISTER:
DATEN_REGISTER: ds.l		8			; D0-D7
ADRESS_REGISTER:ds.l		7			; A0-A6
SAVE_A7:		ds.l		1			; A7 - muss beim Tracen
										; nicht gesetzt werden!

*-------------------------------------------------------------------------------

FILE_ANFANG:		ds.l	1
FILE_LAENGE:		ds.l	1
FILE_TEXT:			ds.l	1
FILE_TEXT_LAENGE:	ds.l	1
FILE_DATA:			ds.l	1
FILE_DATA_LAENGE:	ds.l	1
FILE_BSS:			ds.l	1
FILE_BSS_LAENGE:	ds.l	1

*-------------------------------------------------------------------------------

SAVE_FLAGS:		ds.w		ANZAHL_VEKTOREN			; fÅr Movebefehl

*-------------------------------------------------------------------------------

CACHE_1_CHEAT:	ds.b		CACHE_LAENGE
CACHE_2_CHEAT:	ds.b		CACHE_LAENGE
HISTORY_CHEAT:	ds.b		MENUE_LENGTH
		.EVEN

*-------------------------------------------------------------------------------

* Parser
FIRST_ADRESS:	ds.l		1				; Adresse am Anfang der Zeile
COMMAND_FOUND:	ds.w		1				; gefundener Befehl
PRINT_NEW_LINE:								; keine neue Zeile printen und auch
				ds.b		1				; den Zeilenrest nicht lîschen
		.EVEN

save_D0_A2:		ds.l		2				; Intern
COMMAND_FLAG:	ds.b		1				; Befehl aufrufen? (Intern)
		.EVEN

*-------------------------------------------------------------------------------

FEHLER_ADRESSEN:ds.l		ANZAHL_ADRESSEN

BREAK_POINT:
GEMDOS_BREAKPT: ds.b		16
GEM_BREAKPT:	ds.b		16
BIOS_BREAKPT:	ds.b		16
XBIOS_BREAKPT:	ds.b		16
GO_BREAKPT:		ds.b		16
DO_BREAKPT:		ds.b		16
BREAKPOINTS:	ds.b		16*(ANZAHL_BREAKPOINTS+1)

MARKER: 		ds.l		10

TRACE_PC_1:		ds.l		1			; ZÑhlerbreakpoints tracen
TRACE_PC_2:		ds.l		1			; Anzahlbreakpoints tracen

CACHE_RETURN:	ds.l		1

*-------------------------------------------------------------------------------

SAVE_FOR_RESET: 		ds.l	16			; Register
SAVE_SR_RESET:			ds.w	1			; Statusregister
RESET_ZAEHLER:			ds.l	1

SAVE_SCREEN_RESET:		ds.l	1
SAVE_SHIFTMODE_RESET:	ds.w	1
SAVE_SYNCMODE_RESET:	ds.b	1
SAVE_LINEWID_RESET:		ds.b	1
SAVE_HSCROLL_RESET:		ds.b	1
SAVE_FALCON_REG_RESET:	ds.b	FALCONREGLENGTH
		.EVEN

SAVE_BUS_RESET: 		ds.l	1
SAVE_ADRESS_RESET:		ds.l	1

*-------------------------------------------------------------------------------

ILLEGAL_SR:		ds.w		1
SUPERVISOR:		ds.b		1			; in Supervisormodus schalten

OPCODE_PC:		ds.b		1			; PC zeigt auf Opcode?

TRACE_MODUS_1:	ds.b		1			; + ,- ,* , Anzahl, 68020
TRACE_MODUS_2:	ds.b		1			; not, to tos, except, rts
TRACE_MODUS_3:	ds.b		1			; Breakpoint tracen
TRACE_MODUS_4:	ds.b		1			; Trace 68020 ab zweiten Mal
TRACE_MODUS_5:	ds.b		1			; VBL soll Trace anschalten
STOP_TRACE:		ds.b		1			; Trace ausschalten
		.EVEN

*-------------------------------------------------------------------------------

INTERNER_ERROR: 	ds.l	1
INTERN_ISP:			ds.l	1
INTERN_PC:			ds.l	1
INTERN_STATUS:		ds.w	1
BUS_SSW:			ds.w	1
BUS_AA: 			ds.l	1
BUS_OPCODE:			ds.w	1
BUS_SR: 			ds.w	1
BUS_PC: 			ds.l	1
BUS_MESSAGE_1:		ds.l	1
BUS_MESSAGE_2:		ds.l	1

*-------------------------------------------------------------------------------

CPU:			ds.b		1
FPU:			ds.b		1
VDO:			ds.b		1
SND:			ds.b		1
MCH:			ds.b		1
MSTE:			ds.b		1
		.EVEN

*-------------------------------------------------------------------------------

SHOW_ANZAHL:	ds.w		1			; fÅr SHOWMEMORY
SHOW_RECORD:
		.REPT ANZAHL_SHOW
				ds.b		MENUE_LENGTH+2
		.ENDM
		.EVEN

SHOW_NUMBER:	ds.w		1			; wird gerade geprintet

SHOW_ZAEHLER:	ds.b		1			; PRINT_SHOW
SHOW_ACTIV:		ds.b		1			; fÅr Bus- und Adresserror

ADRESSEN_ZEILEN:ds.w		1			; Output
QUIT_WERT:		ds.w		1			; QUIT

*-------------------------------------------------------------------------------

OBSERVE_ADDRESS:		ds.l	1		; Observebefehl
OBSERVE_ADDRESS_CHANGED:ds.l	1
OBSERVE_ADDRESS_WHERE:	ds.l	1
OBSERVE_COUNT:			ds.w	1
OBSERVE_FOUND:			ds.b	1
OBSERVE_FLAG:			ds.b	1
OBSERVE_SAVE:			ds.b	1024
		.EVEN

*-------------------------------------------------------------------------------

* Variablen fÅr AES Aufrufe

CONTROL:		ds.w		5
GLOBAL: 		ds.w		15
GINTIN: 		ds.w		16
GINTOUT:		ds.w		7
ADDRIN: 		ds.l		2
ADDROUT:		ds.l		1

*-------------------------------------------------------------------------------

* Variablen fÅr den Bildschirmtreiber, werden aus SCREEN_PARAMETER berechnet

BILD_ADRESSE:		ds.l	1			; Anfang des Bildes
ZEILEN_SCREEN:		ds.w	1			; Zeilen pro Bild
ZEILEN_SCREEN_8_8:	ds.w	1			; Zeilen pro Bild 8*8
ZEICHEN_SCREEN: 	ds.w	1			; Zeichen pro Bild
ZEICHEN_SCREEN_8_8:	ds.w	1			; Zeichen pro Bild 8*8
BYTES_ZEILE:		ds.w	1			; Bytes pro Zeichenzeile = Rasterzeile*16/8
BILD_BREITE_:		ds.w	1			; Zeichen pro Zeile zum Printen-1
ABSTAND_X:			ds.l	1			; Abstand in Bytes von links
ABSTAND_Y:			ds.l	1			; Abstand in Bytes von oben
SCAN_LINES:			ds.w	1			; Anzahl Scanlines (8 oder 16)
X_POSITION:			ds.w	1			; aktuelle X-Position
Y_POSITION:			ds.w	1			; aktuelle Y-Position
FONT:				ds.l	1			; aktueller Font
PLANE_FLAG:			ds.b	1			; ungerade oder gerade Adresse
TRUECOLOR:			ds.b	1			; True Color Auflîsung?
DUMP_BREITE:		ds.w	1			; Anzahl Zeichen Hexdump
ASCII_BREITE:		ds.w	1			; Anzahl Zeichen Asciidump
SET_SHIFTMD_TT: 	ds.w	1			; Shift Mode Register TT
SET_SHIFTMD_ST: 	ds.b	1			; Shift Mode Register ST
SET_FALCON_REG: 	ds.b	FALCONREGLENGTH	; Register fÅr Falcon
			EVEN
TC_table:			ds.b	16*256

*-------------------------------------------------------------------------------

* Variablen fÅr den Tastaturtreiber
IOREC_IKBD:			ds.l	1			; Tastaturbuffer

ZAEHLER_1:			ds.l	1			; Key_repeat
ZAEHLER_2:			ds.l	1 		 	; Key_delay
KEY:				ds.b	1			; Scancode gedrÅckter Tasten
LAST_KEY:			ds.b	1			; zuletzt gedrÅckte Taste
ASCII_KEY:			ds.b	1			; Asciicode gedrÅckter Tasten

		.EVEN
UMSCHALT_TASTEN:						; muss gerade Adresse sein
SHIFTRECHTS_FLAG:	ds.b	1			; Diese
SHIFTLINKS_FLAG:	ds.b	1			; Flags
CAPSLOCK_FLAG:		ds.b	1			; mÅssen
CONTROL_FLAG:		ds.b	1			; immer
ALTERNATE_FLAG: 	ds.b	1			; beisammen sein!

KEY_IGNORE_IKBD:	ds.b	1			; Statuspaket unterwegs?
MAUS_PAKET_IKBD:	ds.b	1			; Paket wird gesendet?
MAUS_MESSAGE_IKBD:	ds.b	3			; Mauspaket

KEY_1:				ds.b	1			; Tastaturtreiber Intern
KEY_2:				ds.b	1			; zum Testen auf Einsprung
EVENT:				ds.b	1			; 0 = Key, -1 = Mausleft
		.EVEN

HZ_200_SPEICHER:	ds.l	1			; ZÑhler fÅr Uhr
IKBD_ZEIT:			ds.l	1
KIND_OF_CLOCK:		ds.b	1			; IKBD, Mega, TT?
CLOCK_PRINT:		ds.b	1			; Sekunde abgelaufen?
		.EVEN

SAVE_UMSCHALT:		ds.w	1
SAVE_ALTERNATE: 	ds.b	1
SAVE_CONTROL:		ds.b	1

*-------------------------------------------------------------------------------

* Variablen fÅr den Maustreiber
ZAEHLER_3:			ds.l	1			; Maus_repeat links
ZAEHLER_4:			ds.l	1			; Maus_delay links
ZAEHLER_5:			ds.l	1			; Maus_repeat rechts
ZAEHLER_6:			ds.l	1			; Maus_delay rechts
ZAEHLER_7:			ds.l	1			; Doppelklick links
UEBERTRAG_X:		ds.w	1			; fÅr Mausbeschleuniger
UEBERTRAG_Y:		ds.w	1			; fÅr Mausbeschleuniger
MAUS_X:	 			ds.w	1			; X-Position
MAUS_Y: 			ds.w	1			; Y-Position
MAUS_LEFT:			ds.w	1			; nur das obere Byte abfragen
MAUS_RIGHT:			ds.w	1			; MAUS_?+1 ist fÅr den Treiber
SAVE_MAUSPOS:		ds.l	3			; fÅr Showm und Hidem

MAUS_ON:			ds.b	1			; Maus an oder nicht?
* gibt nur an ob die Maus an ist oder nicht, wird auch vom Interrupt benutzt
MAUS_ZAEHLER:		ds.b	1
* <=0 --> Maus abschalten, >0 --> Maus anschalten
* Der Interrupt darf nur zeichnen falls Maus_zÑhler>0 und Maus_on=true
KILLED_MOUSE:		ds.b	1
* Die Maus wurde gekillt als sie an war
MAUS_GESPERRT:		ds.b	1
* Maus wird gerade gezeichnet
MAUSLEFT_FIRST: 	ds.b	1			; wird vom Editor gebraucht
MAUSRIGHT_FIRST:	ds.b	1			; wird vom Editor gebraucht
		.EVEN

*------------------------------------------------------------------------------

* diverser Stuff
PTERM_MESSAGE:		ds.l	1
PTERM_ADRESSE:		ds.l	1

SLOW_COUNTER:		ds.l	1			; fÅr Slowmotion
SLOW_ADD:			ds.l	1			; fÅr Slowmotion
COOKIE_ADRESSE: 	ds.l	1			; hier ist er eingetragen
HISTORY_LAST:		ds.l	1			; letzter Eintrag

KBSHIFT:			ds.l	1

PAGE_POINTER:		ds.l	1			; Zeiger auf die Doppelseite

OLD_PC: 			ds.l	1			; PRINT_LINE wegen inversem PC

HZ200_ZAEHLER:		ds.l	1

ERROR_MESSAGE:		ds.l	1			; Meldung fÅr Errorhandler

POSITION_FTASTE:	ds.l	3			;  NEW_FORMAT initialisiert

VEKTOR_OFFSET:		ds.w	1			; fÅr CREATE_FRAME

SECOND_LINE:							; ListPC/A3 printen erst
					ds.b	1			; ab der zweiten Linie

DEVICE_BUSY:		ds.b	1			; Timeout Deviceausgabe
INST_FAILED:		ds.b	1			; 0=geglÅckt, -1=failed
INVERS: 			ds.b	1			; Invers?
UNDERLINE:			ds.b	1			; Underlined?
HELL:				ds.b	1			; Helle Schrift?
CURSOR_ZAEHLER: 	ds.b	1			; Ist der Cursor an?
DEBUGGER_FLAG:		ds.b	1			; Debugger aktiv?
OPCODE: 			ds.b	1			; Opcode (-1) oder SR (0)?
AES_INSTALLED:		ds.b	1			; Aes schon installiert?
GDOS_INSTALLED: 	ds.b	1			; Gdos installiert?
KEEP_SCREEN:		ds.b	1
LOCAL_FLAG:			ds.b	1
SLOW_MODE:			ds.b	1
BreakFlag:			ds.b	1
SAVE_SYMBOLFLAG:	ds.b	1
TOGGLE_CHEAT:		ds.b	1
CHANGE_SR:			ds.b	1
DO_A_RESET:			ds.b	1
		.EVEN

*-------------------------------------------------------------------------------

FILE_STRING:	ds.b		MENUE_LENGTH+2			  ; Umlenkungsfile, Nullterminiert

*-------------------------------------------------------------------------------

FREE_REGISTER:	ds.l		15
FREE_USP:		ds.l		1
FREE_ISP:		ds.l		1
FREE_MSP:		ds.l		1
FREE_SR:		ds.w		1

ProgramIsFreed:	ds.b		1		; wird gerade ein Programm freigegeben?
ProgramRuns:	ds.b		1		; ist ein Programm geladen?
RESIDENT_FLAG:	ds.b		1		; Debugger resident?
ONLY_LEXE:		ds.b		1		; damit die Illegal Routine nicht alles neu printet
		.EVEN

*-------------------------------------------------------------------------------

ERROR_STRING:	ds.b		82

PrintPuffer:	ds.b		MENUE_LENGTH+2		; nur von Befehlen benutzbar!

SEKTOR_PUFFER:	ds.b		1024

*-------------------------------------------------------------------------------

				ds.b	1024
_STACK_OS:										; Stack fÅr OS-Aufrufe

*-------------------------------------------------------------------------------

				ds.b		256
_STACK_RESET:									; nur fÅr Resetroutine

*-------------------------------------------------------------------------------

				ds.b		1024
_STACK_INSTALL:									; nur zum Installieren

*-------------------------------------------------------------------------------

				ds.b		1024
_USER_MSP:										; MSP fÅr Userprogramm
				ds.b		1024
_USER_ISP:										; ISP fÅr Userprogramm
				ds.b		1024
_USER_USP:										; USP fÅr Userprogramm

*-------------------------------------------------------------------------------

				ds.b		1024
_STACK_MSP:										; MSP fÅr den Debugger
				ds.b		1024
_STACK_ISP:										; ISP fÅr den Debugger
				ds.b		1024
_STACK_USP:										; USP fÅr den Debugger
