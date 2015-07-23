*-------------------------------------------------------------------------------
* InstallCookie: Durchsucht den Cookie nach interessanten Eintr„gen und
*				 erweitert ihn um 10 Eintr„ge, wenn er zuwenig Platz hat.
* folgende Variablen werden gesetzt:
* CPU:	0 = 68000, 1 = 68010, 2 = 68020, 3 = 68030, 4 = 68040
*		Wert durch 10 geteilt
* FPU:	!=0 68881 oder 68882
*		nur ein Flag, keine Unterscheidungen
* VDO:	0 = st, 1 = STE, 2 = TT
*		das niederwertige Byte des oberen Worts
* SND:	Bit 0 = Yamaha, Bit 1 = DMA-Sound
*		unterstes Byte
* MCH:	0 = st, 1 = STE, 2 = TT, 3 = F030
*		das niederwertige Byte des oberen Worts
* MSTE:	$00 = 1040 STE, $01 = Notebook, $10 = Mega STE
*		unterstes Byte von _MCH
*
* TestMiNT:	Durchsucht den Cookie nach der MiNT Kennung.
* <--- flag.eq = gefunden, flag.ne = nicht gefunden
*
* TestNVDI:	Durchsucht den Cookie nach der NVDI Kennung.
* <--- flag.eq = gefunden, flag.ne = nicht gefunden
*
* TestSYMB: Sucht den Resident Symbol Driver von Robert Federle.
* <--- tst.l D0.l = Cookieeintrag oder 0, wenn nicht vorhanden
*-------------------------------------------------------------------------------


		.EXPORT		InstallCookie,TestMiNT,TestNVDI,TestSYMB,RES_SYMDRIVER

		.INCLUDE	'EQU.S'

*-------------------------------------------------------------------------------

		.TEXT
InstallCookie:	MOVEM.L		d0-a6,-(SP)
.COOKIE_REENTER:MOVEA.L		_P_COOKIES.w,A0
				MOVE.L		A0,D0
				BNE.S		.COOKIE_IN_USE

				MOVEQ		#COOKIE_LENGTH,D0		; neuer Cookie installieren
				LSL.L		#3,D0
				MOVE.L		D0,-(SP)
				jsr			MALLOC
				BEQ			.COOKIE_FAIL
				MOVEA.L		D0,A0
				MOVE.L		A0,_P_COOKIES.w
				MOVEQ		#COOKIE_LENGTH,D0
				MOVE.L		D0,4(A0)

.COOKIE_IN_USE:	clr.b		CPU
				clr.b		FPU
				clr.b		VDO
				clr.b		SND
				clr.b		MCH
				clr.b		MSTE
				MOVEQ		#0,D0
				SUBQ.W		#8,A0

*---------------

.COOKIE_SUCHEN:	ADDQ.L		#1,D0
				ADDQ.W		#8,A0

				move.l		(a0),d7					; Cookie Kennung

				CMPI.L		#'_CPU',d7				; CPU
				BNE.S		.NO_CPU
				CLR.B		DisassemCPU
				MOVE.L		4(A0),D1
				DIVU		#10,D1
				MOVE.B		D1,CPU
				BSET		D1,DisassemCPU

.NO_CPU:		CMPI.L		#'_FPU',d7				; FPU
				BNE.S		.NO_FPU
				cmpi.w		#1,6(a0)
				bhi.s		.FPU
				tst.w		4(a0)
				beq.s		.NO_FPU
.FPU:			st			FPU
				BSET		#6,DisassemCPU

.NO_FPU:		CMPI.L		#'_VDO',d7				; VDO
				BNE.S		.NO_VDO
				MOVE.B		5(A0),VDO

.NO_VDO:		CMPI.L		#'_SND',d7				; SND
				BNE.S		.NO_SND
				MOVE.B		7(A0),SND

.NO_SND: 		CMPI.L		#'_MCH',d7				; MCH
				BNE.S		.NO_MCH
				MOVE.B		5(A0),MCH
				MOVE.B		7(A0),MSTE

.NO_MCH:		TST.B		RESIDENT_FLAG			; Peacebug schon resident?
				BEQ.S		.NO_PBUG
				TST.B		AES_INSTALLED
				BNE.S		.NO_PBUG
				CMPI.L		#KENNUNG,d7
				BNE.S		.NO_PBUG
				MOVEA.L		4(A0),A1
				TST.B		-2(A1)
				BEQ.S		.NO_PBUG
				st			INST_FAILED
				BRA.S		.COOKIE_FAIL

.NO_PBUG:		CMPI.L		#'PMMU',d7				; PMMU
				BNE.S		.NO_PMMU
				TST.L		4(A0)
				BEQ.S		.NO_PMMU
				movem.l		d0-a6,-(sp)				; Speicherbereich schtzen
				moveq		#1,d0
				move.l		ProgrammLength,-(sp)
				move.l		ProgrammStart,-(sp)
				pea			1.w
				move.l		4(a0),a1
				jsr			(a1)
				lea			12(sp),sp
				movem.l		(sp)+,d0-a6

.NO_PMMU:		TST.L		d7
				BNE			.COOKIE_SUCHEN

*---------------

				TST.B		RESIDENT_FLAG			; Cookieeintrag installieren?
				BEQ.S		.COOKIE_FAIL
				MOVE.L		4(A0),D1
				SUB.L		D1,D0
				BGE.S		.TOO_SMALL				; zu wenige Eintr„ge?
				MOVE.L		A0,COOKIE_ADRESSE
				MOVE.L		#KENNUNG,(A0)+			; nein: dann eintragen
				MOVE.L		#COOKIE_RECORD,(A0)+
				CLR.L		(A0)+
				MOVE.L		D1,(A0)
.COOKIE_FAIL:	MOVEM.L		(SP)+,d0-a6
				RTS

.TOO_SMALL:		MOVE.L		D1,D3					; neuer Cookie reservieren
				ADDQ.W		#5,D3
				ADDQ.W		#5,D3
				MOVE.L		D3,D0
				LSL.L		#3,D0
				MOVE.L		D0,-(SP)
				jsr			MALLOC
				BEQ.S		.COOKIE_FAIL
				MOVEA.L		D0,A0					; Eintr„ge umkopieren
				MOVEA.L		_P_COOKIES.w,A1
				move.l		a0,a2
.COOKIE_COPY:	MOVE.L		(A1)+,(A0)+
				BEQ.S		.ALL_COPIED
				MOVE.L		(A1)+,(A0)+
				BRA.S		.COOKIE_COPY
.ALL_COPIED:	MOVE.L		D3,(A0)					; L„nge eintragen
				MOVE.L		a2,_P_COOKIES.w			; neuer Cookie
				BRA			.COOKIE_REENTER

*-------------------------------------------------------------------------------

TestMiNT:		move.l		d3,-(sp)
				move.l		#'MiNT',d3
				bsr.s		SearchCookie
				movem.l		(sp)+,d3		; movem, damit das CCR nicht
				rts							; ver„ndert wird

*-------------------------------------------------------------------------------

TestNVDI:		move.l		d3,-(sp)
				move.l		#'NVDI',d3
				bsr.s		SearchCookie
				movem.l		(sp)+,d3		; movem, damit das CCR nicht
				rts							; ver„ndert wird

*-------------------------------------------------------------------------------

TestSYMB:		move.l		d3,-(sp)
				move.l		#'SYMB',d3
				bsr.s		SearchCookie
				bne.s		.no_driver
				move.l		d3,d0
				bra.s		.ende
.no_driver:		moveq		#0,d0
.ende:			movem.l		(sp)+,d3		; movem, damit das CCR nicht
				rts							; ver„ndert wird

*-------------------------------------------------------------------------------

* ---> d3.l = Kennung
* <--- d3.l = Cookieeintrag
* <--- flag.eq = gefunden, flag.ne = nicht gefunden
SearchCookie:	movem.l		d0/a0,-(sp)
				move.l		_P_COOKIES.w,d0
				beq.s		.no_cookie
				move.l		d0,a0
				subq.w		#8,a0
.loop:			addq.w		#8,a0
				move.l		(a0),d0
				beq.s		.no_cookie
				cmp.l		d0,d3
				bne.s		.loop
				move.l		4(a0),d3
				moveq		#0,d0
				bra.s		.ende
.no_cookie:		moveq		#-1,d0
.ende:			movem.l		(sp)+,d0/a0
				rts
