*-------------------------------------------------------------------------------
* LONG_MULU/S: Longmultiplikation, kann Ueberlauf setzen.
* ---> D3.l, D2.l
* <--- D3.l = D3.l * D2.l
*
* LONG_DIVU/S: Longdivision, kann Division setzen.
* ---> D3.l, D2.l
* <--- D3.l = D3.l / D2.l
* <--- D1.l = Divisionsrest
*-------------------------------------------------------------------------------

		.EXPORT		LongDivu,LongDivs,LongMulu,LongMuls

*-------------------------------------------------------------------------------

LongDivs:		tst.l		d3
				bmi.s		.DFAKTOR1_MINUS
				tst.l		d2
				bmi.s		.DFAKTOR2_MINUS
				bra.s		LongDivu
.DFAKTOR1_MINUS:tst.l		d2
				bmi.s		.DFAKTOR12_MINUS
				neg.l		d3
				bsr.s		LongDivu
				neg.l		d3
				neg.l		d1
				rts
.DFAKTOR2_MINUS:neg.l		d2
				bsr.s		LongDivu
				neg.l		d3
				rts
.DFAKTOR12_MINUS:
				neg.l		d2
				neg.l		d3
				bsr.s		LongDivu
				neg.l		d1
				rts

*-------------------------------------------------------------------------------

LongDivu:		tst.l		d2
				bne.s		.not_zero
				st			Division
				rts
.not_zero:		MOVEM.L		D0/D2,-(SP)
				MOVEQ		#0,D1				; Rest auf Null
				MOVEQ		#31,D0				; 32 Bit Division
.loop:			ADD.L		D3,D3				; Dividend/Quotient shiften
				ADDX.L		D1,D1				; Dividend ins D0 shiften
				CMP.L		D1,D2				; bis D1 > Divisor?
				DBLS		D0,.loop			; nein, dann weitershiften
				BHI.S		.ende				; aber nur 32 Bit
				SUB.L		D2,D1				; Rest = Rest - Divisor
				ADDQ.W		#1,D3				; Stelle setzen
				DBRA		D0,.loop			; 32 mal
.ende:			MOVEM.L		(SP)+,D0/D2
				RTS

*-------------------------------------------------------------------------------

LongMuls:		TST.L		D3
				BMI.S		MFAKTOR1_MINUS
				TST.L		D2
				BMI.S		MFAKTOR2_MINUS
				bra.s		LongMulu
MFAKTOR1_MINUS:	TST.L		D2
				BMI.S		MFAKTOR12_MINUS
				NEG.L		D3
				BSR.S		LongMulu
				NEG.L		D3
				RTS
MFAKTOR2_MINUS: NEG.L		D2
				BSR.S		LongMulu
				NEG.L		D3
				RTS
MFAKTOR12_MINUS:NEG.L		D2
				NEG.L		D3

*-------------------------------------------------------------------------------

LongMulu:		MOVEM.L		D0-D2,-(SP)
				CMP.L		D2,D3
				BHS.S		FAKTOR_OK
				EXG			D2,D3
FAKTOR_OK:		CMP.L		#$FFFF,D2
				BHI.S		FEHLER
				MOVEQ		#0,D1
				MOVE.L		D3,D1
				SWAP		D1
				MULU		D2,D1
				CMP.L		#$FFFF,D1
				BHI.S		FEHLER
				SWAP		D1
				MULU		D2,D3
				ADD.L		D1,D3
				BCS.S		FEHLER
				movem.l		(sp)+,d0-d2
				rts
FEHLER:			st			Ueberlauf
				movem.l		(sp)+,d0-d2
				rts
