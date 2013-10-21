*
* Tut so, als ob ein Blitter installiert und aktiv waere
*
* (c) 1990 Marcel Waldvogel
*

id	= 'BSIM'
_68020	= $59e			;Flag fuer Stackframetyp
ssize	= 2048			;Stackgroesse

start:	bra	init


active:	dc.b	$FF
	even
	DC.l	'XBRA',id
oldvec:	DC.L	0
newvec:	move	USP,A0
	btst	#5,(A7)
	beq	oldproc
	lea	6(A7),A0
	tst.w	_68020.w	;Neuer Prozessor?
	beq	oldproc
	addq.l	#2,A0
oldproc:cmp.w	#64,(A0)	;Blitmode()?
	bne.b	go_old
	tst.b	active		;BLITSIM aktiv?
	bpl	go_old
	moveq	#3,D0		;Blitter da und eingeschaltet
	rte

go_old:	movea.l	oldvec(PC),A0
	jmp	(A0)
ende:				;Ende des residenten Teiles

****************************************************************************

init:	move.l	4(A7),A5	;Hole Basepage, (bis jetzt) nicht benutzt
	lea	stack,A7	;Setze Stack

	pea	-1.w
	move.w	#46,-(A7)	;TRAP #14
	move.w	#5,-(A7)	;Setexec()
	trap	#13
	addq.l	#8,A7
	movea.l	D0,A0

seek:	move.l	A0,D0		;Null?
	beq	install		;Ja ->
	cmpi.l	#'XBRA',-12(A0)	;XBRA-Kennung?
	bne	install		;Nein ->
	cmpi.l	#id,-8(A0)	;Wer ist es?
	beq	flip		;Wir ->
	movea.l	-4(A0),A0	;Zum naechsten Eintrag
	bra	seek


install:pea	newvec(PC)
	move.w	#46,-(a7)	;TRAP #14
	move.w	#5,-(a7)	;Setexc()
	trap	#13
	addq.l	#8,a7
	move.l	d0,oldvec

	pea	instmsg
	move.w	#9,-(A7)	;Cconws()
	trap	#1
	addq.l	#6,A7

	clr.w	-(a7)		;Alles ok
	move.l	#ende-start+256,-(a7)	;Belegter Speicher
	move.w	#$31,-(a7)	;Ptermres()
	trap	#1
	illegal			;Hier kommen wir nie hin


flip:	not.b	-14(A0)		;Flag invertieren
	bpl	deact		;Jetzt deaktiviert
	
	pea	actmsg
	bra	flip2

deact:	pea	deamsg
flip2:	move.w	#9,-(A7)	;Cconws()
	trap	#1
	addq.l	#6,A7

	pea	copr
	move.w	#9,-(A7)	;Cconws()
	trap	#1
	addq.l	#6,A7

	pea	keymsg
	move.w	#9,-(A7)	;Cconws()
	trap	#1
	addq.l	#6,A7

	move.w	#1,-(A7)	;Cconin()
	trap	#1
	addq.l	#6,A7

	clr.w	-(A7)		;Pterm0()
	trap	#1
	illegal


	DATA

instmsg:dc.b	13,10," BlitSim installed."
copr:	dc.b	13,10," (c) 1990 by Marcel Waldvogel"
	dc.b	13,10,0

actmsg:	dc.b	13,10," BlitSim reactivated.",0
deamsg:	dc.b	13,10," BlitSim deactivated.",0
keymsg:	dc.b	" Press any key...",0

	BSS

	even
	ds.b	ssize
stack:
