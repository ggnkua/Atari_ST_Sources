*-------------------------------------------------------------------------------
* TrapVektor: H„ngt Vektoren gem„ss FLAGS ein.
*
* UntrapVektor: H„ngt alle Vektoren aus.
*
* TestVektor: Testet ob eine bestimmte Debuggerroutine in einem Vektor h„ngt.
* ---> A3.l = Vektor
* ---> A5.l = Routine
* <--- A6.l = Routine, die auf Peacebug zeigt oder 0, wenn an erster Stelle
* <--- flag.eq = gefunden, flag.ne = nicht gefunden
*-------------------------------------------------------------------------------

		.EXPORT		TrapVektor,UntrapVektor,TestVektor

		.INCLUDE	'EQU.S'

*-------------------------------------------------------------------------------

		.DATA
Zero:			dc.b		0,0

*-------------------------------------------------------------------------------

		.TEXT
UntrapVektor:	movem.l		d0-a6,-(sp)
				moveq		#0,d6
				lea			Zero,a2
				bra.s		VektorEntry

*-------------------------------------------------------------------------------

TrapVektor: 	movem.l		d0-a6,-(sp)

				moveq		#2,d6
				lea			FLAGS,a2

VektorEntry:	move.w		sr,-(sp)
				ori.w		#$0700,sr

				lea			VEKTOR_ADRESSEN,a0
				lea			ROUTINEN_ADRESSEN,a1

				moveq		#ANZAHL_VEKTOREN-1,d0
.loop:			movea.w		(a0)+,a3			; Vektor
				move.w		(a1)+,d7			; Offset
				lea			ROUTINEN_ADRESSEN,a5
				adda.w		d7,a5				; Routine

				tst.b		AES_INSTALLED
				bne.s		.no_AES
				cmpa.l		#$88,a3
				beq.s		.next_Vektor
				cmpa.l		#$2c,a3
				beq.s		.next_Vektor

.no_AES:		bsr			TestVektor
				beq.s		.got_it

*---------------

* -1 und 1 installieren neu, alle anderen Werte machen gar nichts
				tst.b		CHEAT_MODE
				bne.s		.new_Install
				cmpi.b		#1,(a2)
				beq.s		.new_Install
				cmpi.b		#-1,(a2)
				beq.s		.new_Install
				bra.s		.next_Vektor

*---------------

* alle negativen Werte h„ngen an die erste Stelle, 0 h„ngt aus, alle positiven
* Werte machen gar nichts
.got_it: 		tst.b		CHEAT_MODE
				bne.s		.its_cheat
				tst.b		(a2)
				bgt.s		.next_Vektor		; 1, 2

.its_cheat:		move.l		a6,d7				; 0, -1, -2
				beq.s		.first_Position
				move.l		-4(a5),-4(a6)		; aush„ngen
				bra.s		.minus
.first_Position:move.l		-4(a5),(a3)			; aush„ngen
.minus:			tst.b		(a2)
				beq.s		.next_Vektor		; 0 macht nix mehr
.new_Install:	move.l		(a3),-4(a5)			;-1, -2, (1), neu installieren
				move.l		a5,(a3)

*---------------

.next_Vektor:	adda.w		d6,a2
				dbra		d0,.loop

				lea			RESVECTOR.w,a3
				lea			RESET,a5
				bsr.s		TestVektor
				bne.s		.not_found
				move.l		#$31415926,RESVALID.w

.not_found:		move.w		(sp)+,sr
				movem.l		(sp)+,d0-a6
				rts

*-------------------------------------------------------------------------------

TestVektor:		move.l		d0,-(sp)
				pea			.error(pc)
				bsr			TestBusOn
				movea.l		(a3),a6				; a6 = Routine
				cmpa.l		#$8,a3				; Busvektor?
				bne.s		.no_bus
				movea.l		OLD_TEST_BUS,a6
.no_bus:		cmpa.l		#$c,a3				; Addressvektor?
				bne.s		.no_address
				movea.l		OLD_TEST_ADRESS,a6
.no_address:	moveq		#99,d0				; maximal 100 Verkettungen
				moveq		#0,d7				; d7 = letzte Routine
.loop:			cmpi.l		#'XBRA',-12(a6)		; XBRA?
				bne.s		.not_found
				cmpi.l		#KENNUNG,-8(a6)		; PBUG?
				bne.s		.not_my_own
				cmpa.l		a5,a6				; Routine?
				beq.s		.found
.not_my_own:	cmpa.l		-4(a6),a6			; Endlosschleife?
				beq.s		.not_found
				move.l		a6,d7
				movea.l		-(a6),a6
				dbra		d0,.loop
.not_found:		bsr			TestBusOff
				addq.w		#4,sp
.error:			moveq		#-1,d0
				bra.s		.test_ende
.found:			bsr			TestBusOff
				addq.w		#4,sp
				movea.l		d7,a6
				moveq		#0,d0
.test_ende:		movem.l		(sp)+,d0		; wegen CCR
				rts
