*-------------------------------------------------------------------------------
* TEST_HEX: testet ob ein Ascii-Code Hexadezimal ist (0-9, A-F, a-f)
* ---> D3.b = Asciicode
* <--- D3.l = Asciicode (0-9, A-F) oder -1 im Fehlerfall, tst.l D3
*
* TEST_NUM: testet ob Numerikblock (0-9)
* ---> D0.w = Scancode
* <--- D3.l = Asciicode oder -1 im Fehlerfall, tst.l D3
*
* TEST_BORDER: testet ob der Cursor auf einem gltigen Bereich steht
* <--- flag.ne = gltig, flag.eq = ungltig
*
* TEST_SHOW: testet ob der Cursor im Showfeld steht
* <--- flag.ne = steht im Showfeld, flag.eq = nicht im Showfeld
*
* TEST_EDIT: testet, wo sich der Cursor befindet
* <--- flag.eq = Normal, flag.mi = Register, flag.gt = Adresse
*
* GET_LINEADRESS: berechnet die Adresse einer Zeile (Asciiscreen)
* ---> D3.w = Zeile, deren Adresse berechnet werden soll (0-...)
* <--- A0.l = berechnete Adresse
*
* GET_Y_ADRESS: berechnet die Adresse der aktuellen Zeile (Asciiscreen)
* <--- A0.l = berechnete Adresse
*
* GET_XY_ADRESS: berechnet die Adresse des Cursors (Asciiscreen)
* <--- A0.l = berechnete Adresse
*
* GET_ADRESS_1: berechnet die Adresse, die am Anfang einer Zeile steht
* ---> D3.w = Zeile
* <--- D0.l = Zahl
* <--- flag.eq = alles io., flag.ne = keine Zeilenadresse
*
* GET_ADRESS_2: berechnet die Adresse, die am Anfang der aktuellen Zeile steht
* <--- D0.l = Zahl
* <--- flag.eq = alles io., flag.ne = keine Zeilenadresse
*-------------------------------------------------------------------------------

		.EXPORT		TEST_HEX,TEST_NUM,TEST_BORDER,TEST_SHOW,TEST_EDIT
		.EXPORT		GET_LINEADRESS,GET_Y_ADRESS,GET_XY_ADRESS,GET_ADRESS_1,GET_ADRESS_2

*-------------------------------------------------------------------------------

TEST_HEX:		and.l		#$ff,d3
				cmpi.b		#'0',d3
				blo.s		.nohex
				cmpi.b		#'9',d3
				bls.s		.number
				cmpi.b		#'A',d3
				blo.s		.nohex
				cmpi.b		#'F',d3
				bls.s		.number
				sub.b		#97-65,d3		; Kleinbuchstaben?
				cmpi.b		#'A',d3
				blo.s		.nohex
				cmpi.b		#'F',d3
				bls.s		.number
.nohex: 		moveq		#-1,d3
.number:		tst.l		d3
				rts

*-------------------------------------------------------------------------------

TEST_NUM:		move.w		d0,-(sp)
				cmpi.w		#103,d0
				blo.s		.nonum
				cmpi.w		#112,d0
				bhi.s		.nonum
				subi.w		#103,d0
				moveq		#0,d3
				move.b		.asciitable(pc,d0.w),d3
				bra.s		.num
.nonum: 		moveq		#-1,d3
.num:			move.w		(sp)+,d0
				tst.l		d3
				rts

.asciitable:	dc.b	'7','8','9','4','5','6','1','2','3','0'

*-------------------------------------------------------------------------------

TEST_BORDER:	movem.l		d0-a6,-(sp)
				bsr			GET_Y_ADRESS	; aktuelle Adresse
				st			d7				; gltig
				cmpi.b		#'$',(a0)
				bne.s		.noborder
				tst.w		X_POSITION
				beq.s		.border
				cmpi.w		#9,X_POSITION
				bne.s		.noborder
.border: 		sf			d7				; ungltig
.noborder:		tst.b		d7
				movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

TEST_SHOW:		movem.l		d0-d1,-(sp)
				sf			d1				; nicht Showfeld
				move.w		FIRST_LINE,d0
				cmp.w		Y_POSITION,d0
				bls.s		.noshow
				cmpi.w		#4,Y_POSITION
				shi			d1				; Showfeld, wenn Y <= 4
.noshow:		tst.b		d1
				movem.l		(sp)+,d0-d1
				rts

*-------------------------------------------------------------------------------

TEST_EDIT:		movem.l		d0-a6,-(sp)
				move.w		Y_POSITION,d0
				cmp.w		FIRST_LINE,d0
				slo			d7
				blo.s		.ende			; Register
				bsr			GET_Y_ADRESS
				cmpi.b		#'$',(a0)
				bne.s		.ende			; Normal, kein $
				tst.w		X_POSITION
				beq.s		.ende			; Normal, X = 0
				cmpi.w		#8,X_POSITION
				bhi.s		.ende			; Normal, X > 8
				moveq		#1,d7			; Adressfeld
.ende:			tst.b		d7
				movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

GET_LINEADRESS: move.l		d3,-(sp)
				mulu		ZEILEN_LAENGE,d3
				movea.l		ZEICHEN_ADRESSE,a0
				adda.l		d3,a0
				move.l		(sp)+,d3
				rts

*-------------------------------------------------------------------------------

GET_Y_ADRESS:	bsr.s		GET_XY_ADRESS
				suba.w		X_POSITION,a0
				rts

*-------------------------------------------------------------------------------

GET_XY_ADRESS:	move.l		d0,-(sp)
				movea.l		ZEICHEN_ADRESSE,a0
				move.w		Y_POSITION,d0
				mulu		ZEILEN_LAENGE,d0
				adda.l		d0,a0
				adda.w	    X_POSITION,a0
				move.l		(sp)+,d0
				rts

*-------------------------------------------------------------------------------

GET_ADRESS_1:	movem.l		d3/d7-a0,-(sp)
				mulu		ZEILEN_LAENGE,d3
				movea.l		ZEICHEN_ADRESSE,a0
				adda.l		d3,a0
				cmpi.b		#'$',(a0)+
				bne.s		.no_address
				moveq		#0,d0
				moveq		#7,d7
.loop:			move.b		(a0)+,d3
				subi.b		#'0',d3
				cmp.b		#'A'-'0',d3
				blo.s		.NurZahl
				sub.b		#'A'-'0'-10,d3
.NurZahl:		lsl.l		#4,d0
				or.b		d3,d0
				dbra		d7,.loop
				moveq		#0,d3
				bra.s		.cont
.no_address:	moveq		#-1,d3
.cont:			movem.l		(sp)+,d3/d7-a0
				rts

*---------------

GET_ADRESS_2:	move.l		d3,-(sp)
				move.w		Y_POSITION,d3
				bsr.s		GET_ADRESS_1
				movem.l		(sp)+,d3			; movem wegen CCR
				rts
