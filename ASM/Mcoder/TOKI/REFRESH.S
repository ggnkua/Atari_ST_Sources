	output	a:\auto\toki.prg
hauteur = 176+16
largeur = 224+16
;
; 0->$DC=CARACTERES
; $DC->...=BITMAP
;
	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr
	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	jsr	debugger
	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	MOVE.L	#SOURCE,PTR
	BSR	REFRESH
plante:	bra	plante
	ILLEGAL
REFRESH:
	MOVE.L	PTR,A4
	MOVEQ	#hauteur/16-1,D7
	lea	$78000,a6
VERTIC:
	MOVEQ	#0,D0
	MOVE.B	(A4),D0
	ASL	#7,D0

	LEA	SOURCE+$DC,A5
	ADD	D0,A5		;a5=source bitmap
;
; d5-d7/a2-a4 non utilis‚s dans shift.bin
;
	incbin	shift.bin

	LEA	20(A4),A4
	DBRA	D7,VERTIC
	RTS
PTR:	DC.L	0
palette:
	DC.W	$000,$102,$213,$324,$435,$657,$776,$412
	DC.W	$762,$740,$612,$547,$300,$200,$070,$070

SOURCE:
	incbin	vign.img
debugger:
	incbin	debugger.bin
