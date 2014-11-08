; ------------
; Goldrunner +
; ------------

; -------------------------------------------------------------------
; Unpacked, Trained & Repacked by MUG U.K(tm) of Regression Therapy !
; -------------------------------------------------------------------

; Bits removed/altered:
; ---------------------
;
; a) Removed Ozzwalds' Text Encryption!
; b) Added a trainer option
; c) Repacked game data using Atomik
; d) A few optimizations
; -------------------------------------------------------------------

	opt	o+
	text
begin
	bra	start

	dc.b	'Repacked & Trained by MUG U.K',191,' - 26/10/1997'
	dc.b	' Contact me at:  mug_uk@mindless.com'
	even

l0000	move.b	#$e,$ffff8800.l
	move.b	#7,$ffff8802.l
	lea	$68000,a0
	rts

introtxt	dc.b	27,'E'
	dc.b	'------------',13,10
	dc.b	'Goldrunner +',13,10
	dc.b	'------------',13,10,10
	dc.b	'Unpacked, trained & repacked by:',13,10,10
	dc.b	'MUG U.K',191,' on 26/10/97!',13,10,10

	dc.b	'Trainer gives you infinite shields and',13,10
	dc.b	'as a consequence makes you invincible',13,10
	dc.b	'against all buildings too!',13,10,10

	dc.b	'Fire button does not seem to work on',13,10
	dc.b	'current versions of Pacifist and the',13,10
	dc.b	'music only works on Pacifist 0.47!',13,10,10

	dc.b	'Email me if you have the answers to',13,10
	dc.b	'the above queries!  Addy in code!',13,10,10

	dc.b	"'T' for trainer, SPACE to depack.",13,10,10,0
	even


old_sp	dcb.w	2
start	nop
	dc.w	$a00a

	clr.l	-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	clr.w	-(a7)
	move.l	#$78000,-(a7)
	move.l	#$78000,-(a7)
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	adda.l	#$c,a7

	move.w	#0,$ff8240.l
	move.w	#$777,$ff825e.l

	pea	introtxt(pc)
	move.w	#9,-(a7)		;cconws
	trap	#1
	addq.l	#6,a7
;
; Test keyboard for 'T' or any other key
;	
	move.b	#0,infinite	; Clear infinite lives flag

key_loop	move.w	#8,-(a7)		;cnecin
	trap	#1
	addq.l	#2,a7

	cmp.b	#$74,d0		; 't' pressed
	beq.s	yes_train
	cmp.b	#$54,d0		; 'T' pressed
	beq.s	yes_train
	cmp.b	#$20,d0		; SPACE pressed
	beq.s	no_train
	bra.s	key_loop

yes_train	move.b	#1,infinite	; Yes, we want to cheat

no_train	

	move.w	#0,$ff825e.l

	lea	packed(pc),a0
	lea	$2ff00,a1
	bsr.s	depack

	cmp.b	#1,infinite
	bne.s	run_game
	move.b	#$60,$2ff00+$1578	; Salvos trainer

run_game
	move.l	old_sp,-(a7)
	move.w	#$20,-(a7)
	nop
	addq.l	#6,a7

	lea	$77ff8,a7

	move.l	#$2cff,d0
	lea	$10000,a0
	lea	$2ff00,a1
l0007	move.l	(a1),(a0)+
	clr.l	(a1)+
	dbf	d0,l0007
	move.l	#l0000,$14a90
	jmp	$10000

	include	'depack35.s'

	data

infinite	dc.b	0
	even

packed	incbin	'goldrunr.atm'
	even