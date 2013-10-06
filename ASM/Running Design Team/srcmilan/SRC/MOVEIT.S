
STEP1000	equ	1500			; pixelschritt innerhalb 1000 msek.
STEPDELAY1000	equ	250
TURN1000	equ	128			; gradaenderung innerhalb 1000 msek.
TURNDELAY1000	equ	16



		text

moveIt
		lea	keytable,a1
		lea	keyoverlay,a2
		movea.l	playerDataPtr,a6

	; a1/a2/a6 fuer die gesamte routine

		move.l	PDSX(a6),PDTESTSX(a6)
		move.l	PDSY(a6),PDTESTSY(a6)

		clr.w	PDHASMOVED(a6)
		clr.w	PDHASTURNED(a6)
		clr.w	PDHASSHOT(a6)

	; wenn spieler gestorben, dann keine bewegung

		tst.w	PDHEALTH(a6)
		bmi	miOut

	; run mode

		move.w	KORUNMODESWITCH(a2),d0
		tst.b	(a1,d0.w)
		beq.s	miRunModeOk

		clr.b	(a1,d0.w)		; taste wieder loeschen
		lea	msgRunModeOn,a0
		move.w	PDRUNMODE(a6),d0
		bchg	#0,d0
		beq.s	mirmOn
		lea	msgRunModeOff,a0
mirmOn		move.w	d0,PDRUNMODE(a6)
		bsr	installMessage
miRunModeOk		

	; schrittweiten berechnen

		fmove.w	vblTime1000,fp0
		fdiv.w	#1000,fp0

		fmove.x	fp0,fp1
		fmove.x	fp0,fp2
		fmove.x	fp0,fp3
		fmul.w	#STEP1000,fp0
		fmove.w	fp0,d7			; d7 = aktuelle schrittweite
		tst.w	d7
		bne.s	miD7Ok
		moveq	#1,d7
miD7Ok		fmul.w	#TURN1000,fp1
		fmove.w	fp1,d6			; d6 = aktuelle winkelschrittweite
		tst.w	d6
		bne.s	miD6Ok
		moveq	#1,d6
miD6Ok		fmul.w	#STEPDELAY1000,fp2
		fmove.w	fp2,d5			; d5 = schrittweitenverzoegerung
		tst.w	d5
		bne.s	miD5Ok
		moveq	#1,d5
miD5Ok		fmul.w	#TURNDELAY1000,fp3
		fmove.w	fp3,d4			; d4 = winkelschrittweitenverzoegerung
		tst.w	d4
		bne.s	miD4Ok
		moveq	#1,d4
miD4Ok

	; springt unser spieler?

		move.w	KOJUMP(a2),d0
		tst.b	(a1,d0.w)
		beq.s	miNoJump
		bsr	miJumpNow
miNoJump

	; registerbelegung:  a1 = keytable
	;                    a2 = keyoverlay
	;                    a6 = playerDataPtr
	;                    d4 = winkelschrittweitenverzoegerung
	;                    d5 = schrittweitenverzoegerung
	;                    d6 = winkelschrittweite
	;                    d7 = schrittweite
	; vorwaerts- und rueckwaertsbewegung

		move.w	KOFORWARD(a2),d0
		tst.b	(a1,d0.w)
		beq.s	miNoForward
		bsr	miForwardNow
		bra.s	miNoSlowerStep
miNoForward
		move.w	KOBACKWARD(a2),d0
		tst.b	(a1,d0.w)
		beq.s	miNoBackward
		bsr	miBackwardNow
		bra.s	miNoSlowerStep
miNoBackward
		tst.w	PDLASTSTEP(a6)
		beq.s	miNoSlowerStep
		bsr	miSlowerStepNow
miNoSlowerStep

	; seitwaertsbewegung

		move.w	KOALTERNATE(a2),d0
		tst.b	(a1,d0.w)		; alternate
		beq.s	miNoStrafe

		move.w	KOLEFT(a2),d0
		tst.b	(a1,d0.w)
		beq.s	miNoStrafeLeft
		bsr	miStrafeLeftNow
miNoStrafeLeft	move.w	KORIGHT(a2),d0
		tst.b	(a1,d0.w)
		beq.s	miNoStrafeRight
		bsr	miStrafeRightNow
miNoStrafeRight	bra.s	miSkipAlpha		; wenn seitwaets bewegt wurde, dann normale drehung ueberspringen

miNoStrafe

	; drehbewegung links- oder rechtsherum

		move.w	KOLEFT(a2),d0
		tst.b	(a1,d0.w)
		beq.s	miNoLeft
		bsr	miLeftNow
		bra.s	miNoSlowerAlpha
miNoLeft	move.w	KORIGHT(a2),d0
		tst.b	(a1,d0.w)
		beq.s	miNoRight
		bsr	miRightNow
		bra.s	miNoSlowerAlpha
miNoRight
		tst.w	PDLASTALPHA(a6)
		beq.s	miNoSlowerAlpha
		bsr	miSlowerAlphaNow
miNoSlowerAlpha
miSkipAlpha

miOut
		rts


; ---------------------------------------------------------
; vorwaerts- und rueckwaertsbewegung
; jeweils belegt: d4-d7/a1-a2/a6
miForwardNow
		move.w	PDLASTSTEP(a6),d0
		bpl.s	mifnNoBackward
		moveq	#0,d0
mifnNoBackward	add.w	d5,d0
		cmp.w	d7,d0
		blt.s	mifnStepOk
		move.w	d7,d0
mifnStepOk	move.w	KORUNMODE(a2),d1
		tst.w	(a1,d1.w)
		beq.s	mifnNoRun
		lsl.w	#1,d0
mifnNoRun	move.w	d0,PDLASTSTEP(a6)
		move.w	PDALPHA(a6),d1
		bsr	makeWalk
		rts

miBackwardNow
		move.w	PDLASTSTEP(a6),d0
		bmi.s	mibnNoForward
		moveq	#0,d0
mibnNoForward	sub.w	d5,d0
		move.w	d0,d1
		neg.w	d1
		cmp.w	d7,d1
		blt.s	mibnStepOk
		move.w	d7,d0
		neg.w	d0
mibnStepOk	move.w	KORUNMODE(a2),d1
		tst.w	(a1,d1.w)
		beq.s	mibnNoRun
		lsl.w	#1,d0
mibnNoRun	move.w	d0,PDLASTSTEP(a6)
		move.w	PDALPHA(a6),d1
		bsr	makeWalk
		rts

miSlowerStepNow
		move.w	d5,d1
		move.w	KORUNMODE(a2),d0
		tst.b	(a1,d0.w)
		beq.s	missnNoRun
		add.w	d1,d1
missnNoRun	move.w	PDLASTSTEP(a6),d0
		beq.s	missnOut
		bmi.s	missnBackward
		sub.w	d1,d0				; verzoegerung
		bmi.s	missnNoMore
		bra.s	missnNewPos
missnBackward	add.w	d1,d0
		bpl.s	missnNoMore
missnNewPos	move.w	d0,PDLASTSTEP(a6)
		move.w	PDALPHA(a6),d1
		bsr	makeWalk
		bra.s	missnOut
missnNoMore	clr.w	PDLASTSTEP(a6)
missnOut
		rts


; ---------------------------------------------------------
; spieler will einen neuen sprung beginnen
; belegt: d4-d7/a1-a2/a6
miJumpNow
		clr.b	(a1,d0.w)

	; kein sprung moeglich, wenn
	; spieler gerade in einem sprung
	; sich befindet ...

		tst.w	PDJUMPFLAG(a6)
		bne.s	mijnOut

	; kein sprung moeglich, wenn spieler nicht auf dem boden steht. dazu muss die
	; differenz zwischen tatsaechlicher bodenhoehe und hoehe des spielers zwischen -3 und 3 liegen ...

		move.w	PDSH(a6),d3
		sub.w	PDSHREAL(a6),d3
		bpl.s	mijnDifPos
		neg.w	d3
mijnDifPos	lsr.w	#1,d3
		bne.s	mijnOut

	; spieler kann jetzt springen

		move.w	#1,PDJUMPFLAG(a6)
		clr.w	PDJUMPPOS(a6)
		move.w	PDSHREAL(a6),PDJUMPSTARTSH(a6)

		moveq	#SNDJUMP,d0
		bsr	initSimpleSam
mijnOut
		rts


; ---------------------------------------------------------
; links- und rechtsbewegung
; belegt: d4-d7/a1-a2/a6
miLeftNow
		move.w	PDLASTALPHA(a6),d0
		bpl.s	milnNoRight
		moveq	#0,d0
milnNoRight	add.w	d4,d0
		cmp.w	d6,d0
		blt.s	milnTurnOk
		move.w	d6,d0
milnTurnOk	move.w	KORUNMODE(a2),d1
		tst.b	(a1,d1.w)
		beq.s	milnNoRun
		add.w	d0,d0
milnNoRun	move.w	PDALPHA(a6),d2
		add.w	d0,d2
		andi.w	#$1ff,d2
		move.w	d0,PDLASTALPHA(a6)
		move.w	d2,PDALPHA(a6)
		move.w	#1,PDHASTURNED(a6)
		rts

miRightNow
		move.w	PDLASTALPHA(a6),d0
		bmi.s	mirnNoLeft
		moveq	#0,d0
mirnNoLeft	sub.w	d4,d0
		move.w	d0,d1
		neg.w	d1
		cmp.w	d6,d1
		blt.s	mirnTurnOk
		move.w	d6,d0
		neg.w	d0
mirnTurnOk	move.w	KORUNMODE(a2),d1
		tst.b	(a1,d1.w)
		beq.s	mirnNoRun
		add.w	d0,d0
mirnNoRun	move.w	PDALPHA(a6),d2
		add.w	d0,d2
		andi.w	#$1ff,d2
		move.w	d0,PDLASTALPHA(a6)
		move.w	d2,PDALPHA(a6)
		move.w	#1,PDHASTURNED(a6)
		rts

miSlowerAlphaNow
		move.w	d4,d1
		move.w	KORUNMODE(a2),d0
		tst.b	(a1,d1.w)
		beq.s	misanNoRun
		add.w	d1,d1
misanNoRun	move.w	PDLASTALPHA(a6),d0
		bmi.s	misanRight
misanLeft	sub.w	d1,d0
		bpl.s	misanOk
		moveq	#0,d0
		bra.s	misanOk
misanRight	add.w	d1,d0
		bmi.s	misanOk
		moveq	#0,d0
misanOk		move.w	d0,PDLASTALPHA(a6)
		add.w	PDALPHA(a6),d0
		andi.w	#$1ff,d0
		move.w	d0,PDALPHA(a6)
		rts


; ---------------------------------------------------------
; seitwaertsbewegung
; belegt: d4-d7/a1-a2/a6
miStrafeLeftNow
		move.w	d7,d0
		move.w	PDALPHA(a6),d1
		addi.w	#$80,d1
		andi.w	#$1ff,d1
		bsr	makeWalk
		rts

miStrafeRightNow
		move.w	d7,d0
		move.w	PDALPHA(a6),d1
		subi.w	#$80,d1
		andi.w	#$1ff,d1
		bsr	makeWalk
		rts


; ---------------------------------------------------------
; berechnung einer neuen spielerposition
; d0 = schrittweite
; d1 = winkel
; a6 = playerDataPtr
; benutzte register: d0-d2/a3/fp0-fp2
makeWalk
		move.w	d0,mwStep
		move.w	d1,mwAlpha
		lea	sinus512TabX,a3
		move.w	d1,d2
		add.w	d1,d1
		fmove.x	(a3,d1.w*8),fp0		; sinus
		addi.w	#$80,d2
		andi.w	#$1ff,d2
		add.w	d2,d2
		fmove.x	(a3,d2.w*8),fp1		; cosinus
		fmove.w	d0,fp2			; schrittweite
		fmul.x	fp2,fp0
		fmul.x	fp2,fp1
		fadd.l	PDSY(a6),fp0
		fadd.l	PDSX(a6),fp1
		fmove.l	fp1,PDTESTSX(a6)
		fmove.l	fp0,PDTESTSY(a6)
		move.w	#1,PDHASMOVED(a6)
		rts




		data




		bss


mwStep		ds.w	1
mwAlpha		ds.w	1
