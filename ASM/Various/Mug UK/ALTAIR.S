; --------
; Altair +
; --------

; -------------------------------------------------------------------
; Unpacked, Trained & Repacked by MUG U.K(tm) of Regression Therapy !
; -------------------------------------------------------------------

; Bits removed/altered:
; ---------------------
;
; a) Removed Ozzwalds' Text Encryption!
; b) Added a trainer option
; c) Repacked game data using ICE v2.40
; d) A few optimizations
;
; -------------------------------------------------------------------

	opt	o+

begin
	bra.s	start

	dc.b	'Unpacked,trained & repacked by '
	dc.b	'MUG U.K',191,' 20/10/97 - mikemee@lineone.net - '
	dc.b	'RT97',0
	even

start	nop
	clr.l	-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	move.l	d0,old_sp
	addq.l	#6,sp

	lea	$80000,a7

	dc.w	$a00a

	clr.w	-(a7)
	move.l	#$78000,-(a7)
	move.l	#$78000,-(a7)
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	adda.l	#$c,a7

	pea	palette
	move.w	#6,-(a7)		;setpallete
	trap	#$e
	addq.l	#6,a7

	pea	introtxt(pc)
	move.w	#9,-(a7)		;cconws
	trap	#1
	addq.w	#6,a7
;
; Test keyboard for 'T' or any other key
;	
	move.b	#0,infinite	; Clear infinite lives flag
key_loop	bsr.s	get_key
	cmp.b	#$74,d0		; 't' pressed
	beq.s	yes_train
	cmp.b	#$54,d0		; 'T' pressed
	beq.s	yes_train
	cmp.b	#$20,d0		; SPACE pressed
	beq.s	no_train
	bra.s	key_loop

yes_train	move.b	#1,infinite	; Yes, we want to cheat

no_train	lea	packed(pc),a0
	lea	$1865e,a1
	bsr.s	depack
;
; Will sir be cheating ?  I'll just check .....
	cmp.b	#1,infinite

; No ..
	bne.s	run_game

; Oh sir, can't you play this properly yet ?

	move.b	#$4a,$1865e+$2dc8

run_game	move.l	#old_sp,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,sp

	lea	$77ff8,a7
	lea	patch(pc),a1
	move.l	a1,$1bbac
	jmp	$1865e

patch	move.l	#$30000,d0
loop	subq.l	#1,d0
	cmp.l	#0,d0
	bne.s	loop
	rts

get_key	move.w	#8,-(a7)		;cnecin
	trap	#1
	addq.l	#2,a7
	rts

	include	"ice_a0a1.s"

palette	dc.w	$000,$711,$172,$115,$222,$224,$002,$336
	dc.w	$333,$447,$444,$367,$555,$577,$752,$777

infinite	dc.b	0
	even

old_sp	dc.l	0	

introtxt	dc.b	27,'E'
	dc.b	'--------',13,10
	dc.b	'Altair +',13,10
	dc.b	'--------',13,10,10
	dc.b	'Unpacked, trained & repacked by:',13,10,10
	dc.b	'MUG U.K',191,' on 20/10/97!',13,10,10
	dc.b	'Hi to all I met at the Atari Show in ',13,10
	dc.b	'London yesterday!  Esp. everyone who',13,10
	dc.b	'sat out most of the show in the bar!',13,10,10  
	dc.b	"'T' for trainer, SPACE to depack.",13,10,10,0
	even

packed	incbin	'altair.ice'
	even

zuend	dc.b	'RT97'
	dc.w	0
	even
